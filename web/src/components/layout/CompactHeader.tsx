import Link from "next/link";
import { Icon } from "@/components/ui/Icon";
import { CountBadge } from "@/components/ui/Badge";
import { Logo } from "./Logo";
import { HeaderSearch } from "./WebHeader";

/**
 * Header below 1024 px.
 *  - tablet (T-Home): search field + notifications button, the rail carries logo & cart
 *  - phone: logo row with notifications + cart, then the search field
 */
export function CompactHeader({ cartCount, notificationCount }: { cartCount: number; notificationCount: number }) {
  return (
    <header className="sticky top-0 z-40 border-b border-line bg-white px-4 pt-3 pb-3 md:border-0 md:px-8 md:pt-5 lg:hidden">
      <div className="mb-3 flex items-center justify-between md:hidden">
        <Link href="/" aria-label="In my bush — accueil" className="flex no-underline">
          <Logo size="sm" />
        </Link>
        <div className="flex items-center gap-1">
          <Link
            href="/compte/notifications"
            aria-label={`Notifications, ${notificationCount} non lues`}
            className="relative flex size-11 items-center justify-center rounded-md text-ink hover:bg-sand hover:text-ink"
          >
            <Icon name="bell" size={22} />
            {notificationCount > 0 && <CountBadge count={notificationCount} ring className="absolute top-1 right-0.5" />}
          </Link>
          <Link
            href="/panier"
            aria-label={`Panier, ${cartCount} articles`}
            className="relative flex size-11 items-center justify-center rounded-md text-ink hover:bg-sand hover:text-ink"
          >
            <Icon name="cart" size={22} />
            {cartCount > 0 && <CountBadge count={cartCount} ring className="absolute top-1 right-0.5" />}
          </Link>
        </div>
      </div>
      <div className="flex items-center gap-3">
        <HeaderSearch id="compact-search" placeholder="Tomates, miel, producteurs…" location="Analakely" compact />
        <Link
          href="/compte/notifications"
          aria-label="Notifications"
          className="relative hidden size-[52px] shrink-0 items-center justify-center rounded-[14px] border-[1.5px] border-line-strong bg-white text-ink hover:text-ink md:flex"
        >
          <Icon name="bell" size={22} />
          {notificationCount > 0 && <CountBadge count={notificationCount} ring className="absolute -top-1.5 -right-1.5" />}
        </Link>
      </div>
    </header>
  );
}
