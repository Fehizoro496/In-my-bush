import type { OrderStatus, ProductStatus, ReportStatus, ReportTargetType, Role, UserStatus } from "@/lib/types";

export interface AdminCounts {
  totalUsers: number; totalShops: number; totalProducts: number; publishedProducts: number;
  pendingProducts: number; totalOrders: number; pendingOrders: number; totalRevenue: number;
  totalCommission: number; openReports: number;
}
export interface AdminProduct {
  id: string; name: string; description: string; slug: string; price: number; unitLabel: string;
  stock: number; status: ProductStatus; rejectionReason: string | null; images: string[];
  category: { name: string }; shop: { name: string }; createdAt: string;
}
/** A category as the backoffice manages it, active or not; productCount counts every status. */
export interface AdminCategory {
  id: string; parentId: string | null; parentName: string | null; name: string; slug: string; icon: string | null;
  position: number; active: boolean; productCount: number;
}
export interface CategoryInput { name: string; slug: string; icon: string; parentId: string | null }
export interface AdminUser {
  id: string; firstName: string; lastName: string; email: string | null; phone: string;
  status: UserStatus; roles: Role[]; createdAt: string;
}
export interface AdminOrder {
  id: string; number: string; status: OrderStatus; paymentStatus: string; deliveryMode: string;
  total: number; itemCount: number; buyerName: string; shopName: string; createdAt: string;
}
export interface Report {
  id: string; reporterId: string; targetType: ReportTargetType; targetId: string; reason: string;
  details: string | null; status: ReportStatus; resolutionNote: string | null; createdAt: string;
}
export interface AuditEvent {
  id: string; actorId: string; actorName: string | null; action: string; targetType: string; targetId: string | null;
  reason: string | null; createdAt: string;
}
