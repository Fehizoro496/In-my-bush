import { readdirSync, readFileSync } from "node:fs";
import { join, relative } from "node:path";
import { describe, expect, it } from "vitest";
import { PLANNED_ROUTES, ROUTES, isRoute, withQuery, type RouteName } from "./routes";

const SRC = join(__dirname, "..", "..");

function files(dir: string): string[] {
  return readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
    const p = join(dir, e.name);
    return e.isDirectory() ? files(p) : [p];
  });
}

const posix = (p: string) => relative(SRC, p).replace(/\\/g, "/");

/** Path of a route with "~" in place of its dynamic segment. */
const pattern = (name: RouteName) => {
  const route = ROUTES[name];
  return typeof route === "string" ? route : route("~");
};

describe("ROUTES", () => {
  it("gives static paths", () => {
    expect(ROUTES.home).toBe("/");
    expect(ROUTES.cart).toBe("/panier");
    expect(ROUTES.sellerProductNew).toBe("/vendre/produits/nouveau");
  });

  it("builds paths with a dynamic segment", () => {
    expect(ROUTES.product("miel-de-litchi")).toBe("/produits/miel-de-litchi");
    expect(ROUTES.accountOrder("ord-24817")).toBe("/compte/commandes/ord-24817");
    expect(ROUTES.sellerOrder("sord-1")).toBe("/vendre/commandes/sord-1");
  });

  it("encodes the dynamic segment", () => {
    expect(ROUTES.shop("chez hery/2")).toBe("/vendeurs/chez%20hery%2F2");
  });

  const pages = files(join(SRC, "app"))
    .map(posix)
    .filter((p) => p.endsWith("/page.tsx"))
    .map((p) => {
      const segments = p
        .split("/")
        .slice(1, -1)
        .filter((s) => !/^\(.*\)$/.test(s))
        .map((s) => (/^\[.*\]$/.test(s) ? "~" : s));
      return `/${segments.join("/")}`;
    });
  const names = Object.keys(ROUTES) as RouteName[];

  it("lists every page of src/app", () => {
    const listed = names.map(pattern);
    expect(pages.filter((p) => !listed.includes(p))).toEqual([]);
  });

  it("only lists existing pages, apart from the planned ones", () => {
    const missing = names.filter((n) => !pages.includes(pattern(n)));
    expect(missing.sort()).toEqual([...PLANNED_ROUTES].sort());
  });

  it("has no duplicate path", () => {
    const paths = names.map(pattern);
    expect(new Set(paths).size).toBe(paths.length);
  });

  it("covers the proxy matcher", () => {
    const proxy = readFileSync(join(SRC, "proxy.ts"), "utf8");
    const matcher = /matcher: \[([^\]]*)\]/.exec(proxy)?.[1] ?? "";
    const bases = [...matcher.matchAll(/"([^"]+)\/:path\*"/g)].map((m) => m[1]);
    expect(bases.sort()).toEqual([ROUTES.account, ROUTES.admin, ROUTES.seller].sort());
  });
});

describe("withQuery", () => {
  it("appends the query string, leaving out empty values", () => {
    expect(withQuery(ROUTES.catalogue, { categorie: "fruits-legumes", sous: undefined, region: null })).toBe(
      "/catalogue?categorie=fruits-legumes",
    );
    expect(withQuery(ROUTES.catalogue, { tri: "pertinence", promo: 1 })).toBe("/catalogue?tri=pertinence&promo=1");
    expect(withQuery(ROUTES.search, { q: "thé & café" })).toBe("/recherche?q=th%C3%A9%20%26%20caf%C3%A9");
  });

  it("returns the bare path when there is nothing to append", () => {
    expect(withQuery(ROUTES.catalogue, {})).toBe("/catalogue");
    expect(withQuery(ROUTES.catalogue, new URLSearchParams())).toBe("/catalogue");
  });

  it("accepts URLSearchParams", () => {
    expect(withQuery(ROUTES.catalogue, new URLSearchParams({ categorie: "miel", tri: "prix" }))).toBe(
      "/catalogue?categorie=miel&tri=prix",
    );
  });
});

describe("isRoute", () => {
  it("matches the route and its sub-pages by default", () => {
    expect(isRoute("/vendre/produits", ROUTES.sellerProducts)).toBe(true);
    expect(isRoute("/vendre/produits/42", ROUTES.sellerProducts)).toBe(true);
    expect(isRoute("/vendre/commandes", ROUTES.sellerProducts)).toBe(false);
  });

  it("stops at segment boundaries", () => {
    expect(isRoute("/commande/confirmation", ROUTES.checkout)).toBe(true);
    expect(isRoute("/commandes", ROUTES.checkout)).toBe(false);
  });

  it("matches only the route itself when exact", () => {
    expect(isRoute("/vendre", ROUTES.seller, { exact: true })).toBe(true);
    expect(isRoute("/vendre/produits", ROUTES.seller, { exact: true })).toBe(false);
  });

  it("matches routes with a dynamic segment", () => {
    expect(isRoute("/produits/miel-de-litchi", ROUTES.product)).toBe(true);
    expect(isRoute("/produits", ROUTES.product)).toBe(true);
    expect(isRoute("/produits/miel-de-litchi", ROUTES.product, { exact: true })).toBe(true);
    expect(isRoute("/produits/miel/avis", ROUTES.product, { exact: true })).toBe(false);
    expect(isRoute("/produits/", ROUTES.product, { exact: true })).toBe(false);
  });

  it("never treats the home page as a prefix", () => {
    expect(isRoute("/", ROUTES.home)).toBe(true);
    expect(isRoute("/panier", ROUTES.home)).toBe(false);
  });
});

describe("source files", () => {
  const sources = files(SRC).filter((p) => /\.tsx?$/.test(p) && !posix(p).startsWith("lib/routing/"));

  it("change page through the routing service only", () => {
    const offenders = sources.filter((p) => /useRouter|router\.(push|replace)\(/.test(readFileSync(p, "utf8"))).map(posix);
    expect(offenders).toEqual([]);
  });

  // API paths live in lib/api; the proxy matcher has to stay literal.
  it("take every navigation path from ROUTES", () => {
    const firstSegments = [...new Set((Object.keys(ROUTES) as RouteName[]).map((n) => pattern(n).split("/")[1]).filter(Boolean))].join("|");
    const literal = new RegExp(`["'\`]/(?:${firstSegments})(?:[/?#"'\`]|\\$\\{)|(?:href|action)="/"`);
    const offenders = sources
      .filter((p) => !posix(p).startsWith("lib/api/"))
      .flatMap((p) =>
        readFileSync(p, "utf8")
          .split("\n")
          .map((line, i) => ({ line, at: `${posix(p)}:${i + 1}` }))
          .filter(({ line }) => literal.test(line) && !line.includes("matcher:"))
          .map(({ at }) => at),
      );
    expect(offenders).toEqual([]);
  });
});
