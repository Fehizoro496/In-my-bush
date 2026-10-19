import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it } from "vitest";
import { AdminHistory } from "./AdminHistory";

const event = {
  id: "e1", actorId: "a1", actorName: "Miora Rabe", action: "SHOP_SUSPENDED", targetType: "SHOP", targetId: "s1",
  reason: "Commandes jamais livrées", createdAt: "2026-10-08T07:30:00Z",
};

describe("AdminHistory", () => {
  it("shows each decision with its author, its time in Madagascar and its reason", () => {
    const html = renderToStaticMarkup(<AdminHistory events={[event]} />);
    for (const text of ["Boutique suspendue", "Miora Rabe", "10:30", "Commandes jamais livrées"]) expect(html).toContain(text);
  });

  it("says when nothing was decided yet, and names a deleted author", () => {
    expect(renderToStaticMarkup(<AdminHistory events={[]} />)).toContain("Aucune décision");
    expect(renderToStaticMarkup(<AdminHistory events={[{ ...event, actorName: null }]} />)).toContain("Compte supprimé");
  });
});
