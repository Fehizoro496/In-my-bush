package mg.inmybush.api.admin.dto;

public record DashboardResponse(
    long totalUsers,
    long totalShops,
    long totalProducts,
    long publishedProducts,
    long pendingProducts,
    long totalOrders,
    long pendingOrders,
    long totalRevenue,
    long totalCommission,
    long openReports) {
}
