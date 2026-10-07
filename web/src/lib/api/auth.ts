/** auth — POST /auth/register/otp · /auth/register · /auth/login · /auth/refresh · /auth/logout */
import type { AuthTokens, User } from "@/lib/types";
import { apiFetch } from "./client";

export interface RegisterInput {
  firstName: string;
  lastName: string;
  phone: string;
  email?: string;
  password: string;
  /** 6-digit code texted by `requestRegistrationOtp`. */
  otpCode: string;
}

export const authApi = {
  /** Sign-up, step 1: texts a 6-digit code to the phone number. */
  requestRegistrationOtp: (phone: string) =>
    apiFetch<{ phone: string; expiresAt: string }>("/auth/register/otp", { method: "POST", body: { phone }, token: null }),
  register: (input: RegisterInput) =>
    apiFetch<{ user: User; tokens: AuthTokens }>("/auth/register", { method: "POST", body: input, token: null }),
  login: (identifier: string, password: string) =>
    apiFetch<{ user: User; tokens: AuthTokens }>("/auth/login", { method: "POST", body: { identifier, password }, token: null }),
  refresh: (refreshToken: string) =>
    apiFetch<AuthTokens>("/auth/refresh", { method: "POST", body: { refreshToken }, token: null }),
  logout: (refreshToken: string) => apiFetch<void>("/auth/logout", { method: "POST", body: { refreshToken } }),
};
