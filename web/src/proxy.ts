/**
 * Route protection (Next.js 16 "proxy", formerly middleware.ts).
 *
 *  /compte/*                     → session required
 *  /vendre/ouvrir-ma-boutique    → session required
 *  /vendre/*                     → role SELLER (otherwise → /vendre/ouvrir-ma-boutique)
 *  /admin/*                      → role ADMIN (otherwise → /)
 *
 * STUB: the session is the `imb_session` cookie holding the API access token
 * (JWT). Roles are read from its payload WITHOUT verifying the signature —
 * this only decides what to render; every API call is authorised by the API
 * itself. Replace with real verification (jose + public key) when the auth
 * flow is wired.
 *
 * Dev: NEXT_PUBLIC_AUTH_BYPASS=true lets every page render without a session.
 */
import { NextResponse, type NextRequest } from "next/server";

const SESSION_COOKIE = "imb_session";

function readRoles(token: string): string[] {
  try {
    const payload = token.split(".")[1];
    if (!payload) return [];
    const json = JSON.parse(atob(payload.replace(/-/g, "+").replace(/_/g, "/"))) as { roles?: string[]; exp?: number };
    if (json.exp && json.exp * 1000 < Date.now()) return [];
    return Array.isArray(json.roles) ? json.roles : [];
  } catch {
    return [];
  }
}

export function proxy(request: NextRequest) {
  if (process.env.NEXT_PUBLIC_AUTH_BYPASS === "true") return NextResponse.next();

  const { pathname, search } = request.nextUrl;
  const token = request.cookies.get(SESSION_COOKIE)?.value;
  const roles = token ? readRoles(token) : [];

  if (!token || roles.length === 0) {
    const url = new URL("/connexion", request.url);
    url.searchParams.set("next", `${pathname}${search}`);
    return NextResponse.redirect(url);
  }
  if (pathname.startsWith("/admin") && !roles.includes("ADMIN")) {
    return NextResponse.redirect(new URL("/", request.url));
  }
  if (pathname.startsWith("/vendre") && !pathname.startsWith("/vendre/ouvrir-ma-boutique") && !roles.includes("SELLER")) {
    return NextResponse.redirect(new URL("/vendre/ouvrir-ma-boutique", request.url));
  }
  return NextResponse.next();
}

export const config = {
  matcher: ["/compte/:path*", "/vendre/:path*", "/admin/:path*"],
};
