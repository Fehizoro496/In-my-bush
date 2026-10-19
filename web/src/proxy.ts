import { NextResponse, type NextRequest } from "next/server";
import { ROUTES } from "@/lib/routing/routes";

/** Presence gate only. The API and server layouts verify identity and roles. */
export function proxy(request: NextRequest) {
  const headers = new Headers(request.headers);
  headers.set("x-imb-path", request.nextUrl.pathname + request.nextUrl.search);
  if (!request.cookies.get("imb_session")) {
    const url = new URL(ROUTES.login, request.url);
    url.searchParams.set("next", request.nextUrl.pathname + request.nextUrl.search);
    return NextResponse.redirect(url);
  }
  return NextResponse.next({ request: { headers } });
}
export const config = { matcher: ["/compte/:path*", "/vendre/:path*", "/admin/:path*"] };

