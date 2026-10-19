"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth/require-user";
import { ApiError } from "@/lib/api/client";
import { adminLive } from "@/lib/api/admin-live";
import { ROUTES } from "@/lib/routing/routes";

export async function adminMutation(_state: { error: string; success: string }, form: FormData) {
  await requireAdmin();
  const id = String(form.get("id") ?? "");
  const action = String(form.get("action") ?? "");
  const reason = String(form.get("reason") ?? "").trim();
  if (!/^[0-9a-f-]{36}$/i.test(id)) return { error: "Identifiant invalide.", success: "" };
  if (["reject", "suspend", "ban"].includes(action) && (!reason || reason.length > 500)) {
    return { error: "Un motif de 1 à 500 caractères est obligatoire.", success: "" };
  }
  try {
    if (["approve", "reject"].includes(action)) {
      await adminLive.productAction(id, action, reason);
    } else if (["suspend", "ban", "reactivate"].includes(action)) {
      await adminLive.userAction(id, action, reason);
    } else if (["RESOLVED", "DISMISSED"].includes(action)) {
      await adminLive.reportAction(id, action, reason);
    } else return { error: "Action invalide.", success: "" };
  } catch (error) {
    if (!(error instanceof ApiError)) throw error;
    return { error: error.message, success: "" };
  }
  revalidatePath(ROUTES.admin, "layout");
  return { error: "", success: "Modification enregistrée." };
}
