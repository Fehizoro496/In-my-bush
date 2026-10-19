import { beforeEach, afterEach, describe, expect, it, vi } from "vitest";
import { loginDestination, openSession, rotateOnce, safeNext, sealSession, type SessionTokens } from "./session-core";
import { ROUTES, withQuery } from "../routing/routes";

const tokens = (): SessionTokens => ({ accessToken: "access", refreshToken: crypto.randomUUID(),
  accessTokenExpiresAt: new Date(Date.now() + 900000).toISOString(), refreshTokenExpiresAt: new Date(Date.now() + 86400000).toISOString() });
beforeEach(() => vi.stubEnv("SESSION_SECRET", "test-secret-at-least-thirty-two-characters"));
afterEach(() => vi.unstubAllEnvs());
describe("destination after signing in", () => {
  it("always sends an administrator to the backoffice", () => {
    expect(loginDestination("", true)).toBe(ROUTES.admin);
    expect(loginDestination(null, true)).toBe(ROUTES.admin);
    expect(loginDestination(ROUTES.account, true)).toBe(ROUTES.admin);
    expect(loginDestination(ROUTES.home, true)).toBe(ROUTES.admin);
    expect(loginDestination("https://evil.test", true)).toBe(ROUTES.admin);
  });
  it("keeps the backoffice page an administrator asked for", () => {
    expect(loginDestination(withQuery(ROUTES.adminUsers, { q: "Hery" }), true)).toBe(withQuery(ROUTES.adminUsers, { q: "Hery" }));
    expect(loginDestination(ROUTES.adminAudit, true)).toBe(ROUTES.adminAudit);
  });
  it("returns other users to the page they came from, or to their account", () => {
    expect(loginDestination(ROUTES.sellerOrders, false)).toBe(ROUTES.sellerOrders);
    expect(loginDestination("", false)).toBe(ROUTES.account);
    expect(loginDestination("//evil.test", false)).toBe(ROUTES.account);
  });
});

describe("encrypted sessions", () => {
  it("roundtrips without exposing tokens", () => {
    const value = tokens(); const sealed = sealSession(value);
    expect(sealed).not.toContain(value.refreshToken); expect(openSession(sealed)).toEqual(value);
  });
  it("rejects a tampered or expired cookie", () => {
    const data = Buffer.from(sealSession(tokens()), "base64url"); data[30] ^= 1;
    expect(openSession(data.toString("base64url"))).toBeNull();
    expect(openSession(sealSession({...tokens(), refreshTokenExpiresAt: new Date(0).toISOString()}))).toBeNull();
  });
  it("fails closed without a session secret", () => {
    vi.stubEnv("SESSION_SECRET", ""); expect(() => sealSession(tokens())).toThrow("SESSION_SECRET");
  });
  it("coalesces concurrent and briefly delayed refresh requests", async () => {
    const old = tokens(); const next = tokens(); const refresh = vi.fn(async () => next);
    const results = await Promise.all([rotateOnce(old, refresh), rotateOnce(old, refresh)]);
    expect(results).toEqual([next, next]); expect(await rotateOnce(old, refresh)).toEqual(next); expect(refresh).toHaveBeenCalledTimes(1);
  });
  it("coalesces a failed refresh without retrying in a loop", async () => {
    const old = tokens(); const refresh = vi.fn(async () => { throw new Error("expired"); });
    await expect(rotateOnce(old, refresh)).rejects.toThrow("expired");
    await expect(rotateOnce(old, refresh)).rejects.toThrow("expired"); expect(refresh).toHaveBeenCalledTimes(1);
  });
  it("allows internal destinations and rejects external redirects and loops", () => {
    expect(safeNext(withQuery(ROUTES.adminUsers, { q: "Hery" }))).toBe(withQuery(ROUTES.adminUsers, { q: "Hery" }));
    for (const invalid of ["https://evil.test", "//evil.test", "/\\evil.test", "/session/renew", ROUTES.login]) {
      expect(safeNext(invalid)).toBe(ROUTES.admin);
    }
  });
});
