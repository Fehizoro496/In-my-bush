/** vendeur — /seller/shop · /seller/dashboard · /seller/products · /seller/orders · /seller/sales · /seller/payouts · /seller/reviews */
import type {
  Page,
  Payout,
  ProductStatus,
  Review,
  SaleRow,
  SellerDashboard,
  SellerOrderCard,
  SellerOrderDetail,
  SellerProductRow,
  ShopDetail,
} from "@/lib/types";
import { apiFetch, pageQuery } from "./client";

export type SellerOrderAction = "accept" | "refuse" | "prepare" | "ship" | "deliver";

export interface ProductInput {
  name: string;
  categoryId: string;
  description: string;
  price: number;
  compareAtPrice?: number | null;
  unit: string;
  unitLabel?: string;
  stock: number;
  lowStockThreshold: number;
  originRegion: string;
  imageUrls: string[];
}

export const sellerApi = {
  openShop: (input: { name: string; region: string; city: string; description: string; phone: string }) =>
    apiFetch<ShopDetail>("/seller/shop", { method: "POST", body: input }),
  getShop: () => apiFetch<ShopDetail>("/seller/shop"),
  updateShop: (patch: Partial<ShopDetail>) => apiFetch<ShopDetail>("/seller/shop", { method: "PATCH", body: patch }),

  dashboard: (period: "7d" | "30d" | "12m" = "30d") => apiFetch<SellerDashboard>("/seller/dashboard", { query: { period } }),

  products: (params: { status?: ProductStatus; q?: string; page?: number } = {}) =>
    apiFetch<Page<SellerProductRow>>("/seller/products", { query: { status: params.status, q: params.q, ...pageQuery(params.page, 20) } }),
  createProduct: (input: ProductInput) => apiFetch<SellerProductRow>("/seller/products", { method: "POST", body: input }),
  getProduct: (id: string) => apiFetch<SellerProductRow & ProductInput>(`/seller/products/${id}`),
  updateProduct: (id: string, patch: Partial<ProductInput> & { visible?: boolean }) =>
    apiFetch<SellerProductRow>(`/seller/products/${id}`, { method: "PATCH", body: patch }),
  deleteProduct: (id: string) => apiFetch<void>(`/seller/products/${id}`, { method: "DELETE" }),
  submitProduct: (id: string) => apiFetch<SellerProductRow>(`/seller/products/${id}/submit`, { method: "POST" }),
  updateStock: (id: string, stock: number) =>
    apiFetch<SellerProductRow>(`/seller/products/${id}/stock`, { method: "PATCH", body: { stock } }),

  orders: (params: { status?: string; page?: number } = {}) =>
    apiFetch<Page<SellerOrderCard>>("/seller/orders", { query: { status: params.status, ...pageQuery(params.page, 50) } }),
  order: (id: string) => apiFetch<SellerOrderDetail>(`/seller/orders/${id}`),
  orderAction: (id: string, action: SellerOrderAction, body?: { reason?: string }) =>
    apiFetch<SellerOrderDetail>(`/seller/orders/${id}/${action}`, { method: "POST", body }),

  sales: (period: string, page = 1) => apiFetch<Page<SaleRow>>("/seller/sales", { query: { period, ...pageQuery(page, 20) } }),
  payouts: () => apiFetch<Page<Payout>>("/seller/payouts"),
  reviews: (params: { filter?: string; page?: number } = {}) =>
    apiFetch<Page<Review>>("/seller/reviews", { query: { filter: params.filter, ...pageQuery(params.page, 20) } }),
  replyToReview: (id: string, reply: string) =>
    apiFetch<Review>(`/seller/reviews/${id}/reply`, { method: "POST", body: { reply } }),
};
