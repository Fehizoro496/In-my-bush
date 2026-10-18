package mg.inmybush.api.admin;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import java.util.Optional;
import java.util.UUID;
import mg.inmybush.api.admin.controller.AdminController;
import mg.inmybush.api.admin.dto.CategoryRequest;
import mg.inmybush.api.admin.service.AdminCategoryService;
import mg.inmybush.api.admin.service.AdminService;
import mg.inmybush.api.admin.service.AuditService;
import mg.inmybush.api.config.SecurityConfig;
import mg.inmybush.api.config.AppProperties;
import mg.inmybush.api.settings.service.SettingsService;
import mg.inmybush.api.user.entity.User;
import mg.inmybush.api.user.entity.UserStatus;
import mg.inmybush.api.user.entity.Role;
import mg.inmybush.api.user.repository.UserRepository;
import mg.inmybush.api.order.entity.OrderStatus;
import mg.inmybush.api.catalog.entity.ProductStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(AdminController.class)
@Import(SecurityConfig.class)
class AdminAccessTest {
    @Autowired MockMvc mvc;
    @MockitoBean AdminService admin;
    @MockitoBean AdminCategoryService categories;
    @MockitoBean SettingsService settings;
    @MockitoBean AuditService audit;
    @MockitoBean UserRepository users;
    @MockitoBean JwtDecoder decoder;
    @MockitoBean AppProperties props;
    final UUID id = UUID.randomUUID();
    User user;
    @BeforeEach void setup() {
        user = new User("Admin", "Test", null, "+261340000000", "hash");
        user.setId(id);
        when(users.findById(id)).thenReturn(Optional.of(user));
    }
    private org.springframework.test.web.servlet.request.RequestPostProcessor as(String role) {
        return jwt().jwt(j -> j.subject(id.toString())).authorities(new SimpleGrantedAuthority("ROLE_" + role));
    }
    @Test void anonymousCannotReadAdmin() throws Exception {
        mvc.perform(get("/api/v1/admin/dashboard")).andExpect(status().isUnauthorized());
    }
    @Test void buyerCannotReadOrMutateAdmin() throws Exception {
        mvc.perform(get("/api/v1/admin/dashboard").with(as("BUYER"))).andExpect(status().isForbidden());
        mvc.perform(post("/api/v1/admin/products/" + id + "/approve").with(as("BUYER"))).andExpect(status().isForbidden());
        verifyNoInteractions(admin);
    }
    @Test void suspensionImmediatelyRejectsAnUnexpiredJwt() throws Exception {
        user.setStatus(UserStatus.SUSPENDED);
        mvc.perform(get("/api/v1/admin/dashboard").with(as("ADMIN"))).andExpect(status().isUnauthorized());
        verifyNoInteractions(admin);
    }
    @Test void adminCanReadProductsAndFiltersReachService() throws Exception {
        mvc.perform(get("/api/v1/admin/products?status=PENDING_REVIEW&page=2&size=25").with(as("ADMIN"))).andExpect(status().isOk());
        verify(admin).listProducts(ProductStatus.PENDING_REVIEW, 2, 25);
        mvc.perform(get("/api/v1/admin/users?role=SELLER&status=ACTIVE&q=Hery").with(as("ADMIN"))).andExpect(status().isOk());
        verify(admin).listUsers(Role.SELLER, UserStatus.ACTIVE, "Hery", 0, 20);
        mvc.perform(get("/api/v1/admin/orders?status=DELIVERED").with(as("ADMIN"))).andExpect(status().isOk());
        verify(admin).listOrders(OrderStatus.DELIVERED, 0, 20);
    }
    @Test void rejectionAndSuspensionRequireNonBlankReason() throws Exception {
        for (String path : new String[]{"products/" + id + "/reject", "users/" + id + "/suspend", "users/" + id + "/ban"}) {
            mvc.perform(post("/api/v1/admin/" + path).with(as("ADMIN")).contentType("application/json")
                .content("{\"reason\":\"   \"}")).andExpect(status().isBadRequest());
        }
        verifyNoInteractions(admin);
    }
    @Test void validRejectionAndReportResolutionUseCanonicalRoutes() throws Exception {
        mvc.perform(post("/api/v1/admin/products/" + id + "/reject").with(as("ADMIN"))
            .contentType("application/json").content("{\"reason\":\"Photo illisible\"}")).andExpect(status().isNoContent());
        verify(admin).rejectProduct(id, "Photo illisible");
        mvc.perform(post("/api/v1/admin/reports/" + id + "/resolve").with(as("ADMIN"))
            .contentType("application/json").content("{\"status\":\"DISMISSED\",\"note\":\"Sans objet\"}")).andExpect(status().isOk());
        verify(admin).resolveReport(id, id, mg.inmybush.api.report.entity.ReportStatus.DISMISSED, "Sans objet");
    }
    @Test void onlyAdminsManageCategories() throws Exception {
        mvc.perform(get("/api/v1/admin/categories").with(as("SELLER"))).andExpect(status().isForbidden());
        mvc.perform(post("/api/v1/admin/categories").with(as("SELLER")).contentType("application/json")
            .content("{\"name\":\"Thés\"}")).andExpect(status().isForbidden());
        verifyNoInteractions(categories);
    }
    @Test void categoryRoutesReachTheService() throws Exception {
        mvc.perform(get("/api/v1/admin/categories").with(as("ADMIN"))).andExpect(status().isOk());
        verify(categories).list();
        mvc.perform(post("/api/v1/admin/categories").with(as("ADMIN")).contentType("application/json")
            .content("{\"name\":\"Thés\",\"icon\":\"leaf\"}")).andExpect(status().isCreated());
        verify(categories).create(new CategoryRequest("Thés", null, "leaf", null));
        mvc.perform(put("/api/v1/admin/categories/" + id).with(as("ADMIN")).contentType("application/json")
            .content("{\"name\":\"Thés et tisanes\",\"slug\":\"thes\"}")).andExpect(status().isOk());
        verify(categories).update(id, new CategoryRequest("Thés et tisanes", "thes", null, null));
        mvc.perform(post("/api/v1/admin/categories/" + id + "/move?direction=UP").with(as("ADMIN"))).andExpect(status().isNoContent());
        verify(categories).move(id, AdminCategoryService.Direction.UP);
        UUID other = UUID.randomUUID();
        mvc.perform(post("/api/v1/admin/categories/" + id + "/deactivate").with(as("ADMIN")).contentType("application/json")
            .content("{\"replacementId\":\"" + other + "\"}")).andExpect(status().isOk());
        verify(categories).deactivate(id, other);
        mvc.perform(post("/api/v1/admin/categories/" + id + "/deactivate").with(as("ADMIN"))).andExpect(status().isOk());
        verify(categories).deactivate(id, null);
        mvc.perform(post("/api/v1/admin/categories/" + id + "/reactivate").with(as("ADMIN"))).andExpect(status().isOk());
        verify(categories).reactivate(id);
    }
    @Test void aCategoryNeedsAName() throws Exception {
        for (String body : new String[]{"{\"name\":\"  \"}", "{\"name\":\"x\"}", "{}"}) {
            mvc.perform(post("/api/v1/admin/categories").with(as("ADMIN")).contentType("application/json").content(body))
                .andExpect(status().isBadRequest());
        }
        verifyNoInteractions(categories);
    }
}
