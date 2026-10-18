import "server-only";
import { catalogApi } from "../api/catalog";
import { CATEGORIES, REGIONS, SHOP_REVIEWS } from "../mock/catalog";
import { HOME, buildCatalog, buildProductDetail, buildSearch, buildShop, productReviews, similarProducts } from "../mock/views";
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
export async function getHome(): Promise<typeof HOME> {
  if (USE_MOCKS) return mock(HOME);
  const [reco, news, popular] = await Promise.all([
    catalogApi.homeProducts("rating"),
    catalogApi.homeProducts("newest"),
    catalogApi.homeProducts("popular"),
  ]);
  const products = [...new Map([...reco, ...news, ...popular].map((p) => [p.id, p])).values()];
  return {
    rails: { reco, news, popular },
    tabletReco: reco,
    promos: products.filter((p) => p.compareAtPrice !== null && p.compareAtPrice > p.price),
    promoEndsIn: "",
    // These blocks need dedicated API data before they can be displayed live.
    trust: [], mapPins: [], nearby: [], popularShops: [],
    sellSteps: ["Nommez votre boutique", "Vérifiez votre identité", "Publiez votre premier produit"],
  };
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
