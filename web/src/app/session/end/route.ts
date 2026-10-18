import { NextRequest, NextResponse } from "next/server";
import { clearSession } from "@/lib/auth/session";
import { safeNext } from "@/lib/auth/session-core";
import { ROUTES, withQuery } from "@/lib/routing/routes";

export async function GET(request: NextRequest) {
  await clearSession();
  return NextResponse.redirect(new URL(withQuery(ROUTES.login, { next: safeNext(request.nextUrl.searchParams.get("next")) }), request.url));
}
