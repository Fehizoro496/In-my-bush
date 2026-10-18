import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it, vi } from "vitest";

vi.mock("@/lib/admin/actions", () => ({ adminMutation: vi.fn() }));
const { AdminProductsTable } = await import("./AdminProductsTable");
const product = {
  id: "p1", name: "Miel de litchi", description: "Pot de 500 g", slug: "miel", price: 12000, unitLabel: "pot", stock: 8,
  status: "PENDING_REVIEW" as const, rejectionReason: null, images: [], category: { name: "Épicerie" }, shop: { name: "Rucher" },
  createdAt: "2026-10-08T10:00:00Z", submitted: "08/10/2026",
};

describe("AdminProductsTable", () => {
  it("shows one product per row, each value in its own column, the status as a tag", () => {
    const html = renderToStaticMarkup(<AdminProductsTable items={[product]} />);
    for (const text of ["Miel de litchi", "Rucher", "Épicerie", "08/10/2026", "À valider"]) expect(html).toContain(text);
    expect(html).toContain('aria-label="Voir la fiche de Miel de litchi"');
  });

  it("keeps the description and the moderation actions for the popup", () => {
    const html = renderToStaticMarkup(<AdminProductsTable items={[product]} />);
    expect(html).not.toContain("Pot de 500 g");
    expect(html).not.toContain("Approuver");
  });
});
