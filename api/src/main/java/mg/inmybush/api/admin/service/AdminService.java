package mg.inmybush.api.admin.service;

import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.Locale;
import java.util.UUID;
import mg.inmybush.api.admin.dto.AdminUserResponse;
import mg.inmybush.api.admin.dto.DashboardResponse;
import mg.inmybush.api.auth.service.RefreshTokenService;
import mg.inmybush.api.catalog.dto.SellerProductResponse;
import mg.inmybush.api.catalog.entity.ProductStatus;
import mg.inmybush.api.catalog.mapper.ProductMapper;
import mg.inmybush.api.catalog.repository.ProductRepository;
import mg.inmybush.api.catalog.service.ProductModerationService;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.order.dto.OrderSummaryResponse;
import mg.inmybush.api.order.entity.OrderStatus;
import mg.inmybush.api.order.repository.OrderRepository;
import mg.inmybush.api.report.dto.ReportResponse;
import mg.inmybush.api.report.entity.ReportStatus;
import mg.inmybush.api.report.repository.ReportRepository;
import mg.inmybush.api.report.service.ReportService;
import mg.inmybush.api.shop.repository.ShopRepository;
import mg.inmybush.api.user.entity.Role;
import mg.inmybush.api.user.entity.User;
import mg.inmybush.api.user.entity.UserStatus;
import mg.inmybush.api.user.repository.UserRepository;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminService {

    private final UserRepository users;
    private final ShopRepository shops;
    private final ProductRepository products;
    private final OrderRepository orders;
    private final ReportRepository reports;
    private final ReportService reportService;
    private final ProductModerationService productModeration;
    private final RefreshTokenService refreshTokens;
    private final AuditService audit;

    public AdminService(UserRepository users, ShopRepository shops, ProductRepository products,
                        OrderRepository orders, ReportRepository reports, ReportService reportService,
                        ProductModerationService productModeration,
                        RefreshTokenService refreshTokens, AuditService audit) {
        this.users = users;
        this.shops = shops;
        this.products = products;
        this.orders = orders;
        this.reports = reports;
        this.reportService = reportService;
        this.productModeration = productModeration;
        this.refreshTokens = refreshTokens;
        this.audit = audit;
    }

    @Transactional(readOnly = true)
    public DashboardResponse dashboard() {
        return new DashboardResponse(
            users.count(),
            shops.count(),
            products.count(),
            products.countByStatus(ProductStatus.PUBLISHED),
            products.countByStatus(ProductStatus.PENDING_REVIEW),
            orders.count(),
            orders.countByStatus(OrderStatus.PENDING_CONFIRMATION),
            orders.sumTotal(),
            orders.sumCommission(),
            reports.countByStatus(ReportStatus.OPEN));
    }

    // ------------------------------------------------------------------ users

    @Transactional(readOnly = true)
    public PageResponse<AdminUserResponse> listUsers(Role role, UserStatus status,
        String q, int page, int size) {
        Specification<User> spec = (root, query, cb) -> {
            var predicates = new ArrayList<Predicate>();
            if (role != null) predicates.add(cb.isMember(role, root.get("roles")));
            if (status != null) predicates.add(cb.equal(root.get("status"), status));
            if (q != null && !q.isBlank()) {
                String term = "%" + q.trim().toLowerCase(Locale.ROOT)
                    .replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
                predicates.add(cb.or(cb.like(cb.lower(root.get("firstName")), term, '\\'),
                    cb.like(cb.lower(root.get("lastName")), term, '\\'),
                    cb.like(cb.lower(root.get("email")), term, '\\'), cb.like(root.get("phone"), term, '\\')));
            }
            return cb.and(predicates.toArray(Predicate[]::new));
        };
        return PageResponse.of(users.findAll(spec, Pages.newestFirst(page, size)), AdminUserResponse::from);
    }

    @Transactional
    public AdminUserResponse suspendUser(UUID userId, String reason) {
        User user = users.findById(userId).orElseThrow(() -> NotFoundException.of("Utilisateur", userId));
        user.setStatus(UserStatus.SUSPENDED);
        refreshTokens.revokeAll(userId);
        audit.record("USER_SUSPENDED", "USER", userId, reason.trim());
        return AdminUserResponse.from(user);
    }

    @Transactional
    public AdminUserResponse banUser(UUID userId, String reason) {
        User user = users.findById(userId).orElseThrow(() -> NotFoundException.of("Utilisateur", userId));
        user.setStatus(UserStatus.BANNED);
        refreshTokens.revokeAll(userId);
        audit.record("USER_BANNED", "USER", userId, reason.trim());
        return AdminUserResponse.from(user);
    }

    @Transactional
    public AdminUserResponse reactivateUser(UUID userId) {
        User user = users.findById(userId).orElseThrow(() -> NotFoundException.of("Utilisateur", userId));
        user.setStatus(UserStatus.ACTIVE);
        audit.record("USER_REACTIVATED", "USER", userId, null);
        return AdminUserResponse.from(user);
    }

    // ------------------------------------------------------------------ products

    @Transactional(readOnly = true)
    public PageResponse<SellerProductResponse> listProducts(ProductStatus status, int page, int size) {
        return productModeration.list(status, null, page, size);
    }

    @Transactional(readOnly = true)
    public SellerProductResponse product(UUID id) {
        return ProductMapper.toSellerView(products.findById(id)
            .orElseThrow(() -> NotFoundException.of("Produit", id)));
    }

    @Transactional
    public void approveProduct(UUID productId) {
        productModeration.approve(productId); // returns SellerProductResponse, ignored here
        audit.record("PRODUCT_APPROVED", "PRODUCT", productId, null);
    }

    @Transactional
    public void rejectProduct(UUID productId, String reason) {
        productModeration.reject(productId, reason); // returns SellerProductResponse, ignored here
        audit.record("PRODUCT_REJECTED", "PRODUCT", productId, reason.trim());
    }

    // ------------------------------------------------------------------ orders

    @Transactional(readOnly = true)
    public PageResponse<OrderSummaryResponse> listOrders(OrderStatus status, int page, int size) {
        return PageResponse.of(status == null ? orders.findAllWithDetails(Pages.newestFirst(page, size))
            : orders.findByStatus(status, Pages.newestFirst(page, size)), OrderSummaryResponse::from);
    }

    // ------------------------------------------------------------------ reports

    @Transactional(readOnly = true)
    public PageResponse<ReportResponse> listReports(ReportStatus status, int page, int size) {
        return reportService.list(status, page, size);
    }

    @Transactional
    public ReportResponse resolveReport(UUID adminId, UUID reportId, ReportStatus newStatus, String note) {
        var result = reportService.resolve(adminId, reportId, newStatus, note);
        audit.record("REPORT_" + newStatus.name(), "REPORT", reportId, note);
        return result;
    }
}
