/** panier — GET /me/cart · POST /me/cart/items · PATCH/DELETE /me/cart/items/{id} · DELETE /me/cart */
import type { Cart } from "@/lib/types";
import { apiFetch } from "./client";

export const cartApi = {
  get: () => apiFetch<Cart>("/me/cart"),
  addItem: (productId: string, quantity = 1) =>
    apiFetch<Cart>("/me/cart/items", { method: "POST", body: { productId, quantity } }),
  updateItem: (itemId: string, quantity: number) =>
    apiFetch<Cart>(`/me/cart/items/${itemId}`, { method: "PATCH", body: { quantity } }),
  removeItem: (itemId: string) => apiFetch<Cart>(`/me/cart/items/${itemId}`, { method: "DELETE" }),
  clear: () => apiFetch<void>("/me/cart", { method: "DELETE" }),
};
