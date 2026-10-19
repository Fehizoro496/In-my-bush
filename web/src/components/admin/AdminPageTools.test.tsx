import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it, vi } from "vitest";
import { ROUTES } from "@/lib/routing/routes";

vi.mock("next/headers", () => ({ cookies: async () => ({ get: (name: string) => name === "imb_rows_users" ? { value: "8" } : undefined }) }));
const { AdminPager, AdminTableCard, tableRows } = await import("./AdminPageTools");
const page = { items: [1, 2], page: 0, size: 8, totalItems: 20, totalPages: 3 };

describe("AdminTableCard", () => {
  it("fills the height left on large screens without lengthening the page", () => {
    const html = renderToStaticMarkup(<AdminTableCard table="users" rows={8}><table /></AdminTableCard>);
    expect(html).toContain("lg:flex-1");
    expect(html).toContain("overflow-hidden");
    expect(html).not.toContain("<p");
  });

  it("shows the empty message only when there are no rows", () => {
    expect(renderToStaticMarkup(<AdminTableCard table="users" rows={8} empty="Aucune commande.">{null}</AdminTableCard>)).toContain("Aucune commande.");
    expect(renderToStaticMarkup(<AdminTableCard table="users" rows={8} empty={false}>{null}</AdminTableCard>)).not.toContain("<p");
  });
});

describe("tableRows", () => {
  it("reads the rows remembered for a table, or the default", async () => {
    expect(await tableRows("users")).toBe(8);
    expect(await tableRows("orders")).toBe(10);
  });
});

describe("AdminPager", () => {
  it("offers page sizes unless the rows follow the screen", () => {
    expect(renderToStaticMarkup(<AdminPager data={page} path={ROUTES.adminProducts} />)).toContain("Par page");
    expect(renderToStaticMarkup(<AdminPager sizes={false} data={page} path={ROUTES.adminUsers} />)).not.toContain("Par page");
  });
});
