package mg.inmybush.api.admin.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import mg.inmybush.api.admin.dto.AdminCategoryResponse;
import mg.inmybush.api.admin.dto.AdminReportDetailResponse;
import mg.inmybush.api.admin.dto.AdminShopDetailResponse;
import mg.inmybush.api.admin.dto.AdminShopResponse;
import mg.inmybush.api.admin.dto.AdminUserDetailResponse;
import mg.inmybush.api.admin.dto.AdminUserResponse;
import mg.inmybush.api.admin.dto.AuditEventResponse;
import mg.inmybush.api.admin.dto.CategoryRequest;
import mg.inmybush.api.admin.dto.DashboardResponse;
import mg.inmybush.api.admin.dto.DeactivateCategoryRequest;
import mg.inmybush.api.admin.dto.ModerationRequest;
import mg.inmybush.api.admin.dto.ReportNoteRequest;
import mg.inmybush.api.admin.dto.ReportNoteResponse;
import mg.inmybush.api.admin.dto.ResolveReportRequest;
import mg.inmybush.api.admin.service.AdminCategoryService;
import mg.inmybush.api.admin.service.AdminReportService;
import mg.inmybush.api.admin.service.AdminService;
import mg.inmybush.api.admin.service.AdminShopService;
import mg.inmybush.api.admin.service.AuditService;
import mg.inmybush.api.auth.security.CurrentUser;
import mg.inmybush.api.catalog.dto.SellerProductResponse;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.order.dto.OrderSummaryResponse;
import mg.inmybush.api.order.entity.OrderStatus;
import mg.inmybush.api.report.dto.ReportResponse;
import mg.inmybush.api.report.entity.ReportStatus;
import mg.inmybush.api.report.entity.TargetType;
import mg.inmybush.api.settings.service.SettingsService;
import mg.inmybush.api.shop.entity.ShopStatus;
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
    private final AdminShopService shopService;
    private final AdminReportService reportService;

    public AdminController(AdminService adminService, SettingsService settingsService, AuditService audit,
        AdminCategoryService categoryService, AdminShopService shopService, AdminReportService reportService) {
        this.adminService = adminService;
        this.settingsService = settingsService;
        this.audit = audit;
        this.categoryService = categoryService;
        this.shopService = shopService;
        this.reportService = reportService;
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

    @GetMapping("/users/{id}")
    @Operation(summary = "Fiche d'un utilisateur : boutique, activité et historique des décisions")
    public AdminUserDetailResponse user(@PathVariable UUID id) {
        return adminService.user(id);
    }

    @PostMapping("/users/{id}/suspend")
    @Operation(summary = "Suspendre un utilisateur (ni son propre compte, ni le dernier administrateur actif)")
    public AdminUserResponse suspendUser(@PathVariable UUID id, @Valid @RequestBody ModerationRequest request) {
        return adminService.suspendUser(CurrentUser.id(), id, request.reason());
    }

    @PostMapping("/users/{id}/ban")
    @Operation(summary = "Bannir un utilisateur (ni son propre compte, ni le dernier administrateur actif)")
    public AdminUserResponse banUser(@PathVariable UUID id, @Valid @RequestBody ModerationRequest request) {
        return adminService.banUser(CurrentUser.id(), id, request.reason());
    }

    @PostMapping("/users/{id}/reactivate")
    @Operation(summary = "Réactiver un utilisateur")
    public AdminUserResponse reactivateUser(@PathVariable UUID id) {
        return adminService.reactivateUser(id);
    }

    // ------------------------------------------------------------------ products moderation

    @GetMapping("/products")
    @Operation(summary = "Liste des produits : statut, recherche, catégorie (sous-catégories comprises) et boutique")
    public PageResponse<SellerProductResponse> products(
        @RequestParam(required = false) ProductStatus status,
        @RequestParam(required = false) String q,
        @RequestParam(required = false) UUID categoryId,
        @RequestParam(required = false) UUID shopId,
        @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return adminService.listProducts(status, q, categoryId, shopId, page, size);
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

    @PostMapping("/products/{id}/withdraw")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Retirer de la vente un produit publié ; le vendeur peut le corriger et le soumettre à nouveau")
    public void withdrawProduct(@PathVariable UUID id, @Valid @RequestBody ModerationRequest request) {
        adminService.withdrawProduct(id, request.reason());
    }

    // ------------------------------------------------------------------ shops

    @GetMapping("/shops")
    @Operation(summary = "Boutiques : statut et recherche (nom, ville, propriétaire)")
    public PageResponse<AdminShopResponse> shops(@RequestParam(required = false) ShopStatus status,
        @RequestParam(required = false) String q,
        @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return shopService.list(status, q, page, size);
    }

    @GetMapping("/shops/{id}")
    @Operation(summary = "Fiche d'une boutique : propriétaire, produits par statut et historique des décisions")
    public AdminShopDetailResponse shop(@PathVariable UUID id) {
        return shopService.get(id);
    }

    @PostMapping("/shops/{id}/suspend")
    @Operation(summary = "Suspendre une boutique : masquée du catalogue, plus de nouvelles commandes")
    public AdminShopResponse suspendShop(@PathVariable UUID id, @Valid @RequestBody ModerationRequest request) {
        return shopService.suspend(id, request.reason());
    }

    @PostMapping("/shops/{id}/reactivate")
    @Operation(summary = "Réactiver une boutique suspendue")
    public AdminShopResponse reactivateShop(@PathVariable UUID id) {
        return shopService.reactivate(id);
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
    @Operation(summary = "Signalements, par statut et type de contenu")
    public PageResponse<ReportResponse> reports(@RequestParam(required = false) ReportStatus status,
                                                 @RequestParam(required = false) TargetType type,
                                                 @RequestParam(defaultValue = "0") int page,
                                                 @RequestParam(defaultValue = "20") int size) {
        return reportService.list(status, type, page, size);
    }

    @GetMapping("/reports/{id}")
    @Operation(summary = "Fiche d'un signalement : contenu signalé, notes internes et historique")
    public AdminReportDetailResponse report(@PathVariable UUID id) {
        return reportService.get(id);
    }

    @PostMapping("/reports/{id}/resolve")
    @Operation(summary = "Prendre en charge (IN_REVIEW) ou clore (RESOLVED, DISMISSED, motif obligatoire) un signalement")
    public ReportResponse resolveReport(@PathVariable UUID id, @Valid @RequestBody ResolveReportRequest request) {
        return reportService.changeStatus(CurrentUser.id(), id, request.status(), request.note());
    }

    @PostMapping("/reports/{id}/notes")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Ajouter une note interne, visible de l'équipe de modération seulement")
    public ReportNoteResponse addReportNote(@PathVariable UUID id, @Valid @RequestBody ReportNoteRequest request) {
        return reportService.addNote(CurrentUser.id(), id, request.body());
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
