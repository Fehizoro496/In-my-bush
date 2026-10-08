/**
 * Single list of the site's navigation paths. Never write a path by hand elsewhere:
 *
 *   <Link href={ROUTES.cart}>                                    "/panier"
 *   <Link href={ROUTES.product(slug)}>                           "/produits/miel-de-litchi"
 *   withQuery(ROUTES.catalogue, { categorie: "miel" })           "/catalogue?categorie=miel"
 *   isRoute(pathname, ROUTES.sellerProducts)                     true on the route and below it
 *
 * To change page from code, use routeService (./route.service).
 */
const segment = encodeURIComponent;

export const ROUTES = {
  // Public
  home: "/",
  categories: "/categories",
  catalogue: "/catalogue",
  search: "/recherche",
  product: (slug: string) => `/produits/${segment(slug)}`,
  shop: (slug: string) => `/vendeurs/${segment(slug)}`,
  cart: "/panier",
  checkout: "/commande",
  checkoutConfirmation: "/commande/confirmation",
  login: "/connexion",

  // Account (signed in)
  account: "/compte",
  accountOrder: (id: string) => `/compte/commandes/${segment(id)}`,
  accountFavorites: "/compte/favoris",
  accountMessages: "/compte/messages",
  accountNotifications: "/compte/notifications",
  accountReviews: "/compte/avis",
  accountAddresses: "/compte/adresses",
  accountPayments: "/compte/paiements",
  accountSettings: "/compte/parametres",

  // Seller (role SELLER)
  seller: "/vendre",
  sellerOnboarding: "/vendre/ouvrir-ma-boutique",
  sellerProducts: "/vendre/produits",
  sellerProductNew: "/vendre/produits/nouveau",
  sellerProduct: (id: string) => `/vendre/produits/${segment(id)}`,
  sellerOrders: "/vendre/commandes",
  sellerOrder: (id: string) => `/vendre/commandes/${segment(id)}`,
  sellerHistory: "/vendre/historique",
  sellerReviews: "/vendre/avis",
  sellerShop: "/vendre/boutique",

  // Backoffice (role ADMIN)
  admin: "/admin",
  adminProducts: "/admin/produits",
  adminUsers: "/admin/utilisateurs",
  adminOrders: "/admin/commandes",
  adminReports: "/admin/signalements",

  // Linked from the footer, pages not built yet (see PLANNED_ROUTES)
  helpDelivery: "/aide/livraison",
  helpPayment: "/aide/paiement",
  helpReturns: "/aide/retours",
  helpContact: "/aide/contact",
  about: "/a-propos",
  charter: "/charte",
  press: "/presse",
  careers: "/carrieres",
} as const;

export type RouteName = keyof typeof ROUTES;

/** A static path, or the builder of a path with a dynamic segment. */
export type Route = string | ((value: string) => string);

/** Routes that have no page under src/app yet. */
export const PLANNED_ROUTES: readonly RouteName[] = [
  "helpDelivery",
  "helpPayment",
  "helpReturns",
  "helpContact",
  "about",
  "charter",
  "press",
  "careers",
];

type QueryValue = string | number | boolean | null | undefined;

/** Appends a query string to a path; null and undefined values are left out. */
export function withQuery(path: string, query: Record<string, QueryValue> | URLSearchParams): string {
  const search =
    query instanceof URLSearchParams
      ? query.toString()
      : Object.entries(query)
          .filter(([, v]) => v !== null && v !== undefined)
          .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(String(v))}`)
          .join("&");
  return search ? `${path}?${search}` : path;
}

/** Stands for the dynamic segment when a route builder is turned back into a pattern. */
const ANY = "~";

/**
 * Tells whether `pathname` belongs to a route. By default the route's sub-pages
 * match too ("/vendre/produits/42" is in ROUTES.sellerProducts); `exact` restricts
 * to the route itself. The home page only ever matches exactly.
 */
export function isRoute(pathname: string, route: Route, { exact = false }: { exact?: boolean } = {}): boolean {
  const pattern = typeof route === "string" ? route : route(ANY);
  if (exact || pattern === "/") {
    const parts = pattern.split("/");
    const actual = pathname.split("/");
    return parts.length === actual.length && parts.every((part, i) => (part === ANY ? actual[i] !== "" : part === actual[i]));
  }
  const base = pattern.split(`/${ANY}`)[0];
  return pathname === base || pathname.startsWith(`${base}/`);
}
