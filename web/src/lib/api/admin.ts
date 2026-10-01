/** admin — /admin/dashboard · /admin/products · /admin/users · /admin/orders · /admin/transactions · /admin/reports · /admin/settings */
import type {
  AdminDashboard,
  AdminOrderRow,
  AdminProductRow,
  AdminReport,
  AdminUserRow,
  Page,
  ProductStatus,
  ReportStatus,
} from "@/lib/types";
import { apiFetch, pageQuery } from "./client";

export const adminApi = {
  dashboard: (period = "30d") => apiFetch<AdminDashboard>("/admin/dashboard", { query: { period } }),

  products: (status: ProductStatus = "PENDING_REVIEW", page = 1) =>
    apiFetch<Page<AdminProductRow>>("/admin/products", { query: { status, ...pageQuery(page, 25) } }),
  approveProduct: (id: string) => apiFetch<void>(`/admin/products/${id}/approve`, { method: "POST" }),
  rejectProduct: (id: string, reason: string, message?: string) =>
    apiFetch<void>(`/admin/products/${id}/reject`, { method: "POST", body: { reason, message } }),

  users: (params: { role?: string; status?: string; q?: string; page?: number } = {}) =>
    apiFetch<Page<AdminUserRow>>("/admin/users", {
      query: { role: params.role, status: params.status, q: params.q, ...pageQuery(params.page, 25) },
    }),
  userAction: (id: string, action: "suspend" | "ban" | "reactivate", reason?: string) =>
    apiFetch<void>(`/admin/users/${id}/${action}`, { method: "POST", body: { reason } }),

  orders: (params: { status?: string; page?: number } = {}) =>
    apiFetch<Page<AdminOrderRow>>("/admin/orders", { query: { status: params.status, ...pageQuery(params.page, 25) } }),
  transactions: (page = 1) => apiFetch<Page<AdminOrderRow>>("/admin/transactions", { query: pageQuery(page, 25) }),

  reports: (params: { type?: string; status?: ReportStatus } = {}) =>
    apiFetch<Page<AdminReport>>("/admin/reports", { query: params }),
  updateReport: (id: string, patch: { status: ReportStatus; note?: string }) =>
    apiFetch<AdminReport>(`/admin/reports/${id}`, { method: "PATCH", body: patch }),

  settings: () => apiFetch<Record<string, string>>("/admin/settings"),
  updateSettings: (patch: Record<string, string>) => apiFetch<Record<string, string>>("/admin/settings", { method: "PATCH", body: patch }),
};
