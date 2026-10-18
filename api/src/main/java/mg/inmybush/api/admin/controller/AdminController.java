package mg.inmybush.api.admin.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import mg.inmybush.api.admin.dto.AdminCategoryResponse;
import mg.inmybush.api.admin.dto.AdminUserResponse;
import mg.inmybush.api.admin.dto.AuditEventResponse;
import mg.inmybush.api.admin.dto.CategoryRequest;
import mg.inmybush.api.admin.dto.DashboardResponse;
import mg.inmybush.api.admin.dto.DeactivateCategoryRequest;
import mg.inmybush.api.admin.dto.ModerationRequest;
import mg.inmybush.api.admin.dto.ResolveReportRequest;
import mg.inmybush.api.admin.service.AdminCategoryService;
import mg.inmybush.api.admin.service.AdminService;
import mg.inmybush.api.admin.service.AuditService;
import mg.inmybush.api.auth.security.CurrentUser;
import mg.inmybush.api.catalog.dto.SellerProductResponse;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.order.dto.OrderSummaryResponse;
import mg.inmybush.api.order.entity.OrderStatus;
import mg.inmybush.api.report.dto.ReportResponse;
import mg.inmybush.api.report.entity.ReportStatus;
import mg.inmybush.api.settings.service.SettingsService;
import mg.inmybush.api.user.entity.Role;
import mg.inmybush.api.user.entity.UserStatus;
import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin")
@Tag(name = "Admin")
public class AdminController {

    private final AdminService adminService;
    private final SettingsService settingsService;
    private final AuditService audit;
    private final AdminCategoryService categoryService;

    public AdminController(AdminService adminService, SettingsService settingsService,
        AuditService audit, AdminCategoryService categoryService) {
        this.adminService = adminService;
        this.settingsService = settingsService;
        this.audit = audit;
        this.categoryService = categoryService;
    }

    @GetMapping("/dashboard")
    @Operation(summary = "Tableau de bord")
    public DashboardResponse dashboard() {
        return adminService.dashboard();
    }

    // ------------------------------------------------------------------ users

    @GetMapping("/users")
    @Operation(summary = "Liste des utilisateurs")
    public PageResponse<AdminUserResponse> users(@RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(required = false) Role role,
        @RequestParam(required = false) UserStatus status,
        @RequestParam(required = false) String q) {
        return adminService.listUsers(role, status, q, page, size);
    }

    @PostMapping("/users/{id}/suspend")
    @Operation(summary = "Suspendre un utilisateur")
    public AdminUserResponse suspendUser(@PathVariable UUID id, @Valid @RequestBody ModerationRequest request) {
        return adminService.suspendUser(id, request.reason());
    }

    @PostMapping("/users/{id}/ban")
    @Operation(summary = "Bannir un utilisateur")
    public AdminUserResponse banUser(@PathVariable UUID id, @Valid @RequestBody ModerationRequest request) {
        return adminService.banUser(id, request.reason());
    }

    @PostMapping("/users/{id}/reactivate")
    @Operation(summary = "Réactiver un utilisateur")
    public AdminUserResponse reactivateUser(@PathVariable UUID id) {
        return adminService.reactivateUser(id);
    }

    // ------------------------------------------------------------------ products moderation

    @GetMapping("/products")
    @Operation(summary = "Liste des produits, à valider ou non")
    public PageResponse<SellerProductResponse> products(
        @RequestParam(required = false) ProductStatus status,
        @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return adminService.listProducts(status, page, size);
    }

    @GetMapping("/products/{id}")
    @Operation(summary = "Fiche d'un produit")
    public SellerProductResponse product(@PathVariable UUID id) {
        return adminService.product(id);
    }

    @GetMapping("/audit")
    @Operation(summary = "Journal des actions d'administration")
    public PageResponse<AuditEventResponse> audit(
        @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return audit.list(page, size);
    }

    @PostMapping("/products/{id}/approve")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Approuver un produit")
    public void approveProduct(@PathVariable UUID id) {
        adminService.approveProduct(id);
    }

    @PostMapping("/products/{id}/reject")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Rejeter un produit")
    public void rejectProduct(@PathVariable UUID id, @Valid @RequestBody ModerationRequest request) {
        adminService.rejectProduct(id, request.reason());
    }

    // ------------------------------------------------------------------ categories

    @GetMapping("/categories")
    @Operation(summary = "Toutes les catégories, actives ou non, dans l'ordre d'affichage")
    public List<AdminCategoryResponse> categories() {
        return categoryService.list();
    }

    @PostMapping("/categories")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Créer une catégorie (lien déduit du nom s'il est vide)")
    public AdminCategoryResponse createCategory(@Valid @RequestBody CategoryRequest request) {
        return categoryService.create(request);
    }

    @PutMapping("/categories/{id}")
    @Operation(summary = "Modifier une catégorie")
    public AdminCategoryResponse updateCategory(@PathVariable UUID id, @Valid @RequestBody CategoryRequest request) {
        return categoryService.update(id, request);
    }

    @PostMapping("/categories/{id}/move")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Monter ou descendre une catégorie parmi ses voisines")
    public void moveCategory(@PathVariable UUID id, @RequestParam AdminCategoryService.Direction direction) {
        categoryService.move(id, direction);
    }

    @PostMapping("/categories/{id}/deactivate")
    @Operation(summary = "Désactiver une catégorie ; ses produits vont dans replacementId (obligatoire s'il y en a)")
    public AdminCategoryResponse deactivateCategory(@PathVariable UUID id, @RequestBody(required = false) DeactivateCategoryRequest request) {
        return categoryService.deactivate(id, request == null ? null : request.replacementId());
    }

    @PostMapping("/categories/{id}/reactivate")
    @Operation(summary = "Réactiver une catégorie")
    public AdminCategoryResponse reactivateCategory(@PathVariable UUID id) {
        return categoryService.reactivate(id);
    }

    // ------------------------------------------------------------------ orders

    @GetMapping("/orders")
    @Operation(summary = "Toutes les commandes")
    public PageResponse<OrderSummaryResponse> orders(@RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(required = false) OrderStatus status) {
        return adminService.listOrders(status, page, size);
    }

    // ------------------------------------------------------------------ reports

    @GetMapping("/reports")
    @Operation(summary = "Signalements")
    public PageResponse<ReportResponse> reports(@RequestParam(required = false) ReportStatus status,
                                                 @RequestParam(defaultValue = "0") int page,
                                                 @RequestParam(defaultValue = "20") int size) {
        return adminService.listReports(status, page, size);
    }

    @PostMapping("/reports/{id}/resolve")
    @Operation(summary = "Résoudre un signalement")
    public ReportResponse resolveReport(@PathVariable UUID id, @Valid @RequestBody ResolveReportRequest request) {
        return adminService.resolveReport(CurrentUser.id(), id, request.status(), request.note());
    }

    // ------------------------------------------------------------------ settings

    @GetMapping("/settings")
    @Operation(summary = "Paramètres de la plateforme")
    public Map<String, String> settings() {
        return settingsService.all();
    }

    @PatchMapping("/settings")
    @Transactional
    @Operation(summary = "Modifier des paramètres")
    public Map<String, String> updateSettings(@RequestBody Map<String, String> changes) {
        var result = settingsService.update(changes);
        audit.record("SETTINGS_UPDATED", "PLATFORM", null, String.join(", ", changes.keySet()));
        return result;
    }
}
