import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it } from "vitest";
import { ROUTES } from "@/lib/routing/routes";
import { AdminReportTarget } from "./AdminReportTarget";

const product = {
  found: true, title: "Tisane détox", excerpt: "Purifie le foie en 3 jours.", status: "PUBLISHED", productSlug: "tisane-detox",
  userId: "u1", userName: "Hery Rakoto", shopId: "s1", shopName: "Le Jardin de Hery",
};

describe("AdminReportTarget", () => {
  it("shows the reported text and leads to the product, its seller and its shop", () => {
    const html = renderToStaticMarkup(<AdminReportTarget type="PRODUCT" target={product} />);
    for (const text of ["Produit signalé", "Tisane détox", "Purifie le foie", "Publié", "Modérer le produit"]) expect(html).toContain(text);
    for (const href of [ROUTES.product("tisane-detox"), ROUTES.adminUser("u1"), ROUTES.adminShop("s1")]) expect(html).toContain(`href="${href}"`);
  });

  it("only offers the product moderation for a product", () => {
    const html = renderToStaticMarkup(<AdminReportTarget type="MESSAGE" target={{ ...product, title: "Message de Hery Rakoto", status: null, productSlug: null }} />);
    expect(html).not.toContain("Modérer le produit");
    expect(html).toContain("Message de Hery Rakoto");
  });

  it("says when the content has been deleted", () => {
    const html = renderToStaticMarkup(<AdminReportTarget type="REVIEW" target={{ ...product, found: false }} />);
    expect(html).toContain("supprimé");
    expect(html).not.toContain("Tisane détox");
  });
});
