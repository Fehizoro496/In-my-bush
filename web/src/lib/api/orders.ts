/** commandes (acheteur) — POST /checkouts · /me/orders · /me/orders/{id}[/cancel|/confirm-delivery|/reviews] · GET /me/reviews */
import type { BuyerOrderDetail, BuyerOrderSummary, Checkout, DeliveryMode, Page, PaymentMethod, Review } from "@/lib/types";
import { apiFetch, pageQuery } from "./client";

export interface CheckoutInput {
  addressId: string;
  /** Delivery mode chosen per shop. */
  deliveryModes: Record<string, DeliveryMode>;
  payment: { method: PaymentMethod; phone?: string };
  promoCode?: string;
}

export const ordersApi = {
  checkout: (input: CheckoutInput) => apiFetch<Checkout>("/checkouts", { method: "POST", body: input }),
  list: (params: { status?: string; page?: number } = {}) =>
    apiFetch<Page<BuyerOrderSummary>>("/me/orders", { query: { status: params.status, ...pageQuery(params.page, 10) } }),
  get: (id: string) => apiFetch<BuyerOrderDetail>(`/me/orders/${id}`),
  cancel: (id: string, reason?: string) => apiFetch<BuyerOrderDetail>(`/me/orders/${id}/cancel`, { method: "POST", body: { reason } }),
  confirmDelivery: (id: string) => apiFetch<BuyerOrderDetail>(`/me/orders/${id}/confirm-delivery`, { method: "POST" }),
  review: (id: string, input: { productId: string; rating: number; comment: string }) =>
    apiFetch<Review>(`/me/orders/${id}/reviews`, { method: "POST", body: input }),
  myReviews: () => apiFetch<Page<Review>>("/me/reviews"),
};
