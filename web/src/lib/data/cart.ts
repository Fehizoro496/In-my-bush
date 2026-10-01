import "server-only";
import { cartApi } from "@/lib/api/cart";
import { CART, CART_SUGGESTIONS, CHECKOUT, CONFIRMATION } from "@/lib/mock/cart";
import { USE_MOCKS, mock } from "./config";

export async function getCart() {
  return USE_MOCKS ? mock(CART) : cartApi.get();
}

export async function getCartSuggestions() {
  return mock(CART_SUGGESTIONS);
}

export async function getCheckoutDraft() {
  // TODO(api): computed client-side from GET /me/cart + GET /me/addresses when switching.
  return mock(CHECKOUT);
}

export async function getConfirmation() {
  return mock(CONFIRMATION);
}
