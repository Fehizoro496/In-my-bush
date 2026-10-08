"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "@/components/ui/Icon";
import { Avatar } from "@/components/ui/Avatar";
import { ROUTES, isRoute, withQuery } from "@/lib/routing/routes";

export interface AccountCounters {
  ordersInProgress: number;
  unreadMessages: number;
  reviewsToLeave: number;
  lowStock: number;
  ordersToHandle: number;
  unreadNotifications: number;
}

interface Item {
  label: string;
  href: string;
  icon: IconName;
  badge?: number;
  match?: (p: string) => boolean;
}

function groups(c: AccountCounters, isSeller: boolean): { title: string; icon: IconName; items: Item[] }[] {
  const sell: Item[] = isSeller
    ? [
        { label: "Tableau de bord", href: ROUTES.seller, icon: "chart", match: (p) => isRoute(p, ROUTES.seller, { exact: true }) },
        { label: "Mes produits", href: ROUTES.sellerProducts, icon: "package", match: (p) => isRoute(p, ROUTES.sellerProducts) },
        { label: "Stock", href: withQuery(ROUTES.sellerProducts, { filtre: "stock" }), icon: "layers", badge: c.lowStock, match: () => false },
        { label: "Commandes reçues", href: ROUTES.sellerOrders, icon: "receipt", badge: c.ordersToHandle, match: (p) => isRoute(p, ROUTES.sellerOrders) },
        { label: "Historique des ventes", href: ROUTES.sellerHistory, icon: "trend" },
        { label: "Avis reçus", href: ROUTES.sellerReviews, icon: "star" },
        { label: "Profil vendeur", href: ROUTES.sellerShop, icon: "store" },
      ]
    : [{ label: "Ouvrir ma boutique", href: ROUTES.sellerOnboarding, icon: "store" }];
  return [
    {
      title: "Mes achats",
      icon: "basket",
      items: [
        { label: "Commandes", href: ROUTES.account, icon: "package", badge: c.ordersInProgress, match: (p) => isRoute(p, ROUTES.account, { exact: true }) || isRoute(p, ROUTES.accountOrder) },
        { label: "Favoris", href: ROUTES.accountFavorites, icon: "heart" },
        { label: "Messages", href: ROUTES.accountMessages, icon: "msg", badge: c.unreadMessages },
        { label: "Avis à laisser", href: ROUTES.accountReviews, icon: "starO", badge: c.reviewsToLeave },
      ],
    },
    { title: "Mes ventes", icon: "store", items: sell },
    {
      title: "Compte",
      icon: "user",
      items: [
        { label: "Profil", href: `${ROUTES.accountSettings}#profil`, icon: "user", match: () => false },
        { label: "Adresses", href: ROUTES.accountAddresses, icon: "pin" },
        { label: "Moyens de paiement", href: ROUTES.accountPayments, icon: "wallet" },
        { label: "Notifications", href: ROUTES.accountNotifications, icon: "bell", badge: c.unreadNotifications },
        { label: "Paramètres", href: ROUTES.accountSettings, icon: "settings" },
      ],
    },
  ];
}

function isActive(item: Item, pathname: string) {
  return item.match ? item.match(pathname) : pathname === item.href || pathname.startsWith(`${item.href}/`);
}

/** Account sidebar (≥ 1024 px) and horizontal scroller (below). */
export function AccountNav({
  user,
  counters,
  isSeller = true,
}: {
  user: { name: string; initials: string; roleLabel: string };
  counters: AccountCounters;
  isSeller?: boolean;
}) {
  const pathname = usePathname();
  const gs = groups(counters, isSeller);
  return (
    <>
      <nav
        aria-label="Mon compte"
        className="hidden w-[264px] shrink-0 flex-col gap-[18px] self-start rounded-xl border border-line bg-white px-3 py-[18px] lg:flex"
      >
        <div className="flex items-center gap-3 px-1.5">
          <Avatar initials={user.initials} size={48} display />
          <div className="flex flex-col gap-px">
            <b className="text-[15px]">{user.name}</b>
            <span className="text-[12px] text-muted">{user.roleLabel}</span>
          </div>
        </div>
        {gs.map((g) => (
          <div key={g.title} className="flex flex-col gap-0.5">
            <div className="flex items-center gap-1.5 px-2.5 pb-1.5 text-[11px] font-bold tracking-[0.08em] text-muted uppercase">
              <Icon name={g.icon} size={14} />
              {g.title}
            </div>
            {g.items.map((it) => {
              const on = isActive(it, pathname);
              return (
                <Link
                  key={it.label}
                  href={it.href}
                  aria-current={on ? "page" : undefined}
                  className={cn(
                    "flex h-10 items-center gap-2.5 rounded-[10px] px-2.5 text-[14px] no-underline",
                    on ? "bg-pomme-100 font-bold text-pomme-800 hover:text-pomme-800" : "font-medium text-text-soft hover:bg-bg hover:text-ink",
                  )}
                >
                  <Icon name={it.icon} size={18} />
                  <span className="flex-1">{it.label}</span>
                  {!!it.badge && (
                    <span className="flex h-5 min-w-5 items-center justify-center rounded-full bg-orange-500 px-1.5 text-[11px] font-extrabold text-on-secondary">
                      {it.badge}
                    </span>
                  )}
                </Link>
              );
            })}
          </div>
        ))}
      </nav>
      <nav aria-label="Mon compte" className="-mx-4 overflow-x-auto px-4 scrollbar-none md:-mx-8 md:px-8 lg:hidden">
        <ul className="m-0 flex w-max list-none gap-2 p-0">
          {gs.flatMap((g) => g.items).map((it) => {
            const on = isActive(it, pathname);
            return (
              <li key={it.label}>
                <Link
                  href={it.href}
                  aria-current={on ? "page" : undefined}
                  className={cn(
                    "flex h-11 items-center gap-2 rounded-full border-[1.5px] px-3.5 text-[14px] font-semibold whitespace-nowrap no-underline",
                    on ? "border-pomme-900 bg-pomme-900 text-pomme-50 hover:text-pomme-50" : "border-line-strong bg-white text-ink hover:text-ink",
                  )}
                >
                  <Icon name={it.icon} size={16} />
                  {it.label}
                  {!!it.badge && (
                    <span className="flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-orange-500 px-1 text-[11px] font-extrabold text-on-secondary">
                      {it.badge}
                    </span>
                  )}
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>
    </>
  );
}
