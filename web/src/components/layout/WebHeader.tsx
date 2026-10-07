import Link from "next/link";
import { Suspense } from "react";
import { Icon } from "@/components/ui/Icon";
import { CountBadge } from "@/components/ui/Badge";
import { Avatar } from "@/components/ui/Avatar";
import { initials } from "@/lib/format";
import { CategoryLinks, HeaderCategoryLinks, type HeaderCategory } from "./HeaderCategoryNav";
import { Logo } from "./Logo";

export interface HeaderUser {
  firstName: string;
  lastName: string;
}

/** Search form used by every header (GET /recherche?q=). */
export function HeaderSearch({
  placeholder = "Rechercher un produit, un producteur, une région…",
  location = "Antananarivo",
  id = "header-search",
  compact = false,
}: {
  placeholder?: string;
  location?: string;
  id?: string;
  compact?: boolean;
}) {
  return (
    <form
      role="search"
      action="/recherche"
      className="flex h-12 min-w-0 flex-1 items-center gap-2.5 rounded-md border-[1.5px] border-line-strong bg-bg pr-1.5 pl-3.5 focus-within:border-pomme-600 focus-within:shadow-[0_0_0_4px_rgba(140,198,63,0.22)] md:h-[52px] lg:h-12"
    >
      <Icon name="search" size={20} className="text-muted" />
      <label htmlFor={id} className="sr-only">
        Rechercher
      </label>
      <input
        id={id}
        name="q"
        type="search"
        placeholder={placeholder}
        className="h-full min-w-0 flex-1 border-0 bg-transparent text-[15px] text-ink outline-none focus-visible:outline-none"
      />
      <button
        type="button"
        className={
          compact
            ? "hidden h-9 shrink-0 items-center gap-1.5 border-l border-line-strong px-2.5 text-[13px] font-semibold text-body sm:flex"
            : "hidden h-9 shrink-0 items-center gap-1.5 border-l border-line-strong px-3 text-[13px] font-semibold text-body xl:flex"
        }
        aria-label={`Zone de livraison : ${location}`}
      >
        <Icon name="pin" size={16} />
        {location}
      </button>
      <button
        type="submit"
        aria-label="Lancer la recherche"
        className="flex size-[38px] shrink-0 items-center justify-center rounded-sm bg-pomme-500 text-on-primary hover:bg-[#7DB834]"
      >
        <Icon name="arrowR" size={18} />
      </button>
    </form>
  );
}

/** Desktop header (≥ 1024 px): 80 px main row + 48 px category row = 128 px. */
export function WebHeader({
  user,
  cartCount,
  categories,
}: {
  user: HeaderUser | null;
  cartCount: number;
  categories: HeaderCategory[];
}) {
  return (
    <header className="sticky top-0 z-40 hidden border-b border-line bg-white lg:block">
      <div className="mx-auto flex h-20 max-w-[1440px] items-center gap-4 px-8 xl:gap-5 xl:px-20">
        <Link href="/" aria-label="In my bush — accueil" className="flex shrink-0 no-underline">
          <Logo />
        </Link>
        <Link
          href="/categories"
          className="flex h-11 shrink-0 items-center gap-2 rounded-[10px] bg-sand px-3.5 text-[14px] font-semibold text-ink no-underline hover:bg-divider hover:text-ink"
        >
          <Icon name="grid" size={18} />
          Catégories
          <Icon name="chevD" size={16} />
        </Link>
        <HeaderSearch />
        <Link
          href="/vendre"
          className="flex h-11 shrink-0 items-center gap-2 rounded-[10px] border-[1.5px] border-pomme-500 bg-pomme-50 px-4 text-[14px] font-bold text-pomme-800 no-underline hover:bg-mint hover:text-pomme-800"
        >
          <Icon name="store" size={18} />
          Vendre
        </Link>
        <nav aria-label="Compte" className="flex shrink-0 items-center gap-1">
          <Link
            href="/compte/favoris"
            className="flex h-[52px] w-16 flex-col items-center justify-center gap-0.5 text-[12px] font-medium text-ink no-underline hover:text-pomme-700"
          >
            <Icon name="heart" size={22} />
            Favoris
          </Link>
          <Link
            href="/panier"
            aria-label={`Panier, ${cartCount} article${cartCount > 1 ? "s" : ""}`}
            className="flex h-[52px] w-16 flex-col items-center justify-center gap-0.5 text-[12px] font-medium text-ink no-underline hover:text-pomme-700"
          >
            <span className="relative flex">
              <Icon name="cart" size={22} />
              {cartCount > 0 && <CountBadge count={cartCount} ring className="absolute -top-1.5 -right-2.5" />}
            </span>
            Panier
          </Link>
          {user ? (
            <Link href="/compte" className="flex h-[52px] items-center gap-2 pl-2 text-ink no-underline hover:text-ink">
              <Avatar initials={initials(`${user.firstName} ${user.lastName}`)} color="#365A10" size={36} />
              <span className="flex flex-col text-[12px] leading-[15px]">
                <span className="text-muted">Bonjour</span>
                <b className="text-[13px]">{user.firstName}</b>
              </span>
            </Link>
          ) : (
            <Link
              href="/connexion"
              className="flex h-[52px] items-center gap-2 pl-2 text-[14px] font-bold text-ink no-underline hover:text-pomme-700"
            >
              <Icon name="user" size={22} />
              Connexion
            </Link>
          )}
        </nav>
      </div>
      <nav aria-label="Catégories" className="border-t border-divider">
        <div className="mx-auto flex h-12 max-w-[1440px] items-center justify-between gap-4 px-8 xl:px-20">
          <Suspense fallback={<CategoryLinks categories={categories} active={null} />}>
            <HeaderCategoryLinks categories={categories} />
          </Suspense>
          <span className="hidden shrink-0 items-center gap-1.5 text-[13px] font-semibold whitespace-nowrap text-pomme-700 xl:flex">
            <Icon name="truck" size={18} />
            Livraison en 24–48 h · Antananarivo
          </span>
        </div>
      </nav>
    </header>
  );
}
