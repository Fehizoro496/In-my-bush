package mg.inmybush.api.admin;

import java.util.UUID;
import mg.inmybush.api.admin.dto.AdminUserResponse;
import mg.inmybush.api.admin.dto.DashboardResponse;
import mg.inmybush.api.catalog.ProductModerationService;
import mg.inmybush.api.catalog.ProductRepository;
import mg.inmybush.api.catalog.ProductStatus;
import mg.inmybush.api.common.NotFoundException;
import mg.inmybush.api.common.PageResponse;
import mg.inmybush.api.common.Pages;
import mg.inmybush.api.order.OrderRepository;
import mg.inmybush.api.order.OrderStatus;
import mg.inmybush.api.order.dto.OrderSummaryResponse;
import mg.inmybush.api.report.ReportRepository;
import mg.inmybush.api.report.ReportService;
import mg.inmybush.api.report.ReportStatus;
import mg.inmybush.api.report.dto.ReportResponse;
import mg.inmybush.api.shop.ShopRepository;
import mg.inmybush.api.user.User;
import mg.inmybush.api.user.UserRepository;
import mg.inmybush.api.user.UserStatus;
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

    public AdminService(UserRepository users, ShopRepository shops, ProductRepository products,
                        OrderRepository orders, ReportRepository reports, ReportService reportService,
                        ProductModerationService productModeration) {
        this.users = users;
        this.shops = shops;
        this.products = products;
        this.orders = orders;
        this.reports = reports;
        this.reportService = reportService;
        this.productModeration = productModeration;
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
    public PageResponse<AdminUserResponse> listUsers(int page, int size) {
        return PageResponse.of(users.findAll(Pages.newestFirst(page, size)), AdminUserResponse::from);
    }

    @Transactional
    public AdminUserResponse suspendUser(UUID userId) {
        User user = users.findById(userId).orElseThrow(() -> NotFoundException.of("Utilisateur", userId));
        user.setStatus(UserStatus.SUSPENDED);
        return AdminUserResponse.from(user);
    }

    @Transactional
    public AdminUserResponse banUser(UUID userId) {
        User user = users.findById(userId).orElseThrow(() -> NotFoundException.of("Utilisateur", userId));
        user.setStatus(UserStatus.BANNED);
        return AdminUserResponse.from(user);
    }

    @Transactional
    public AdminUserResponse reactivateUser(UUID userId) {
        User user = users.findById(userId).orElseThrow(() -> NotFoundException.of("Utilisateur", userId));
        user.setStatus(UserStatus.ACTIVE);
        return AdminUserResponse.from(user);
    }

    // ------------------------------------------------------------------ products

    @Transactional
    public void approveProduct(UUID productId) {
        productModeration.approve(productId); // returns SellerProductResponse, ignored here
    }

    @Transactional
    public void rejectProduct(UUID productId, String reason) {
        productModeration.reject(productId, reason); // returns SellerProductResponse, ignored here
    }

    // ------------------------------------------------------------------ orders

    @Transactional(readOnly = true)
    public PageResponse<OrderSummaryResponse> listOrders(int page, int size) {
        return PageResponse.of(orders.findAllWithDetails(Pages.newestFirst(page, size)), OrderSummaryResponse::from);
    }

    // ------------------------------------------------------------------ reports

    @Transactional(readOnly = true)
    public PageResponse<ReportResponse> listReports(ReportStatus status, int page, int size) {
        return reportService.list(status, page, size);
    }

    @Transactional
    public ReportResponse resolveReport(UUID adminId, UUID reportId, ReportStatus newStatus, String note) {
        return reportService.resolve(adminId, reportId, newStatus, note);
    }
}
