import { NextRequest, NextResponse } from "next/server";
import { API_URL, clearSession, readSession, renewSession, saveSession } from "@/lib/auth/session";
import { safeNext } from "@/lib/auth/session-core";
import { ROUTES, withQuery } from "@/lib/routing/routes";

export async function GET(request: NextRequest) {
  const next = safeNext(request.nextUrl.searchParams.get("next"));
  try {
    const session = await readSession();
    if (!session) throw new Error("Missing session");
    const renewed = await renewSession(session);
    const me = await fetch(`${API_URL}/me`, { headers: { Authorization: `Bearer ${renewed.accessToken}` },
      cache: "no-store", signal: AbortSignal.timeout(15000) });
    if (!me.ok) throw new Error("Inactive session");
    await saveSession(renewed);
    return NextResponse.redirect(new URL(next, request.url));
  } catch {
    await clearSession();
    return NextResponse.redirect(new URL(withQuery(ROUTES.login, { next }), request.url));
  }
}
