/**
 * Routing service: changes page from code. One `to<Route>()` method per entry of ROUTES (./routes).
 * Client components only, from event handlers.
 *
 *   routeService.toHome()                     goes to "/"
 *   routeService.toProduct(slug)              goes to "/produits/miel-de-litchi"
 *   routeService.toCart({ replace: true })    replaces the current history entry
 *   routeService.navigate(path)               goes to an arbitrary internal path
 *
 * For a path (<Link href>, redirects, server code), read ROUTES directly.
 * Navigation uses the Next.js router, bound once by <RouteServiceBinder /> in the root layout.
 */
import { ROUTES } from "./routes";

export interface NavigateOptions {
  /** Replace the current history entry instead of adding one. */
  replace?: boolean;
  /** Set to false to keep the scroll position. */
  scroll?: boolean;
}

/** The part of the Next.js app router the service needs. */
export interface AppRouter {
  push(href: string, options?: { scroll?: boolean }): void;
  replace(href: string, options?: { scroll?: boolean }): void;
}

let router: AppRouter | null = null;

function navigate(path: string, { replace = false, scroll }: NavigateOptions = {}): void {
  if (!router) {
    throw new Error(
      "routeService: navigation is only available in client components, once <RouteServiceBinder /> is mounted. " +
        "On the server, redirect to a path from ROUTES instead.",
    );
  }
  const options = scroll === undefined ? undefined : { scroll };
  if (replace) router.replace(path, options);
  else router.push(path, options);
}

export const routeService = {
  // Public
  toHome: (options?: NavigateOptions) => navigate(ROUTES.home, options),
  toCategories: (options?: NavigateOptions) => navigate(ROUTES.categories, options),
  toCatalogue: (options?: NavigateOptions) => navigate(ROUTES.catalogue, options),
  toSearch: (options?: NavigateOptions) => navigate(ROUTES.search, options),
  toProduct: (slug: string, options?: NavigateOptions) => navigate(ROUTES.product(slug), options),
  toShop: (slug: string, options?: NavigateOptions) => navigate(ROUTES.shop(slug), options),
  toCart: (options?: NavigateOptions) => navigate(ROUTES.cart, options),
  toCheckout: (options?: NavigateOptions) => navigate(ROUTES.checkout, options),
  toCheckoutConfirmation: (options?: NavigateOptions) => navigate(ROUTES.checkoutConfirmation, options),
  toLogin: (options?: NavigateOptions) => navigate(ROUTES.login, options),

  // Account (signed in)
  toAccount: (options?: NavigateOptions) => navigate(ROUTES.account, options),
  toAccountOrder: (id: string, options?: NavigateOptions) => navigate(ROUTES.accountOrder(id), options),
  toAccountFavorites: (options?: NavigateOptions) => navigate(ROUTES.accountFavorites, options),
  toAccountMessages: (options?: NavigateOptions) => navigate(ROUTES.accountMessages, options),
  toAccountNotifications: (options?: NavigateOptions) => navigate(ROUTES.accountNotifications, options),
  toAccountReviews: (options?: NavigateOptions) => navigate(ROUTES.accountReviews, options),
  toAccountAddresses: (options?: NavigateOptions) => navigate(ROUTES.accountAddresses, options),
  toAccountPayments: (options?: NavigateOptions) => navigate(ROUTES.accountPayments, options),
  toAccountSettings: (options?: NavigateOptions) => navigate(ROUTES.accountSettings, options),

  // Seller (role SELLER)
  toSeller: (options?: NavigateOptions) => navigate(ROUTES.seller, options),
  toSellerOnboarding: (options?: NavigateOptions) => navigate(ROUTES.sellerOnboarding, options),
  toSellerProducts: (options?: NavigateOptions) => navigate(ROUTES.sellerProducts, options),
  toSellerProductNew: (options?: NavigateOptions) => navigate(ROUTES.sellerProductNew, options),
  toSellerProduct: (id: string, options?: NavigateOptions) => navigate(ROUTES.sellerProduct(id), options),
  toSellerOrders: (options?: NavigateOptions) => navigate(ROUTES.sellerOrders, options),
  toSellerOrder: (id: string, options?: NavigateOptions) => navigate(ROUTES.sellerOrder(id), options),
  toSellerHistory: (options?: NavigateOptions) => navigate(ROUTES.sellerHistory, options),
  toSellerReviews: (options?: NavigateOptions) => navigate(ROUTES.sellerReviews, options),
  toSellerShop: (options?: NavigateOptions) => navigate(ROUTES.sellerShop, options),

  // Backoffice (role ADMIN)
  toAdmin: (options?: NavigateOptions) => navigate(ROUTES.admin, options),
  toAdminProducts: (options?: NavigateOptions) => navigate(ROUTES.adminProducts, options),
  toAdminUsers: (options?: NavigateOptions) => navigate(ROUTES.adminUsers, options),
  toAdminOrders: (options?: NavigateOptions) => navigate(ROUTES.adminOrders, options),
  toAdminReports: (options?: NavigateOptions) => navigate(ROUTES.adminReports, options),

  // Linked from the footer, pages not built yet
  toHelpDelivery: (options?: NavigateOptions) => navigate(ROUTES.helpDelivery, options),
  toHelpPayment: (options?: NavigateOptions) => navigate(ROUTES.helpPayment, options),
  toHelpReturns: (options?: NavigateOptions) => navigate(ROUTES.helpReturns, options),
  toHelpContact: (options?: NavigateOptions) => navigate(ROUTES.helpContact, options),
  toAbout: (options?: NavigateOptions) => navigate(ROUTES.about, options),
  toCharter: (options?: NavigateOptions) => navigate(ROUTES.charter, options),
  toPress: (options?: NavigateOptions) => navigate(ROUTES.press, options),
  toCareers: (options?: NavigateOptions) => navigate(ROUTES.careers, options),

  /** Goes to an internal path that is not a plain entry of ROUTES (query string, `next` parameter…). */
  navigate,

  /** Gives the service the Next.js router. Called by <RouteServiceBinder />. */
  bind(next: AppRouter | null): void {
    router = next;
  },
};

export type RouteService = typeof routeService;
