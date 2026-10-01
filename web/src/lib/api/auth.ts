/** auth — POST /auth/register · /auth/login · /auth/refresh · /auth/logout · /auth/otp/request · /auth/otp/verify */
import type { AuthTokens, User } from "@/lib/types";
import { apiFetch } from "./client";

export interface RegisterInput {
  firstName: string;
  lastName: string;
  phone: string;
  email?: string;
  password: string;
}

export const authApi = {
  register: (input: RegisterInput) =>
    apiFetch<{ user: User; tokens: AuthTokens }>("/auth/register", { method: "POST", body: input, token: null }),
  login: (identifier: string, password: string) =>
    apiFetch<{ user: User; tokens: AuthTokens }>("/auth/login", { method: "POST", body: { identifier, password }, token: null }),
  refresh: (refreshToken: string) =>
    apiFetch<AuthTokens>("/auth/refresh", { method: "POST", body: { refreshToken }, token: null }),
  logout: (refreshToken: string) => apiFetch<void>("/auth/logout", { method: "POST", body: { refreshToken } }),
  requestOtp: (phone: string) => apiFetch<void>("/auth/otp/request", { method: "POST", body: { phone }, token: null }),
  verifyOtp: (phone: string, code: string) =>
    apiFetch<{ user: User; tokens: AuthTokens }>("/auth/otp/verify", { method: "POST", body: { phone, code }, token: null }),
};
