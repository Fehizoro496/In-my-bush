import { describe, expect, it } from "vitest";
import { checkAdminAction, REASON_MAX } from "./action-rules";

const id = "0e000000-0000-4000-8000-000000000103";

describe("backoffice actions", () => {
  it("requires a reason for every decision that takes something away", () => {
    for (const action of ["reject", "withdraw", "suspend", "ban", "suspendShop", "RESOLVED", "DISMISSED"]) {
      expect(checkAdminAction(id, action, "")).toBe("Un motif est obligatoire pour cette décision.");
      expect(checkAdminAction(id, action, "Photos trompeuses")).toBe("");
    }
  });

  it("lets approvals, reactivations and taking a report in charge go without a reason", () => {
    for (const action of ["approve", "reactivate", "reactivateShop", "IN_REVIEW"]) expect(checkAdminAction(id, action, "")).toBe("");
  });

  it("refuses an empty note, a text too long, an unknown action or identifier", () => {
    expect(checkAdminAction(id, "note", "")).toBe("La note est vide.");
    expect(checkAdminAction(id, "reject", "x".repeat(REASON_MAX + 1))).toContain(String(REASON_MAX));
    expect(checkAdminAction(id, "delete", "Motif")).toBe("Action invalide.");
    expect(checkAdminAction("../users", "ban", "Motif")).toBe("Identifiant invalide.");
  });
});
