"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "@/components/ui/Icon";
import { CountBadge } from "@/components/ui/Badge";
import { ROUTES, isRoute } from "@/lib/routing/routes";

interface NavItem {
  label: string;
  href: string;
  icon: IconName;
  badge?: number;
  sell?: boolean;
  match: (path: string) => boolean;
}

function buildItems(counters: { cart: number; messages: number; notifications: number }) {
  const rail: NavItem[] = [
    { label: "Accueil", href: ROUTES.home, icon: "home", match: (p) => isRoute(p, ROUTES.home, { exact: true }) || isRoute(p, ROUTES.catalogue) || isRoute(p, ROUTES.product) || isRoute(p, ROUTES.categories) },
    { label: "Messages", href: ROUTES.accountMessages, icon: "msg", badge: counters.messages, match: (p) => isRoute(p, ROUTES.accountMessages) },
    { label: "Vendre", href: ROUTES.seller, icon: "plus", sell: true, match: (p) => isRoute(p, ROUTES.seller) },
    { label: "Panier", href: ROUTES.cart, icon: "cart", badge: counters.cart, match: (p) => isRoute(p, ROUTES.cart) || isRoute(p, ROUTES.checkout) },
    { label: "Profil", href: ROUTES.account, icon: "user", match: (p) => isRoute(p, ROUTES.account) && !isRoute(p, ROUTES.accountMessages) },
  ];
  const bar: NavItem[] = [
    rail[0]!,
    rail[1]!,
    rail[2]!,
    { label: "Notifs", href: ROUTES.accountNotifications, icon: "bell", badge: counters.notifications, match: (p) => isRoute(p, ROUTES.accountNotifications) },
    { label: "Paramètres", href: ROUTES.accountSettings, icon: "settings", match: (p) => isRoute(p, ROUTES.account) && !isRoute(p, ROUTES.accountMessages) && !isRoute(p, ROUTES.accountNotifications) },
  ];
  return { rail, bar };
}

/** Tablet navigation rail (768–1023 px), from T-Home / T-Catalog. */
export function TabletRail({ counters }: { counters: { cart: number; messages: number; notifications: number } }) {
  const pathname = usePathname();
  const { rail } = buildItems(counters);
  return (
    <nav
      aria-label="Navigation principale"
      className="fixed inset-y-0 left-0 z-40 hidden w-[84px] flex-col items-center gap-2 border-r border-line bg-white py-5 md:flex lg:hidden"
    >
      <Link
        href={ROUTES.home}
        aria-label="In my bush — accueil"
        className="mb-5 flex size-11 items-center justify-center rounded-[14px] bg-pomme-500 text-on-primary"
      >
        <Icon name="sprout" size={26} />
      </Link>
      {rail.map((r) => {
        const on = r.match(pathname);
        return (
          <Link
            key={r.href}
            href={r.href}
            aria-current={on ? "page" : undefined}
            className={cn(
              "flex min-h-[60px] w-[72px] flex-col items-center justify-center gap-1 rounded-lg text-[11px] no-underline",
              on ? "font-bold text-pomme-800 hover:text-pomme-800" : "font-medium text-body hover:text-ink",
            )}
          >
            <span
              className={cn(
                "relative flex h-8 w-[52px] items-center justify-center rounded-full",
                r.sell ? "bg-pomme-500 text-on-primary" : on ? "bg-mint text-pomme-800" : "text-body",
              )}
            >
              <Icon name={r.icon} size={22} />
              {!!r.badge && <CountBadge count={r.badge} ring className="absolute -top-1 right-0.5" />}
            </span>
            {r.label}
          </Link>
        );
      })}
    </nav>
  );
}

/** Phone bottom tab bar (< 768 px), from MobileTabBar. */
export function MobileTabBar({ counters }: { counters: { cart: number; messages: number; notifications: number } }) {
  const pathname = usePathname();
  const { bar } = buildItems(counters);
  return (
    <nav
      aria-label="Navigation principale"
      className="fixed inset-x-0 bottom-0 z-40 grid h-[76px] grid-cols-5 border-t border-line bg-white/[0.97] px-2 pt-1.5 pb-3 shadow-[0_-4px_16px_rgba(31,35,24,0.04)] backdrop-blur md:hidden"
    >
      {bar.map((r) => {
        const on = r.match(pathname);
        if (r.sell) {
          return (
            <Link
              key={r.href}
              href={r.href}
              className="flex flex-col items-center justify-end gap-[3px] text-[11px] font-bold text-ink no-underline hover:text-ink"
            >
              <span className="-mt-[22px] flex size-[50px] items-center justify-center rounded-[18px] border-[3px] border-white bg-pomme-500 text-on-primary shadow-[0_6px_16px_rgba(92,145,32,0.35)]">
                <Icon name="plus" size={26} />
              </span>
              {r.label}
            </Link>
          );
        }
        return (
          <Link
            key={r.href}
            href={r.href}
            aria-current={on ? "page" : undefined}
            className={cn(
              "flex flex-col items-center justify-center gap-[3px] text-[11px] whitespace-nowrap no-underline",
              on ? "font-bold text-pomme-700 hover:text-pomme-700" : "font-medium text-muted hover:text-ink",
            )}
          >
            <span className="relative flex">
              <Icon name={r.icon} size={24} />
              {!!r.badge && <CountBadge count={r.badge} ring className="absolute -top-[5px] -right-[9px]" />}
            </span>
            {r.label}
          </Link>
        );
      })}
    </nav>
  );
}
