"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth/require-user";
import { ApiError } from "@/lib/api/client";
import { adminLive } from "@/lib/api/admin-live";
import { ROUTES } from "@/lib/routing/routes";
import { ADMIN_ACTIONS, checkAdminAction } from "./action-rules";

export async function adminMutation(_state: { error: string; success: string }, form: FormData) {
  await requireAdmin();
  const id = String(form.get("id") ?? "");
  const action = String(form.get("action") ?? "");
  const reason = String(form.get("reason") ?? "").trim();
  const error = checkAdminAction(id, action, reason);
  if (error) return { error, success: "" };
  try {
    switch (ADMIN_ACTIONS[action]!.kind) {
      case "product": await adminLive.productAction(id, action, reason); break;
      case "user": await adminLive.userAction(id, action, reason); break;
      case "shop": await adminLive.shopAction(id, action === "suspendShop" ? "suspend" : "reactivate", reason); break;
      case "report": await adminLive.reportAction(id, action, reason); break;
      case "note": await adminLive.reportNote(id, reason); break;
    }
  } catch (error) {
    if (!(error instanceof ApiError)) throw error;
    return { error: error.message, success: "" };
  }
  revalidatePath(ROUTES.admin, "layout");
  return { error: "", success: action === "note" ? "Note ajoutée." : "Modification enregistrée." };
}
