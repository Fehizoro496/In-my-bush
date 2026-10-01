/** me — GET/PATCH /me · /me/addresses[/{id}] · /me/payout-methods[/{id}] */
import type { Address, PayoutMethod, User } from "@/lib/types";
import { apiFetch } from "./client";

export const meApi = {
  get: () => apiFetch<User>("/me"),
  update: (patch: Partial<Pick<User, "firstName" | "lastName" | "email" | "phone" | "avatarUrl">>) =>
    apiFetch<User>("/me", { method: "PATCH", body: patch }),

  listAddresses: () => apiFetch<Address[]>("/me/addresses"),
  createAddress: (input: Omit<Address, "id">) => apiFetch<Address>("/me/addresses", { method: "POST", body: input }),
  updateAddress: (id: string, patch: Partial<Omit<Address, "id">>) =>
    apiFetch<Address>(`/me/addresses/${id}`, { method: "PATCH", body: patch }),
  deleteAddress: (id: string) => apiFetch<void>(`/me/addresses/${id}`, { method: "DELETE" }),

  listPayoutMethods: () => apiFetch<PayoutMethod[]>("/me/payout-methods"),
  createPayoutMethod: (input: { method: PayoutMethod["method"]; phone: string; isDefault?: boolean }) =>
    apiFetch<PayoutMethod>("/me/payout-methods", { method: "POST", body: input }),
  deletePayoutMethod: (id: string) => apiFetch<void>(`/me/payout-methods/${id}`, { method: "DELETE" }),
};
