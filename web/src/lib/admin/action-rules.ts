/** Which part of the API carries a backoffice action, and whether the action needs a reason. */
export type AdminActionKind = "product" | "user" | "shop" | "report" | "note";

export const ADMIN_ACTIONS: Record<string, { kind: AdminActionKind; reason: boolean }> = {
  approve: { kind: "product", reason: false },
  reject: { kind: "product", reason: true },
  withdraw: { kind: "product", reason: true },
  suspend: { kind: "user", reason: true },
  ban: { kind: "user", reason: true },
  reactivate: { kind: "user", reason: false },
  suspendShop: { kind: "shop", reason: true },
  reactivateShop: { kind: "shop", reason: false },
  IN_REVIEW: { kind: "report", reason: false },
  RESOLVED: { kind: "report", reason: true },
  DISMISSED: { kind: "report", reason: true },
  note: { kind: "note", reason: true },
};

export const REASON_MAX = 500;

/** Error to show for an action asked by a backoffice form, or "" when it can be sent to the API. */
export function checkAdminAction(id: string, action: string, reason: string): string {
  if (!/^[0-9a-f-]{36}$/i.test(id)) return "Identifiant invalide.";
  const rule = ADMIN_ACTIONS[action];
  if (!rule) return "Action invalide.";
  if (reason.length > REASON_MAX) return `Le texte compte ${REASON_MAX} caractères au plus.`;
  if (rule.reason && !reason) return rule.kind === "note" ? "La note est vide." : "Un motif est obligatoire pour cette décision.";
  return "";
}
