"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth/require-user";
import { ApiError } from "@/lib/api/client";
import { adminLive } from "@/lib/api/admin-live";
import { ROUTES } from "@/lib/routing/routes";

export type CategoryState = { error: string; success: string };
const UUID = /^[0-9a-f-]{36}$/i;
const done = (success: string): CategoryState => {
  revalidatePath(ROUTES.admin, "layout");
  return { error: "", success };
};
const failed = (error: unknown): CategoryState => {
  if (error instanceof ApiError) return { error: error.message, success: "" };
  throw error;
};

/** Creates a category, or modifies the one whose id the form carries. */
export async function saveCategory(_state: CategoryState, form: FormData): Promise<CategoryState> {
  await requireAdmin();
  const id = String(form.get("id") ?? "");
  const name = String(form.get("name") ?? "").trim();
  const parentId = String(form.get("parentId") ?? "");
  if (name.length < 2 || name.length > 80) return { error: "Le nom compte de 2 à 80 caractères.", success: "" };
  if ((id && !UUID.test(id)) || (parentId && !UUID.test(parentId))) return { error: "Catégorie invalide.", success: "" };
  const input = {
    name, slug: String(form.get("slug") ?? "").trim(), icon: String(form.get("icon") ?? ""), parentId: parentId || null,
  };
  try {
    if (id) await adminLive.updateCategory(id, input);
    else await adminLive.createCategory(input);
  } catch (error) { return failed(error); }
  return done(id ? "Catégorie modifiée." : "Catégorie créée.");
}

/** Deactivates a category; its products go to the replacement category of the form, if any. */
export async function deactivateCategory(_state: CategoryState, form: FormData): Promise<CategoryState> {
  await requireAdmin();
  const id = String(form.get("id") ?? "");
  const replacementId = String(form.get("replacementId") ?? "");
  if (!UUID.test(id) || (replacementId && !UUID.test(replacementId))) return { error: "Catégorie invalide.", success: "" };
  try { await adminLive.deactivateCategory(id, replacementId || null); } catch (error) { return failed(error); }
  return done("Catégorie désactivée.");
}

export async function reactivateCategory(_state: CategoryState, form: FormData): Promise<CategoryState> {
  await requireAdmin();
  const id = String(form.get("id") ?? "");
  if (!UUID.test(id)) return { error: "Catégorie invalide.", success: "" };
  try { await adminLive.reactivateCategory(id); } catch (error) { return failed(error); }
  return done("Catégorie réactivée.");
}

/** Moves a category up or down among its siblings. */
export async function moveCategory(_state: CategoryState, form: FormData): Promise<CategoryState> {
  await requireAdmin();
  const id = String(form.get("id") ?? "");
  const direction = form.get("direction") === "UP" ? "UP" : "DOWN";
  if (!UUID.test(id)) return { error: "Catégorie invalide.", success: "" };
  try { await adminLive.moveCategory(id, direction); } catch (error) { return failed(error); }
  return done("");
}
