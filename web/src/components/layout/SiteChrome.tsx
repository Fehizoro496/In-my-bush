import type { ReactNode } from "react";
import { getCounters, getCurrentUser } from "@/lib/data/account";
import { getCategories } from "@/lib/data/catalog";
import { initials } from "@/lib/format";
import { AccountNav } from "./AccountNav";
import { CompactHeader } from "./CompactHeader";
import { Container } from "./Container";
import { Footer } from "./Footer";
import { MobileTabBar, TabletRail } from "./MobileNav";
import { WebHeader } from "./WebHeader";

/** Public/account chrome: desktop header, tablet rail, phone tab bar, footer. */
export async function SiteChrome({ children, footer = true }: { children: ReactNode; footer?: boolean }) {
  const [user, counters, categories] = await Promise.all([getCurrentUser(), getCounters(), getCategories()]);
  const nav = { cart: counters.cart, messages: counters.unreadMessages, notifications: counters.unreadNotifications };
  return (
    <div className="flex min-h-dvh flex-col md:pl-[84px] lg:pl-0">
      <a
        href="#contenu"
        className="sr-only z-50 rounded-md bg-ink px-4 py-2 text-white focus:not-sr-only focus:fixed focus:top-2 focus:left-2"
      >
        Aller au contenu
      </a>
      <WebHeader user={user} cartCount={counters.cart} categories={categories.map((c) => ({ name: c.name, slug: c.slug }))} />
      <CompactHeader cartCount={counters.cart} notificationCount={counters.unreadNotifications} />
      <TabletRail counters={nav} />
      <div id="contenu" className="flex flex-1 flex-col pb-24 md:pb-0">
        {children}
      </div>
      {footer ? <Footer /> : <div className="h-20 md:hidden" />}
      <MobileTabBar counters={nav} />
    </div>
  );
}

/** Account / seller layout: AccountNav sidebar + content column. */
export async function AccountShell({ children }: { children: ReactNode }) {
  const [user, counters] = await Promise.all([getCurrentUser(), getCounters()]);
  const isSeller = user.roles.includes("SELLER");
  return (
    <Container className="flex flex-col gap-5 pt-5 pb-16 md:pt-6 lg:flex-row lg:items-start lg:gap-8 lg:pt-8">
      <AccountNav
        user={{
          name: `${user.firstName} ${user.lastName}`,
          initials: initials(`${user.firstName} ${user.lastName}`),
          roleLabel: isSeller ? "Acheteur & vendeur" : "Acheteur",
        }}
        counters={counters}
        isSeller={isSeller}
      />
      <main className="flex min-w-0 flex-1 flex-col gap-5">{children}</main>
    </Container>
  );
}
