import { apiFetch, pageQuery } from "./client";
import { DEFAULT_PAGE_SIZE } from "@/lib/admin/pagination";
import type { Page } from "@/lib/types";
import type {
  AdminCategory, AdminCounts, AdminProduct, AdminReportDetail, AdminShop, AdminShopDetail, AdminUserDetail, CategoryInput,
  AdminUser, AdminOrder, Report, ReportNote, AuditEvent,
} from "./admin-contract";

export type ProductFilters = { status?: string; q?: string; categoryId?: string; shopId?: string };

export const adminLive = {
  productAction: (id: string, action: string, reason: string) => apiFetch(`/admin/products/${id}/${action}`, { method: "POST", body: action === "approve" ? undefined : { reason } }),
  userAction: (id: string, action: string, reason: string) => apiFetch(`/admin/users/${id}/${action}`, { method: "POST", body: action === "reactivate" ? undefined : { reason } }),
  shopAction: (id: string, action: "suspend" | "reactivate", reason: string) => apiFetch(`/admin/shops/${id}/${action}`, { method: "POST", body: action === "suspend" ? { reason } : undefined }),
  reportAction: (id: string, status: string, note: string) => apiFetch(`/admin/reports/${id}/resolve`, { method: "POST", body: { status, note: note || undefined } }),
  reportNote: (id: string, body: string) => apiFetch<ReportNote>(`/admin/reports/${id}/notes`, { method: "POST", body: { body } }),
  categories: () => apiFetch<AdminCategory[]>("/admin/categories"),
  createCategory: (body: CategoryInput) => apiFetch<AdminCategory>("/admin/categories", { method: "POST", body }),
  updateCategory: (id: string, body: CategoryInput) => apiFetch<AdminCategory>(`/admin/categories/${id}`, { method: "PUT", body }),
  moveCategory: (id: string, direction: "UP" | "DOWN") => apiFetch(`/admin/categories/${id}/move`, { method: "POST", query: { direction } }),
  deactivateCategory: (id: string, replacementId: string | null) => apiFetch<AdminCategory>(`/admin/categories/${id}/deactivate`, { method: "POST", body: { replacementId } }),
  reactivateCategory: (id: string) => apiFetch<AdminCategory>(`/admin/categories/${id}/reactivate`, { method: "POST" }),
  dashboard: () => apiFetch<AdminCounts>("/admin/dashboard"),
  products: (filters: ProductFilters, page = 1, size = DEFAULT_PAGE_SIZE) => apiFetch<Page<AdminProduct>>("/admin/products", { query: { ...filters, ...pageQuery(page, size) } }),
  users: (query: { q?: string; role?: string; status?: string; page?: number; size?: number }) => apiFetch<Page<AdminUser>>("/admin/users", { query: { ...query, ...pageQuery(query.page, query.size ?? DEFAULT_PAGE_SIZE) } }),
  user: (id: string) => apiFetch<AdminUserDetail>(`/admin/users/${id}`),
  shops: (query: { q?: string; status?: string }, page = 1, size = DEFAULT_PAGE_SIZE) => apiFetch<Page<AdminShop>>("/admin/shops", { query: { ...query, ...pageQuery(page, size) } }),
  shop: (id: string) => apiFetch<AdminShopDetail>(`/admin/shops/${id}`),
  orders: (status = "", page = 1, size = DEFAULT_PAGE_SIZE) => apiFetch<Page<AdminOrder>>("/admin/orders", { query: { status, ...pageQuery(page, size) } }),
  reports: (query: { status?: string; type?: string }, page = 1, size = DEFAULT_PAGE_SIZE) => apiFetch<Page<Report>>("/admin/reports", { query: { ...query, ...pageQuery(page, size) } }),
  report: (id: string) => apiFetch<AdminReportDetail>(`/admin/reports/${id}`),
  audit: (page = 1, size = DEFAULT_PAGE_SIZE) => apiFetch<Page<AuditEvent>>("/admin/audit", { query: pageQuery(page, size) }),
};
