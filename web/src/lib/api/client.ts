/**
 * Typed fetch wrapper for the In my bush REST API (`/api/v1`).
 *  - base URL from NEXT_PUBLIC_API_URL
 *  - JWT bearer token (passed explicitly, or read from the `imb_session` cookie on the server)
 *  - errors are RFC 7807 problem+json → thrown as ApiError
 */
import "server-only";
import type { Page, ProblemDetails } from "@/lib/types";
import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { readSession, renewSession, saveSession } from "@/lib/auth/session";
import { safeNext, sessionEndPath, sessionRenewPath } from "@/lib/auth/session-core";

export const API_URL = process.env.API_URL ?? process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/api/v1";

/** Name of the cookie holding the access token (httpOnly, set by /connexion). */
export const SESSION_COOKIE = "imb_session";

export class ApiError extends Error {
  readonly status: number;
  readonly problem: ProblemDetails;

  constructor(problem: ProblemDetails) {
    super(problem.detail ?? problem.title);
    this.name = "ApiError";
    this.status = problem.status;
    this.problem = problem;
  }

  /** Field errors (validation), if any. */
  get fieldErrors(): Record<string, string> {
    return this.problem.errors ?? {};
  }
}

type Query = Record<string, string | number | boolean | null | undefined>;

export interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "PATCH" | "DELETE";
  query?: Query;
  body?: unknown;
  /** Access token. When omitted on the server, the session cookie is used. */
  token?: string | null;
  signal?: AbortSignal;
  /** Next.js fetch cache options. */
  next?: { revalidate?: number | false; tags?: string[] };
  cache?: RequestCache;
}

function buildUrl(path: string, query?: Query): string {
  const url = new URL(`${API_URL.replace(/\/$/, "")}${path.startsWith("/") ? path : `/${path}`}`);
  if (query) {
    for (const [k, v] of Object.entries(query)) {
      if (v !== undefined && v !== null && v !== "") url.searchParams.set(k, String(v));
    }
  }
  return url.toString();
}

async function resolveToken(explicit?: string | null): Promise<string | null> {
  if (explicit !== undefined) return explicit;
  if (typeof window !== "undefined") return null; // browser: the cookie is httpOnly, calls go through server actions/route handlers
  try {
    return (await readSession())?.accessToken ?? null;
  } catch {
    return null;
  }
}

export async function apiFetch<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { method = "GET", query, body, signal, next, cache } = options;
  const token = await resolveToken(options.token);
  const isForm = typeof FormData !== "undefined" && body instanceof FormData;

  const send = (access: string | null) => fetch(buildUrl(path, query), {
    method,
    signal,
    next,
    cache: cache ?? "no-store",
    headers: {
      Accept: "application/json, application/problem+json",
      ...(body !== undefined && !isForm ? { "Content-Type": "application/json" } : {}),
      ...(access ? { Authorization: `Bearer ${access}` } : {}),
    },
    body: body === undefined ? undefined : isForm ? (body as FormData) : JSON.stringify(body),
  });

  let res = await send(token);
  if (res.status === 401 && options.token === undefined && !path.startsWith("/auth/")) {
    const session = await readSession();
    // Signed out: the 401 is thrown below. Public pages render without a user, requireUser() sends to the login page.
    if (session) {
      const nextPath = safeNext((await headers()).get("x-imb-path"));
      let renewed;
      try { renewed = await renewSession(session); }
      catch { redirect(sessionEndPath(nextPath)); }
      try { await saveSession(renewed); }
      catch {
        // Server Components cannot write cookies. Persist the coalesced rotation in a route handler.
        redirect(sessionRenewPath(nextPath));
      }
      res = await send(renewed.accessToken);
      if (res.status === 401) redirect(sessionEndPath(nextPath));
    }
  }
  if (!res.ok) {
    let problem: ProblemDetails = { title: res.statusText || "Erreur", status: res.status };
    const type = res.headers.get("content-type") ?? "";
    if (type.includes("json")) {
      try {
        problem = { ...problem, ...((await res.json()) as Partial<ProblemDetails>) };
      } catch {
        /* keep default problem */
      }
    }
    throw new ApiError(problem);
  }

  if (res.status === 204) return undefined as T;
  return (await res.json()) as T;
}

/** Converts a 1-based UI page into the API's `?page=0&size=20`. */
export function pageQuery(page = 1, size = 20): { page: number; size: number } {
  return { page: Math.max(0, page - 1), size };
}

export type { Page };
