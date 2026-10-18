import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("server-only", () => ({}));
vi.mock("../api/client", () => ({ apiFetch: vi.fn(), pageQuery: vi.fn() }));

import { apiFetch } from "../api/client";

const product = {
  id: "real-product", slug: "real-product", name: "Produit API", price: 100,
  compareAtPrice: 150, unit: "KG", unitLabel: "kg", stock: 2,
  stockStatus: "LOW_STOCK", ratingAvg: 4, ratingCount: 3, imageUrl: null,
  shop: { id: "shop", slug: "shop", name: "Producteur API", city: "Antsirabe" },
  category: { id: "category", slug: "legumes", name: "Légumes" },
};

describe("accueil sans mocks", () => {
  beforeEach(() => {
    vi.resetModules();
    vi.mocked(apiFetch).mockReset();
    vi.stubEnv("NEXT_PUBLIC_USE_MOCKS", "false");
  });

  it("compose les rails à partir des pages API et adapte les cartes", async () => {
    vi.mocked(apiFetch).mockResolvedValue({ items: [product], page: 0, size: 10, totalItems: 1, totalPages: 1 });
    const { getHome } = await import("./catalog");
    const home = await getHome();
    expect(apiFetch).toHaveBeenCalledTimes(3);
    for (const sort of ["rating", "newest", "popular"]) {
      expect(apiFetch).toHaveBeenCalledWith("/products", { token: null, query: { sort, page: 0, size: 10 } });
    }
    expect(home.rails.news[0]).toMatchObject({ name: "Produit API", stockLevel: "LOW", categorySlug: "legumes", visual: { icon: "leaf" } });
    expect(home.promos).toHaveLength(1);
    expect(home.nearby).toEqual([]);
    expect(home.popularShops).toEqual([]);
    expect(home.promoEndsIn).toBe("");
  });

  it("accepte un catalogue vide en production même si le drapeau mock est activé", async () => {
    vi.stubEnv("NODE_ENV", "production");
    vi.stubEnv("NEXT_PUBLIC_USE_MOCKS", "true");
    vi.mocked(apiFetch).mockResolvedValue({ items: [] });
    const { getHome } = await import("./catalog");
    expect((await getHome()).rails.news).toEqual([]);
    expect(apiFetch).toHaveBeenCalledTimes(3);
    vi.unstubAllEnvs();
  });

  it("remonte une erreur API sans substituer de produits fictifs", async () => {
    vi.mocked(apiFetch).mockRejectedValue(new Error("API indisponible"));
    const { getHome } = await import("./catalog");
    await expect(getHome()).rejects.toThrow("API indisponible");
  });

  it("conserve le mode démonstration explicitement activé", async () => {
    vi.stubEnv("NODE_ENV", "development");
    vi.stubEnv("NEXT_PUBLIC_USE_MOCKS", "true");
    const { getHome } = await import("./catalog");
    expect((await getHome()).rails.news.length).toBeGreaterThan(0);
    expect(apiFetch).not.toHaveBeenCalled();
    vi.unstubAllEnvs();
  });
});
