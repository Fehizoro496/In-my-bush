import "server-only";
import { catalogApi } from "@/lib/api/catalog";
import { CATEGORIES, REGIONS, SHOP_REVIEWS } from "@/lib/mock/catalog";
import { HOME, buildCatalog, buildProductDetail, buildSearch, buildShop, productReviews, similarProducts } from "@/lib/mock/views";
import type { CatalogFilters } from "@/lib/types";
import { USE_MOCKS, mock } from "./config";

export async function getCategories() {
  return USE_MOCKS ? mock(CATEGORIES) : catalogApi.categories();
}

export async function getRegions() {
  // No dedicated endpoint yet: regions come with the categories page in mock mode.
  return mock(REGIONS);
}

/** Home page blocks (rails, promos, nearby producers…). */
export async function getHome() {
  // TODO(api): no /home endpoint — compose from /products?sort=… and /shops when switching.
  return mock(HOME);
}

export async function getCatalog(filters: CatalogFilters) {
  return USE_MOCKS ? mock(buildCatalog(filters)) : catalogApi.products(filters);
}

export async function searchCatalog(q: string) {
  if (USE_MOCKS) return mock(buildSearch(q));
  const [products, suggestions] = await Promise.all([catalogApi.products({ q }), catalogApi.suggestions(q)]);
  return { ...buildSearch(q), products: products.products, suggestions };
}

export async function getProduct(slug: string) {
  if (USE_MOCKS) return mock(buildProductDetail(slug));
  return catalogApi.product(slug);
}

export async function getProductReviews(productId: string) {
  if (USE_MOCKS) return mock(productReviews());
  return (await catalogApi.productReviews(productId)).items;
}

export async function getSimilarProducts(slug: string) {
  return mock(similarProducts(slug));
}

export async function getShop(slug: string) {
  if (USE_MOCKS) {
    const s = buildShop(slug);
    return s ? mock({ ...s, reviews: SHOP_REVIEWS }) : null;
  }
  const [shop, products] = await Promise.all([catalogApi.shop(slug), catalogApi.shopProducts(slug)]);
  return { ...shop, products: products.items, reviews: SHOP_REVIEWS };
}
