import "server-only";
import { cache } from "react";
import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { apiFetch, ApiError } from "@/lib/api/client";
import { ROUTES } from "@/lib/routing/routes";
import type { User } from "@/lib/types";
import { readSession } from "./session";
import { safeNext, sessionEndPath } from "./session-core";

/** The signed-in user, or null for a visitor. Never redirects: for pages anyone can open. */
export const currentUser = cache(async (): Promise<User | null> => {
  if (!(await readSession())) return null;
  try {
    return await apiFetch<User>("/me");
  } catch (error) {
    if (error instanceof ApiError && error.status === 401) return null;
    throw error;
  }
});

/** The signed-in user; visitors are sent to the login page and come back afterwards. */
export const requireUser = cache(async (): Promise<User> => {
  const user = await currentUser();
  // Goes through /session/end so an unreadable or rejected cookie is removed on the way.
  if (!user) redirect(sessionEndPath(safeNext((await headers()).get("x-imb-path"), ROUTES.account)));
  return user;
});

export async function requireAdmin(): Promise<User> {
  const user = await requireUser();
  if (!user.roles.includes("ADMIN")) redirect(ROUTES.home);
  return user;
}
