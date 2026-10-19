import { createCipheriv, createDecipheriv, createHash, randomBytes } from "node:crypto";
import { ROUTES, isRoute } from "../routing/routes";

export const SESSION_COOKIE = "imb_session";
export interface SessionTokens {
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresAt: string;
  refreshTokenExpiresAt: string;
}

function key() {
  const secret = process.env.SESSION_SECRET;
  if (!secret || secret.length < 32) throw new Error("SESSION_SECRET doit contenir au moins 32 caractères.");
  return createHash("sha256").update(secret).digest();
}
export function sealSession(tokens: SessionTokens): string {
  const iv = randomBytes(12);
  const cipher = createCipheriv("aes-256-gcm", key(), iv);
  const body = Buffer.concat([cipher.update(JSON.stringify(tokens), "utf8"), cipher.final()]);
  return Buffer.concat([iv, cipher.getAuthTag(), body]).toString("base64url");
}
export function openSession(value?: string): SessionTokens | null {
  if (!value) return null;
  const secret = key();
  try {
    const data = Buffer.from(value, "base64url");
    const decipher = createDecipheriv("aes-256-gcm", secret, data.subarray(0, 12));
    decipher.setAuthTag(data.subarray(12, 28));
    const tokens = JSON.parse(Buffer.concat([decipher.update(data.subarray(28)), decipher.final()]).toString()) as SessionTokens;
    if (!tokens.accessToken || !tokens.refreshToken || !Number.isFinite(Date.parse(tokens.accessTokenExpiresAt)) ||
        !(Date.parse(tokens.refreshTokenExpiresAt) > Date.now())) return null;
    return tokens;
  } catch { return null; }
}
export function safeNext(value?: string | null, fallback: string = ROUTES.admin): string {
  if (!value || !value.startsWith("/") || value.startsWith("//") || /[\\\r\n]/.test(value)) return fallback;
  const path = new URL(value, "https://local.invalid").pathname;
  if (path.startsWith("/session/") || path === ROUTES.login) return fallback;
  return value;
}
/**
 * Where to go after signing in. An administrator always lands in the backoffice: on the page
 * asked for when it is a backoffice page, on its dashboard otherwise. Other users return to
 * the page they came from, or open their account.
 */
export function loginDestination(next: string | null | undefined, isAdmin: boolean): string {
  if (!isAdmin) return safeNext(next, ROUTES.account);
  const target = safeNext(next, ROUTES.admin);
  return isRoute(new URL(target, "https://local.invalid").pathname, ROUTES.admin) ? target : ROUTES.admin;
}

/** Route handlers that clear or renew the session cookie, then go to `next`. */
export const sessionEndPath = (next: string) => `/session/end?next=${encodeURIComponent(next)}`;
export const sessionRenewPath = (next: string) => `/session/renew?next=${encodeURIComponent(next)}`;

/** One persistent Node process; use a shared coordinator before scaling to multiple workers. */
const globalSessions = globalThis as typeof globalThis & {
  imbRotations?: Map<string, { until: number; promise: Promise<SessionTokens> }>;
};
const rotations = globalSessions.imbRotations ??= new Map();
export function rotateOnce(tokens: SessionTokens, rotate: () => Promise<SessionTokens>): Promise<SessionTokens> {
  const now = Date.now();
  for (const [id, entry] of rotations) if (entry.until < now) rotations.delete(id);
  const id = createHash("sha256").update(tokens.refreshToken).digest("hex");
  const previous = rotations.get(id);
  if (previous) return previous.promise;
  const entry = { until: Infinity, promise: Promise.resolve().then(rotate) };
  rotations.set(id, entry);
  void entry.promise.then(() => { entry.until = Date.now() + 10000; }, () => { entry.until = Date.now() + 10000; });
  return entry.promise;
}

