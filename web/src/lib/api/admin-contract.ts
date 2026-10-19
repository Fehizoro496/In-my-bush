import type { OrderStatus, ProductStatus, ReportStatus, ReportTargetType, Role, ShopStatus, UserStatus } from "@/lib/types";

export interface AdminCounts {
  totalUsers: number; totalShops: number; totalProducts: number; publishedProducts: number;
  pendingProducts: number; totalOrders: number; pendingOrders: number; totalRevenue: number;
  totalCommission: number; openReports: number;
}
export interface AdminProduct {
  id: string; name: string; description: string; slug: string; price: number; unitLabel: string;
  stock: number; status: ProductStatus; rejectionReason: string | null; images: string[];
  category: { name: string }; shop: { id: string; name: string }; createdAt: string;
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
/** Backoffice sheet of an account; history lists the decisions taken on it, newest first. */
export interface AdminUserDetail {
  user: AdminUser; shop: { id: string; name: string; slug: string; status: ShopStatus } | null;
  orderCount: number; reportCount: number; history: AuditEvent[];
}
/** A shop as the backoffice manages it; productCounts has every product status. */
export interface AdminShop {
  id: string; name: string; slug: string; description: string | null; city: string | null; region: string | null;
  status: ShopStatus; ownerId: string; ownerName: string; ownerPhone: string; ownerStatus: UserStatus;
  productCounts: Record<ProductStatus, number>; ratingAvg: number; ratingCount: number; createdAt: string;
}
export interface AdminShopDetail { shop: AdminShop; orderCount: number; reportCount: number; history: AuditEvent[] }
export interface AdminOrder {
  id: string; number: string; status: OrderStatus; paymentStatus: string; deliveryMode: string;
  total: number; itemCount: number; buyerName: string; shopName: string; createdAt: string;
}
export interface Report {
  id: string; reporterId: string; targetType: ReportTargetType; targetId: string; reason: string;
  details: string | null; status: ReportStatus; resolutionNote: string | null; createdAt: string;
}
/** The reported content; found is false once it has been deleted. */
export interface ReportTarget {
  found: boolean; title: string | null; excerpt: string | null; status: string | null; productSlug: string | null;
  userId: string | null; userName: string | null; shopId: string | null; shopName: string | null;
}
export interface ReportNote { id: string; authorId: string; authorName: string | null; body: string; createdAt: string }
export interface AdminReportDetail {
  report: Report & { resolvedAt: string | null }; reporterName: string | null; resolvedByName: string | null;
  target: ReportTarget; targetReportCount: number; notes: ReportNote[]; history: AuditEvent[];
}
export interface AuditEvent {
  id: string; actorId: string; actorName: string | null; action: string; targetType: string; targetId: string | null;
  reason: string | null; createdAt: string;
}
