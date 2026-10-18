import "server-only";
import { cookies } from "next/headers";
import { openSession, rotateOnce, sealSession, SESSION_COOKIE, type SessionTokens } from "./session-core";

export const API_URL = process.env.API_URL ?? process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/api/v1";
export const readSession = async () => openSession((await cookies()).get(SESSION_COOKIE)?.value);
export async function saveSession(tokens: SessionTokens) {
  const { accessToken, refreshToken, accessTokenExpiresAt, refreshTokenExpiresAt } = tokens;
  (await cookies()).set(SESSION_COOKIE, sealSession({ accessToken, refreshToken, accessTokenExpiresAt, refreshTokenExpiresAt }), {
    httpOnly: true, secure: process.env.NODE_ENV === "production", sameSite: "lax", path: "/",
    expires: new Date(tokens.refreshTokenExpiresAt),
  });
}
export async function clearSession() { (await cookies()).delete(SESSION_COOKIE); }
export function renewSession(tokens: SessionTokens) {
  return rotateOnce(tokens, async () => {
    const response = await fetch(`${API_URL}/auth/refresh`, {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken: tokens.refreshToken }), cache: "no-store", signal: AbortSignal.timeout(15000),
    });
    if (!response.ok) throw new Error("Session expirée. Veuillez vous reconnecter.");
    const result = await response.json() as SessionTokens;
    if (!result.accessToken || !result.refreshToken || !Number.isFinite(Date.parse(result.accessTokenExpiresAt)) ||
        !(Date.parse(result.refreshTokenExpiresAt) > Date.now())) throw new Error("Session invalide.");
    return result;
  });
}

