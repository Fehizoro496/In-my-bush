/** favoris — GET /me/favorites · PUT/DELETE /me/favorites/{productId} */
import type { Page, ProductSummary } from "@/lib/types";
import { apiFetch, pageQuery } from "./client";

export const favoritesApi = {
  list: (page = 1) => apiFetch<Page<ProductSummary>>("/me/favorites", { query: pageQuery(page, 24) }),
  add: (productId: string) => apiFetch<void>(`/me/favorites/${productId}`, { method: "PUT" }),
  remove: (productId: string) => apiFetch<void>(`/me/favorites/${productId}`, { method: "DELETE" }),
};
