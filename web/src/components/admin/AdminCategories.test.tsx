import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it, vi } from "vitest";
import type { AdminCategory } from "@/lib/api/admin-contract";

vi.mock("@/lib/admin/category-actions", () => ({
  saveCategory: vi.fn(), deactivateCategory: vi.fn(), reactivateCategory: vi.fn(), moveCategory: vi.fn(),
}));
const { AdminCategoriesTable, canMove, parentChoices, replacementChoices } = await import("./AdminCategories");

const cat = (id: string, name: string, extra: Partial<AdminCategory> = {}): AdminCategory => ({
  id, parentId: null, parentName: null, name, slug: id, icon: "leaf", position: 1, active: true, productCount: 0, ...extra,
});
const fruits = cat("fruits", "Fruits & légumes", { productCount: 4 });
const agrumes = cat("agrumes", "Agrumes", { parentId: "fruits", parentName: "Fruits & légumes" });
const epicerie = cat("epicerie", "Épicerie");
const anciens = cat("anciens", "Anciens", { active: false });
const all = [fruits, agrumes, epicerie, anciens];

describe("AdminCategoriesTable", () => {
  it("shows each value in its own column and the state as a tag", () => {
    const html = renderToStaticMarkup(<AdminCategoriesTable items={all} all={all} />);
    for (const text of ["Fruits &amp; légumes", "Agrumes", "Active", "Désactivée", "Modifier", "Réactiver"]) expect(html).toContain(text);
    expect(html).toContain('aria-label="Monter"');
  });
});

describe("category choices", () => {
  it("only offers active top-level parents, never the category itself", () => {
    expect(parentChoices(all).map(c => c.id)).toEqual(["fruits", "epicerie"]);
    expect(parentChoices(all, epicerie).map(c => c.id)).toEqual(["fruits"]);
  });

  it("sends the products of a deactivated category to another active one", () => {
    expect(replacementChoices(all, fruits).map(c => c.id)).toEqual(["epicerie"]);
    expect(replacementChoices(all, epicerie).map(c => c.id)).toEqual(["fruits", "agrumes"]);
  });

  it("moves a category among its siblings only", () => {
    expect(canMove(all, fruits)).toEqual({ up: false, down: true });
    expect(canMove(all, anciens)).toEqual({ up: true, down: false });
    expect(canMove(all, agrumes)).toEqual({ up: false, down: false });
  });
});
