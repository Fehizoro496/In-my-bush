import "server-only";
import { sellerApi } from "@/lib/api/seller";
import { buildShop } from "@/lib/mock/views";
import {
  EDIT_PRODUCT,
  MONTHLY_SALES,
  REVIEWS_BY_PRODUCT,
  REVIEW_BREAKDOWN,
  SALES,
  SELLER_DASHBOARD,
  SELLER_ORDERS,
  SELLER_ORDER_DETAIL,
  SELLER_PRODUCTS,
  SELLER_REVIEWS,
} from "@/lib/mock/seller";
import { USE_MOCKS, mock } from "./config";

export async function getSellerDashboard() {
  return USE_MOCKS ? mock(SELLER_DASHBOARD) : sellerApi.dashboard();
}

export async function getSellerProducts() {
  return USE_MOCKS ? mock(SELLER_PRODUCTS) : (await sellerApi.products()).items;
}

export async function getSellerProduct(id: string) {
  if (USE_MOCKS) {
    const row = SELLER_PRODUCTS.find((p) => p.id === id);
    if (!row) return null;
    return mock({ ...EDIT_PRODUCT, id: row.id, name: row.name, visual: row.visual, stock: String(row.stock), threshold: String(row.lowStockThreshold) });
  }
  const p = await sellerApi.getProduct(id);
  return { ...EDIT_PRODUCT, id: p.id, name: p.name, visual: p.visual, stock: String(p.stock), threshold: String(p.lowStockThreshold), description: p.description };
}

export async function getSellerOrders() {
  return USE_MOCKS ? mock(SELLER_ORDERS) : (await sellerApi.orders()).items;
}

export async function getSellerOrder(id: string) {
  if (USE_MOCKS) {
    const card = SELLER_ORDERS.find((o) => o.id === id || o.number === id);
    if (!card) return null;
    return mock(
      card.id === SELLER_ORDER_DETAIL.id
        ? SELLER_ORDER_DETAIL
        : { ...SELLER_ORDER_DETAIL, id: card.id, number: card.number, status: card.status, client: { ...SELLER_ORDER_DETAIL.client, ...card.client } },
    );
  }
  return sellerApi.order(id);
}

export async function getSalesHistory() {
  if (USE_MOCKS) return mock({ monthly: MONTHLY_SALES, rows: SALES });
  const page = await sellerApi.sales("12m");
  return { monthly: MONTHLY_SALES, rows: page.items };
}

export async function getSellerReviews() {
  if (USE_MOCKS) return mock({ reviews: SELLER_REVIEWS, breakdown: REVIEW_BREAKDOWN, byProduct: REVIEWS_BY_PRODUCT });
  const page = await sellerApi.reviews();
  return { reviews: page.items, breakdown: REVIEW_BREAKDOWN, byProduct: REVIEWS_BY_PRODUCT };
}

export async function getMyShop() {
  if (USE_MOCKS) return mock(buildShop("le-jardin-de-hery")!);
  return { ...(await sellerApi.getShop()), products: [] };
}
