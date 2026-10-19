import { apiFetch, pageQuery } from "./client";
import { DEFAULT_PAGE_SIZE } from "@/lib/admin/pagination";
import type { Page } from "@/lib/types";
import type { AdminCategory, AdminCounts, AdminProduct, CategoryInput, AdminUser, AdminOrder, Report, AuditEvent } from "./admin-contract";

export const adminLive = {
  productAction: (id: string, action: string, reason: string) => apiFetch(`/admin/products/${id}/${action}`, { method: "POST", body: action === "reject" ? { reason } : undefined }),
  userAction: (id: string, action: string, reason: string) => apiFetch(`/admin/users/${id}/${action}`, { method: "POST", body: action === "reactivate" ? undefined : { reason } }),
  reportAction: (id: string, status: string, note: string) => apiFetch(`/admin/reports/${id}/resolve`, { method: "POST", body: { status, note } }),
  categories: () => apiFetch<AdminCategory[]>("/admin/categories"),
  createCategory: (body: CategoryInput) => apiFetch<AdminCategory>("/admin/categories", { method: "POST", body }),
  updateCategory: (id: string, body: CategoryInput) => apiFetch<AdminCategory>(`/admin/categories/${id}`, { method: "PUT", body }),
  moveCategory: (id: string, direction: "UP" | "DOWN") => apiFetch(`/admin/categories/${id}/move`, { method: "POST", query: { direction } }),
  deactivateCategory: (id: string, replacementId: string | null) => apiFetch<AdminCategory>(`/admin/categories/${id}/deactivate`, { method: "POST", body: { replacementId } }),
  reactivateCategory: (id: string) => apiFetch<AdminCategory>(`/admin/categories/${id}/reactivate`, { method: "POST" }),
  dashboard: () => apiFetch<AdminCounts>("/admin/dashboard"),
  products: (status = "PENDING_REVIEW", page = 1, size = DEFAULT_PAGE_SIZE) => apiFetch<Page<AdminProduct>>("/admin/products", { query: { status, ...pageQuery(page, size) } }),
  users: (query: { q?: string; role?: string; status?: string; page?: number; size?: number }) => apiFetch<Page<AdminUser>>("/admin/users", { query: { ...query, ...pageQuery(query.page, query.size ?? DEFAULT_PAGE_SIZE) } }),
  orders: (status = "", page = 1, size = DEFAULT_PAGE_SIZE) => apiFetch<Page<AdminOrder>>("/admin/orders", { query: { status, ...pageQuery(page, size) } }),
  reports: (status = "OPEN", page = 1, size = DEFAULT_PAGE_SIZE) => apiFetch<Page<Report>>("/admin/reports", { query: { status, ...pageQuery(page, size) } }),
  audit: (page = 1, size = DEFAULT_PAGE_SIZE) => apiFetch<Page<AuditEvent>>("/admin/audit", { query: pageQuery(page, size) }),
};
