import { describe, expect, it } from "vitest";
import { AUDIT_ACTION, ORDER_STATUS, PAYMENT_STATUS, PRODUCT_STATUS, ROLE, USER_STATUS, tagOf } from "./labels";

describe("backoffice tags", () => {
  it("names every status, role and action the API sends", () => {
    for (const s of ["ACTIVE", "SUSPENDED", "BANNED"]) expect(USER_STATUS[s]).toBeDefined();
    for (const r of ["BUYER", "SELLER", "ADMIN"]) expect(ROLE[r]).toBeDefined();
    for (const s of ["PENDING_REVIEW", "PUBLISHED", "REJECTED", "DRAFT", "ARCHIVED"]) expect(PRODUCT_STATUS[s]).toBeDefined();
    for (const s of ["PENDING_CONFIRMATION", "ACCEPTED", "PREPARED", "IN_DELIVERY", "DELIVERED", "REFUSED", "CANCELLED"]) expect(ORDER_STATUS[s]).toBeDefined();
    for (const s of ["PENDING", "HELD", "RELEASED", "REFUNDED", "FAILED"]) expect(PAYMENT_STATUS[s]).toBeDefined();
    for (const a of ["USER_SUSPENDED", "USER_BANNED", "USER_REACTIVATED", "PRODUCT_APPROVED", "PRODUCT_REJECTED", "REPORT_RESOLVED", "REPORT_DISMISSED", "SETTINGS_UPDATED", "CATEGORY_CREATED", "CATEGORY_UPDATED", "CATEGORY_MOVED", "CATEGORY_DEACTIVATED", "CATEGORY_REACTIVATED"]) expect(AUDIT_ACTION[a]).toBeDefined();
  });

  it("colours a status by its meaning", () => {
    expect(tagOf(USER_STATUS, "BANNED")).toEqual({ label: "Banni", tone: "danger" });
    expect(tagOf(ORDER_STATUS, "DELIVERED").tone).toBe("done");
  });

  it("keeps the code of an unknown value in a neutral tag", () => {
    expect(tagOf(ORDER_STATUS, "LOST")).toEqual({ label: "LOST", tone: "neutral" });
  });
});
