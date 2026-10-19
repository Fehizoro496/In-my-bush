"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "@/components/ui/Icon";
import { Drawer } from "@/components/ui/Modal";
import { Logo } from "./Logo";
import { ROUTES } from "@/lib/routing/routes";
import type { User } from "@/lib/types";
import type { AdminCounts } from "@/lib/api/admin-contract";
import { logoutAction } from "@/lib/auth/actions";
import { initials } from "@/lib/format";

type AdminNavProps = { user: User; counts: AdminCounts };

interface AdminItem {
  label: string;
  href: string;
  icon: IconName;
  badge?: string;
  exact?: boolean;
  /** Only this entry is highlighted for its route. */
  primary?: boolean;
}

const groups = (counts: AdminCounts): { title: string; items: AdminItem[] }[] => [
  { title: "Pilotage", items: [{ label: "Dashboard", href: ROUTES.admin, icon: "chart", exact: true, primary: true }] },
  {
    title: "Marketplace",
    items: [
      { label: "Utilisateurs", href: ROUTES.adminUsers, icon: "users", primary: true },
      { label: "Boutiques", href: ROUTES.adminShops, icon: "store", primary: true },
      { label: "Produits", href: ROUTES.adminProducts, icon: "package", badge: String(counts.pendingProducts), primary: true },
      { label: "Catégories", href: ROUTES.adminCategories, icon: "layers", primary: true },
      { label: "Commandes", href: ROUTES.adminOrders, icon: "receipt", primary: true },
    ],
  },
  {
    title: "Modération",
    items: [
      { label: "Signalements", href: ROUTES.adminReports, icon: "flag", badge: String(counts.openReports), primary: true },
    ],
  },
  {
    title: "Système",
    items: [
      { label: "Journal", href: ROUTES.adminAudit, icon: "clock", primary: true },
    ],
  },
];

function SidebarContent({ pathname, onNavigate, user, counts }: AdminNavProps & { pathname: string; onNavigate?: () => void }) {
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
        {groups(counts).map((g) => (
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
          {initials(`${user.firstName} ${user.lastName}`)}
        </span>
        <div className="flex flex-1 flex-col text-[13px] leading-[17px]">
          <b>{user.firstName} {user.lastName}</b>
          <span className="text-[12px] text-[#9AA78A]">Administrateur</span>
        </div>
        <form action={logoutAction}><button
          type="submit"
          aria-label="Se déconnecter"
          className="flex size-10 items-center justify-center rounded-[10px] text-[#C5D0B5] hover:bg-white/10 hover:text-white"
        >
          <Icon name="logout" size={19} />
        </button></form>
      </div>
    </div>
  );
}

/** Fixed dark sidebar (≥ 1024 px). */
export function AdminSidebar(props: AdminNavProps) {
  const pathname = usePathname();
  return (
    <aside className="sticky top-0 hidden h-dvh w-64 shrink-0 bg-admin-sidebar text-[#E4EBD6] lg:block">
      <SidebarContent pathname={pathname} {...props} />
    </aside>
  );
}

/** Top bar: menu (below 1024 px), breadcrumb, search, notifications, help. */
export function AdminTopbar(props: AdminNavProps) {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const crumbs: Record<string, string[]> = {
    [ROUTES.admin]: ["Pilotage", "Dashboard"],
    [ROUTES.adminProducts]: ["Marketplace", "Produits"],
    [ROUTES.adminCategories]: ["Marketplace", "Catégories"],
    [ROUTES.adminUsers]: ["Marketplace", "Utilisateurs"],
    [ROUTES.adminOrders]: ["Marketplace", "Commandes"],
    [ROUTES.adminReports]: ["Modération", "Signalements"],
    [ROUTES.adminAudit]: ["Système", "Journal"],
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
          placeholder="Rechercher un utilisateur…"
          className="min-w-0 flex-1 border-0 bg-transparent text-ink outline-none focus-visible:outline-none"
        />
      </form>
      <Drawer open={open} onClose={() => setOpen(false)} title="Menu" side="left" width={280} dark>
        <SidebarContent pathname={pathname} {...props} onNavigate={() => setOpen(false)} />
      </Drawer>
    </header>
  );
}
