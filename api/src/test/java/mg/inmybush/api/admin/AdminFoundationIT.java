package mg.inmybush.api.admin;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Duration;
import java.util.UUID;
import mg.inmybush.api.admin.repository.AuditRepository;
import mg.inmybush.api.auth.service.AuthRateLimiter;
import mg.inmybush.api.catalog.entity.*;
import mg.inmybush.api.catalog.repository.*;
import mg.inmybush.api.common.ApiException;
import mg.inmybush.api.shop.entity.Shop;
import mg.inmybush.api.shop.repository.ShopRepository;
import mg.inmybush.api.user.entity.*;
import mg.inmybush.api.user.repository.UserRepository;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;

/** Real migrations and transactions in a fresh isolated schema; never resets the development schema. */
@SpringBootTest
@AutoConfigureMockMvc
class AdminFoundationIT {
    static final String SCHEMA = "imb_it_" + UUID.randomUUID().toString().replace("-", "");
    @DynamicPropertySource static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.flyway.default-schema", () -> SCHEMA);
        registry.add("spring.flyway.schemas", () -> SCHEMA);
        registry.add("spring.jpa.properties.hibernate.default_schema", () -> SCHEMA);
        registry.add("spring.datasource.hikari.connection-init-sql", () -> "SET search_path TO " + SCHEMA + ",public");
        registry.add("spring.flyway.locations", () -> "classpath:db/migration");
        registry.add("app.sms.mmsduck.api-key", () -> "");
    }
    @AfterAll static void dropSchema(@Autowired JdbcTemplate jdbc) {
        jdbc.execute("DROP SCHEMA IF EXISTS " + SCHEMA + " CASCADE");
    }
    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @Autowired UserRepository users;
    @Autowired PasswordEncoder passwords;
    @Autowired ShopRepository shops;
    @Autowired CategoryRepository categories;
    @Autowired ProductRepository products;
    @Autowired AuditRepository audit;
    @Autowired AuthRateLimiter limiter;

    User user(String first, boolean admin) {
        String unique = UUID.randomUUID().toString();
        User u = new User(first, "Test", unique + "@example.test", "+261" + String.format("%09d", Integer.toUnsignedLong(unique.hashCode()) % 1000000000), passwords.encode("test-password"));
        if (admin) u.addRole(Role.ADMIN);
        return users.saveAndFlush(u);
    }
    com.fasterxml.jackson.databind.JsonNode login(User u) throws Exception {
        var response = mvc.perform(post("/api/v1/auth/login").contentType("application/json")
            .content(json.writeValueAsString(java.util.Map.of("identifier", u.getEmail(), "password", "test-password"))))
            .andExpect(status().isOk()).andReturn().getResponse();
        return json.readTree(response.getContentAsString());
    }
    @Test void realLoginModerationAuditAndSuspension() throws Exception {
        User admin = user("Admin", true);
        User buyer = user("Acheteur", false);
        String adminToken = login(admin).get("accessToken").asText();
        var buyerSession = login(buyer);
        String buyerToken = buyerSession.get("accessToken").asText();
        mvc.perform(get("/api/v1/admin/dashboard").header("Authorization", "Bearer " + buyerToken)).andExpect(status().isForbidden());
        Shop shop = shops.saveAndFlush(new Shop(buyer, "Boutique test", UUID.randomUUID().toString()));
        Category category = categories.findAll().get(0);
        Product product = new Product(shop, category, "Produit test", UUID.randomUUID().toString());
        product.setUnit(ProductUnit.KG);
        product.setPrice(1000);
        product.submitForReview();
        product = products.saveAndFlush(product);
        mvc.perform(get("/api/v1/admin/products?status=PENDING_REVIEW").header("Authorization", "Bearer " + adminToken))
            .andExpect(status().isOk()).andExpect(jsonPath("$.items[0].id").value(product.getId().toString()));
        mvc.perform(post("/api/v1/admin/products/" + product.getId() + "/reject").header("Authorization", "Bearer " + adminToken)
            .contentType("application/json").content("{\"reason\":\"Photo illisible\"}")).andExpect(status().isNoContent());
        assertEquals(ProductStatus.REJECTED, products.findById(product.getId()).orElseThrow().getStatus());
        assertTrue(audit.findAll().stream().anyMatch(e -> e.getActorId().equals(admin.getId()) && "Photo illisible".equals(e.getReason())));
        mvc.perform(post("/api/v1/admin/users/" + buyer.getId() + "/suspend").header("Authorization", "Bearer " + adminToken)
            .contentType("application/json").content("{\"reason\":\"Contrôle du compte\"}")).andExpect(status().isOk());
        mvc.perform(get("/api/v1/me").header("Authorization", "Bearer " + buyerToken)).andExpect(status().isUnauthorized());
        mvc.perform(post("/api/v1/auth/refresh").contentType("application/json")
            .content(json.writeValueAsString(java.util.Map.of("refreshToken", buyerSession.get("refreshToken").asText()))))
            .andExpect(status().isUnauthorized());
        mvc.perform(get("/api/v1/admin/users?role=BUYER&status=SUSPENDED&q=Acheteur").header("Authorization", "Bearer " + adminToken))
            .andExpect(status().isOk()).andExpect(jsonPath("$.totalItems").value(1));
        // Other tests share the schema: count only this administrator's events.
        assertEquals(2, audit.findAll().stream().filter(e -> e.getActorId().equals(admin.getId())).count());
        mvc.perform(get("/api/v1/admin/audit").header("Authorization", "Bearer " + adminToken))
            .andExpect(status().isOk()).andExpect(jsonPath("$.items[0].actorName").value("Admin Test"));
    }
    @Test void deactivatingACategoryMovesItsProductsAndHidesIt() throws Exception {
        String token = "Bearer " + login(user("Admin", true)).get("accessToken").asText();
        var created = json.readTree(mvc.perform(post("/api/v1/admin/categories").header("Authorization", token)
            .contentType("application/json").content("{\"name\":\"Thés " + UUID.randomUUID().toString().substring(0, 8) + "\"}"))
            .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString());
        UUID categoryId = UUID.fromString(created.get("id").asText());
        Category target = categories.findAll().stream().filter(c -> c.getParent() == null && !c.getId().equals(categoryId)).findFirst().orElseThrow();
        Shop shop = shops.saveAndFlush(new Shop(user("Vendeur", false), "Boutique thé", UUID.randomUUID().toString()));
        Product product = new Product(shop, categories.findById(categoryId).orElseThrow(), "Thé vert", UUID.randomUUID().toString());
        product.setUnit(ProductUnit.KG);
        product.setPrice(1000);
        product = products.saveAndFlush(product);
        mvc.perform(post("/api/v1/admin/categories/" + categoryId + "/deactivate").header("Authorization", token))
            .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("CATEGORY_HAS_PRODUCTS"));
        mvc.perform(post("/api/v1/admin/categories/" + categoryId + "/deactivate").header("Authorization", token)
            .contentType("application/json").content("{\"replacementId\":\"" + target.getId() + "\"}"))
            .andExpect(status().isOk()).andExpect(jsonPath("$.active").value(false));
        assertEquals(target.getId(), products.findById(product.getId()).orElseThrow().getCategory().getId());
        String publicList = mvc.perform(get("/api/v1/categories")).andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        assertFalse(publicList.contains(categoryId.toString()));
        mvc.perform(get("/api/v1/admin/categories").header("Authorization", token)).andExpect(status().isOk())
            .andExpect(jsonPath("$[?(@.id == '" + categoryId + "')].active").value(false));
        assertTrue(audit.findAll().stream().anyMatch(e -> "CATEGORY_DEACTIVATED".equals(e.getAction()) && categoryId.equals(e.getTargetId())));
    }
    @Test void failedDecisionsDoNotCreateAuditEvents() throws Exception {
        String token = login(user("Admin", true)).get("accessToken").asText();
        long before = audit.count();
        mvc.perform(post("/api/v1/admin/products/" + UUID.randomUUID() + "/approve")
            .header("Authorization", "Bearer " + token)).andExpect(status().isNotFound());
        assertEquals(before, audit.count());
    }
    @Test void rateLimitIsPersistentAndReturns429() {
        String key = "test:" + UUID.randomUUID();
        limiter.check(key, 2, Duration.ofMinutes(1));
        limiter.check(key, 2, Duration.ofMinutes(1));
        ApiException error = assertThrows(ApiException.class, () -> limiter.check(key, 2, Duration.ofMinutes(1)));
        assertEquals(429, error.getStatus().value());
        assertThrows(ApiException.class, () -> limiter.check(key, 2, Duration.ofMinutes(1)));
    }
}
