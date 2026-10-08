import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { routeService } from "./route.service";
import { ROUTES } from "./routes";

describe("routeService", () => {
  const router = { push: vi.fn(), replace: vi.fn() };

  beforeEach(() => {
    router.push.mockClear();
    router.replace.mockClear();
    routeService.bind(router);
  });
  afterEach(() => routeService.bind(null));

  it("has one navigation method per route", () => {
    const expected = Object.keys(ROUTES).map((name) => `to${name[0].toUpperCase()}${name.slice(1)}`);
    const methods = Object.keys(routeService).filter((k) => /^to[A-Z]/.test(k));
    expect(methods.sort()).toEqual(expected.sort());
  });

  it("pushes the route on the router", () => {
    routeService.toHome();
    expect(router.push).toHaveBeenLastCalledWith("/", undefined);
    routeService.toCheckoutConfirmation();
    expect(router.push).toHaveBeenLastCalledWith("/commande/confirmation", undefined);
    routeService.toProduct("miel-de-litchi");
    expect(router.push).toHaveBeenLastCalledWith("/produits/miel-de-litchi", undefined);
  });

  it("sends every method to its own route", () => {
    for (const [name, value] of Object.entries(ROUTES)) {
      const methods = routeService as unknown as Record<string, (...args: string[]) => void>;
      const expected = typeof value === "string" ? value : value("x");
      methods[`to${name[0].toUpperCase()}${name.slice(1)}`](...(typeof value === "string" ? [] : ["x"]));
      expect(router.push).toHaveBeenLastCalledWith(expected, undefined);
    }
  });

  it("replaces the history entry on demand", () => {
    routeService.toCart({ replace: true });
    routeService.toAccountOrder("ord-1", { replace: true });
    expect(router.push).not.toHaveBeenCalled();
    expect(router.replace).toHaveBeenNthCalledWith(1, "/panier", undefined);
    expect(router.replace).toHaveBeenNthCalledWith(2, "/compte/commandes/ord-1", undefined);
  });

  it("navigates to an arbitrary path, keeping the scroll position on demand", () => {
    routeService.navigate("/compte/commandes/ord-1?suivi=1");
    expect(router.push).toHaveBeenLastCalledWith("/compte/commandes/ord-1?suivi=1", undefined);
    routeService.navigate("/catalogue?tri=prix", { scroll: false });
    expect(router.push).toHaveBeenLastCalledWith("/catalogue?tri=prix", { scroll: false });
  });

  it("throws when no router is bound, as on the server", () => {
    routeService.bind(null);
    expect(() => routeService.toHome()).toThrow("only available in client components");
  });
});
