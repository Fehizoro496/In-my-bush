/** catalogue — /categories · /products · /products/{slug} · /products/{id}/reviews · /shops/{slug} · /shops/{slug}/products · /search/suggestions */
import type { Category, CatalogFilters, CatalogResult, Page, ProductDetail, ProductSummary, Review, SearchResult, ShopDetail } from "@/lib/types";
import { apiFetch, pageQuery } from "./client";

const SORTS: Record<NonNullable<CatalogFilters["tri"]>, string> = {
  pertinence: "relevance",
  "prix-asc": "price,asc",
  "prix-desc": "price,desc",
  note: "rating,desc",
  nouveautes: "createdAt,desc",
};

export const catalogApi = {
  categories: () => apiFetch<Category[]>("/categories", { next: { revalidate: 300 } }),

  products: (f: CatalogFilters, size = 12) =>
    apiFetch<CatalogResult>("/products", {
      query: {
        q: f.q,
        category: f.categorie,
        region: f.region,
        minPrice: f.minPrice,
        maxPrice: f.maxPrice,
        sort: f.tri ? SORTS[f.tri] : undefined,
        ...pageQuery(f.page, size),
      },
    }),

  product: (slug: string) => apiFetch<ProductDetail>(`/products/${encodeURIComponent(slug)}`),
  productReviews: (productId: string, page = 1) =>
    apiFetch<Page<Review>>(`/products/${productId}/reviews`, { query: pageQuery(page, 10) }),

  shop: (slug: string) => apiFetch<ShopDetail>(`/shops/${encodeURIComponent(slug)}`),
  shopProducts: (slug: string, page = 1) =>
    apiFetch<Page<ProductSummary>>(`/shops/${encodeURIComponent(slug)}/products`, { query: pageQuery(page, 24) }),

  suggestions: (q: string) => apiFetch<SearchResult["suggestions"]>("/search/suggestions", { query: { q } }),
};
