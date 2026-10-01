import "server-only";
import { favoritesApi } from "@/lib/api/favorites";
import { meApi } from "@/lib/api/me";
import { messagesApi } from "@/lib/api/messages";
import { notificationsApi } from "@/lib/api/notifications";
import { ordersApi } from "@/lib/api/orders";
import {
  ADDRESSES,
  BUYER_ORDERS,
  BUYER_ORDER_DETAIL,
  CONVERSATIONS,
  COUNTERS,
  CURRENT_USER,
  FAVORITE_PRODUCTS,
  FOLLOWED_SHOPS,
  MESSAGES,
  NOTIFICATIONS,
  PAYMENT_METHODS,
  PAYOUTS,
  PUBLISHED_REVIEWS,
  REVIEWS_TO_LEAVE,
  REVIEW_TAGS,
} from "@/lib/mock/account";
import { USE_MOCKS, mock } from "./config";

export async function getCurrentUser() {
  return USE_MOCKS ? mock(CURRENT_USER) : meApi.get();
}

export async function getCounters() {
  if (USE_MOCKS) return mock(COUNTERS);
  const { count } = await notificationsApi.unreadCount();
  return { ...COUNTERS, unreadNotifications: count };
}

export async function getMyOrders() {
  return USE_MOCKS ? mock(BUYER_ORDERS) : (await ordersApi.list()).items;
}

export async function getMyOrder(id: string) {
  if (USE_MOCKS) {
    const summary = BUYER_ORDERS.find((o) => o.id === id || o.number === id);
    if (!summary) return null;
    return mock(summary.id === BUYER_ORDER_DETAIL.id ? BUYER_ORDER_DETAIL : { ...BUYER_ORDER_DETAIL, ...summary });
  }
  return ordersApi.get(id);
}

export async function getFavorites() {
  if (USE_MOCKS) return mock({ products: FAVORITE_PRODUCTS, shops: FOLLOWED_SHOPS });
  const page = await favoritesApi.list();
  return { products: page.items, shops: FOLLOWED_SHOPS };
}

export async function getConversations() {
  if (USE_MOCKS) return mock({ conversations: CONVERSATIONS, messages: MESSAGES });
  const [buy, sell] = await Promise.all([messagesApi.conversations("PURCHASE"), messagesApi.conversations("SALE")]);
  const conversations = [...buy.items, ...sell.items];
  const first = conversations[0];
  const messages = first ? { [first.id]: (await messagesApi.messages(first.id)).items } : {};
  return { conversations, messages };
}

export async function getNotifications() {
  return USE_MOCKS ? mock(NOTIFICATIONS) : (await notificationsApi.list()).items;
}

export async function getMyReviews() {
  // TODO(api): GET /me/reviews returns published reviews; "to leave" comes from delivered orders.
  return mock({ toLeave: REVIEWS_TO_LEAVE, published: PUBLISHED_REVIEWS, tags: REVIEW_TAGS });
}

export async function getAddresses() {
  return USE_MOCKS ? mock(ADDRESSES) : meApi.listAddresses();
}

export async function getPaymentSettings() {
  // TODO(api): payout summary comes from /seller/payouts; buyer methods are stored client-side by the PSP.
  return mock({ methods: PAYMENT_METHODS, payouts: PAYOUTS, nextPayout: { label: "Prochain versement · jeudi 2 oct.", amount: "[MONTANT]", target: "MVola •• 12 · chaque jeudi" } });
}
