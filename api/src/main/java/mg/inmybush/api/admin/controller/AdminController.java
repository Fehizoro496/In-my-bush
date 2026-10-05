package mg.inmybush.api.admin.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Map;
import java.util.UUID;
import mg.inmybush.api.admin.dto.AdminUserResponse;
import mg.inmybush.api.admin.dto.DashboardResponse;
import mg.inmybush.api.admin.dto.ModerationRequest;
import mg.inmybush.api.admin.dto.ResolveReportRequest;
import mg.inmybush.api.auth.security.CurrentUser;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.order.dto.OrderSummaryResponse;
import mg.inmybush.api.report.entity.ReportStatus;
import mg.inmybush.api.report.dto.ReportResponse;
import mg.inmybush.api.settings.service.SettingsService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import mg.inmybush.api.admin.service.AdminService;

@RestController
@RequestMapping("/api/v1/admin")
@Tag(name = "Admin")
public class AdminController {

    private final AdminService adminService;
    private final SettingsService settingsService;

    public AdminController(AdminService adminService, SettingsService settingsService) {
        this.adminService = adminService;
        this.settingsService = settingsService;
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
                                                  @RequestParam(defaultValue = "20") int size) {
        return adminService.listUsers(page, size);
    }

    @PostMapping("/users/{id}/suspend")
    @Operation(summary = "Suspendre un utilisateur")
    public AdminUserResponse suspendUser(@PathVariable UUID id) {
        return adminService.suspendUser(id);
    }

    @PostMapping("/users/{id}/ban")
    @Operation(summary = "Bannir un utilisateur")
    public AdminUserResponse banUser(@PathVariable UUID id) {
        return adminService.banUser(id);
    }

    @PostMapping("/users/{id}/reactivate")
    @Operation(summary = "Réactiver un utilisateur")
    public AdminUserResponse reactivateUser(@PathVariable UUID id) {
        return adminService.reactivateUser(id);
    }

    // ------------------------------------------------------------------ products moderation

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

    // ------------------------------------------------------------------ orders

    @GetMapping("/orders")
    @Operation(summary = "Toutes les commandes")
    public PageResponse<OrderSummaryResponse> orders(@RequestParam(defaultValue = "0") int page,
                                                      @RequestParam(defaultValue = "20") int size) {
        return adminService.listOrders(page, size);
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
    @Operation(summary = "Modifier des paramètres")
    public Map<String, String> updateSettings(@RequestBody Map<String, String> changes) {
        return settingsService.update(changes);
    }
}
