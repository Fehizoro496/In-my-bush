"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "@/components/ui/Icon";
import { Drawer } from "@/components/ui/Modal";
import { Logo } from "./Logo";
import { ROUTES, withQuery } from "@/lib/routing/routes";

interface AdminItem {
  label: string;
  href: string;
  icon: IconName;
  badge?: string;
  exact?: boolean;
  /** Only this entry is highlighted for its route. */
  primary?: boolean;
}

const GROUPS: { title: string; items: AdminItem[] }[] = [
  { title: "Pilotage", items: [{ label: "Dashboard", href: ROUTES.admin, icon: "chart", exact: true, primary: true }] },
  {
    title: "Marketplace",
    items: [
      { label: "Utilisateurs", href: ROUTES.adminUsers, icon: "users", primary: true },
      { label: "Vendeurs", href: withQuery(ROUTES.adminUsers, { role: "vendeurs" }), icon: "store" },
      { label: "Produits", href: ROUTES.adminProducts, icon: "package", badge: "24", primary: true },
      { label: "Catégories", href: withQuery(ROUTES.adminProducts, { vue: "categories" }), icon: "layers" },
      { label: "Commandes", href: ROUTES.adminOrders, icon: "receipt", primary: true },
      { label: "Transactions", href: withQuery(ROUTES.adminOrders, { vue: "transactions" }), icon: "wallet" },
    ],
  },
  {
    title: "Modération",
    items: [
      { label: "Avis", href: withQuery(ROUTES.adminReports, { type: "avis" }), icon: "starO" },
      { label: "Signalements", href: ROUTES.adminReports, icon: "flag", badge: "7", primary: true },
    ],
  },
  {
    title: "Marketing",
    items: [
      { label: "Promotions", href: withQuery(ROUTES.admin, { section: "promotions" }), icon: "percent" },
      { label: "Notifications", href: withQuery(ROUTES.admin, { section: "notifications" }), icon: "bell" },
    ],
  },
  { title: "Système", items: [{ label: "Paramètres", href: withQuery(ROUTES.admin, { section: "parametres" }), icon: "settings" }] },
];

function SidebarContent({ pathname, onNavigate }: { pathname: string; onNavigate?: () => void }) {
  return (
    <div className="flex h-full flex-col px-3.5 py-5">
      <div className="px-1.5 pb-5">
        <Link href={ROUTES.admin} aria-label="In my bush — backoffice" className="no-underline" onClick={onNavigate}>
          <Logo tone="dark" />
        </Link>
      </div>
      <span className="mx-1.5 mb-[18px] self-start rounded-[6px] bg-lime px-2 py-1 text-[11px] font-bold tracking-[0.08em] text-on-primary uppercase">
        Backoffice
      </span>
      <nav aria-label="Administration" className="flex flex-1 flex-col gap-[18px] overflow-y-auto">
        {GROUPS.map((g) => (
          <div key={g.title} className="flex flex-col gap-0.5">
            <div className="px-2.5 pb-1.5 text-[11px] font-bold tracking-[0.08em] text-[#9AA78A] uppercase">{g.title}</div>
            {g.items.map((it) => {
              const on = it.primary && (it.exact ? pathname === it.href : pathname.startsWith(it.href));
              return (
                <Link
                  key={it.label}
                  href={it.href}
                  onClick={onNavigate}
                  aria-current={on ? "page" : undefined}
                  className={cn(
                    "flex h-10 items-center gap-3 rounded-[10px] px-2.5 text-[14px] no-underline",
                    on
                      ? "bg-[rgba(140,198,63,0.18)] font-bold text-pomme-50 hover:text-pomme-50"
                      : "font-medium text-[#C5D0B5] hover:bg-white/5 hover:text-white",
                  )}
                >
                  <Icon name={it.icon} size={19} />
                  <span className="flex-1">{it.label}</span>
                  {it.badge && (
                    <span className="flex h-5 min-w-[22px] items-center justify-center rounded-full bg-orange-500 px-1.5 text-[11px] font-extrabold text-on-secondary">
                      {it.badge}
                    </span>
                  )}
                </Link>
              );
            })}
          </div>
        ))}
      </nav>
      <div className="mt-4 flex items-center gap-2.5 border-t border-[rgba(228,235,214,0.12)] px-1.5 pt-3.5">
        <span className="flex size-9 items-center justify-center rounded-full bg-orange-500 text-[13px] font-extrabold text-on-secondary">
          NA
        </span>
        <div className="flex flex-1 flex-col text-[13px] leading-[17px]">
          <b>Nirina A.</b>
          <span className="text-[12px] text-[#9AA78A]">Super admin</span>
        </div>
        <Link
          href={ROUTES.login}
          aria-label="Se déconnecter"
          className="flex size-10 items-center justify-center rounded-[10px] text-[#C5D0B5] hover:bg-white/10 hover:text-white"
        >
          <Icon name="logout" size={19} />
        </Link>
      </div>
    </div>
  );
}

/** Fixed dark sidebar (≥ 1024 px). */
export function AdminSidebar() {
  const pathname = usePathname();
  return (
    <aside className="sticky top-0 hidden h-dvh w-64 shrink-0 bg-admin-sidebar text-[#E4EBD6] lg:block">
      <SidebarContent pathname={pathname} />
    </aside>
  );
}

/** Top bar: menu (below 1024 px), breadcrumb, search, notifications, help. */
export function AdminTopbar() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const crumbs: Record<string, string[]> = {
    [ROUTES.admin]: ["Pilotage", "Dashboard"],
    [ROUTES.adminProducts]: ["Marketplace", "Produits"],
    [ROUTES.adminUsers]: ["Marketplace", "Utilisateurs"],
    [ROUTES.adminOrders]: ["Marketplace", "Commandes"],
    [ROUTES.adminReports]: ["Modération", "Signalements"],
  };
  const parts = crumbs[pathname] ?? ["Admin"];
  return (
    <header className="sticky top-0 z-30 flex h-[72px] items-center gap-3 border-b border-line bg-white px-4 md:gap-5 md:px-8">
      <button
        type="button"
        aria-label="Ouvrir le menu"
        onClick={() => setOpen(true)}
        className="flex size-11 items-center justify-center rounded-[10px] border-[1.5px] border-line-strong lg:hidden"
      >
        <Icon name="menu" size={20} />
      </button>
      <nav aria-label="Fil d’Ariane" className="flex min-w-0 items-center gap-1.5 text-[14px] text-muted">
        <span className="hidden sm:inline">Admin</span>
        {parts.map((p, i) => (
          <span key={p} className={cn("flex items-center gap-1.5", i < parts.length - 1 && "hidden sm:flex")}>
            <Icon name="chevR" size={14} className={i === 0 ? "hidden sm:block" : undefined} />
            <span className={i === parts.length - 1 ? "font-bold text-ink" : "font-medium"}>{p}</span>
          </span>
        ))}
      </nav>
      <div className="flex-1" />
      <form role="search" action={ROUTES.adminUsers} className="hidden h-[42px] w-[360px] items-center gap-2 rounded-[10px] border-[1.5px] border-line-strong bg-bg px-3 text-[14px] text-muted md:flex">
        <Icon name="search" size={17} />
        <label htmlFor="admin-search" className="sr-only">
          Rechercher
        </label>
        <input
          id="admin-search"
          name="q"
          placeholder="Rechercher utilisateur, produit, commande…"
          className="min-w-0 flex-1 border-0 bg-transparent text-ink outline-none focus-visible:outline-none"
        />
        <kbd className="rounded-[5px] border border-pebble px-[5px] py-px font-sans text-[11px] font-bold">Ctrl K</kbd>
      </form>
      <button
        type="button"
        aria-label="Notifications, 5 nouvelles"
        className="relative flex size-[42px] shrink-0 items-center justify-center rounded-[10px] border-[1.5px] border-line-strong bg-white"
      >
        <Icon name="bell" size={19} />
        <span className="absolute top-2 right-[9px] size-2 rounded-full bg-orange-500" />
      </button>
      <button
        type="button"
        aria-label="Aide"
        className="hidden size-[42px] shrink-0 items-center justify-center rounded-[10px] border-[1.5px] border-line-strong bg-white sm:flex"
      >
        <Icon name="info" size={19} />
      </button>
      <Drawer open={open} onClose={() => setOpen(false)} title="Menu" side="left" width={280} dark>
        <SidebarContent pathname={pathname} onNavigate={() => setOpen(false)} />
      </Drawer>
    </header>
  );
}
