"use server";
import { redirect } from "next/navigation";
import { apiFetch, ApiError } from "@/lib/api/client";
import { API_URL, clearSession, readSession, saveSession } from "./session";
import { loginDestination, type SessionTokens } from "./session-core";
import type { User } from "@/lib/types";
import { ROUTES } from "@/lib/routing/routes";

export async function loginAction(_state: { error: string }, form: FormData) {
  let destination: string;
  try {
    const result = await apiFetch<SessionTokens & { user: User }>("/auth/login", {
      method: "POST", token: null,
      body: { identifier: String(form.get("identifier") ?? ""), password: String(form.get("password") ?? "") },
    });
    await saveSession(result);
    destination = loginDestination(String(form.get("next") ?? ""), result.user.roles.includes("ADMIN"));
  } catch (error) {
    return { error: error instanceof ApiError ? error.message : "Connexion indisponible. Veuillez réessayer." };
  }
  redirect(destination);
}
export async function logoutAction() {
  const session = await readSession();
  try {
    if (session) await fetch(`${API_URL}/auth/logout`, {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken: session.refreshToken }), cache: "no-store", signal: AbortSignal.timeout(10000),
    });
  } catch { /* The local session is always removed, including when the API is unavailable. */ }
  finally { await clearSession(); }
  redirect(ROUTES.login);
}
