"use client";

import Link from "next/link";
import { useState } from "react";
import { cn } from "@/lib/cn";
import { formatAriary, formatDiscount } from "@/lib/format";
import type { ProductSummary } from "@/lib/types";
import { Icon } from "@/components/ui/Icon";
import { RatingInline } from "@/components/ui/Rating";
import { useToast } from "@/components/ui/Toast";
import { ROUTES } from "@/lib/routing/routes";

/** Product card (ProductCard.dc.html): photo, promo, favourite, seller · place, rating, price / unit, quick add. */
export function ProductCard({ product, href, className }: { product: ProductSummary; href?: string; className?: string }) {
  const [fav, setFav] = useState(!!product.isFavorite);
  const [added, setAdded] = useState(false);
  const toast = useToast();
  const out = product.stockLevel === "OUT";
  const low = product.stockLevel === "LOW";
  const link = href ?? ROUTES.product(product.slug);
  const v = product.visual;

  return (
    <article
      className={cn(
        "group relative flex flex-col overflow-hidden rounded-lg border border-line bg-white shadow-card transition-[box-shadow,border-color] duration-200 hover:border-pomme-300 hover:shadow-card-hover",
        className,
      )}
    >
      <div className="relative flex aspect-[1/0.86] items-center justify-center" style={{ background: v.tint, color: v.ink }}>
        <span className="flex opacity-55" aria-hidden>
          <Icon name={v.icon} size={56} />
        </span>
        <span className="absolute bottom-2 left-2.5 text-[10px] font-bold tracking-[0.08em] uppercase opacity-70">
          Photo · {v.label ?? product.name}
        </span>
        {product.compareAtPrice && (
          <span className="absolute top-2.5 left-2.5 rounded-[6px] bg-orange-500 px-2 py-1 text-[11px] font-extrabold text-on-secondary">
            {formatDiscount(product.price, product.compareAtPrice)}
          </span>
        )}
        <button
          type="button"
          aria-label={fav ? `Retirer ${product.name} des favoris` : `Ajouter ${product.name} aux favoris`}
          aria-pressed={fav}
          onClick={() => setFav(!fav)}
          className="absolute top-1 right-1 z-10 flex size-11 items-center justify-center"
        >
          <span
            className={cn(
              "flex size-[34px] items-center justify-center rounded-full bg-white/95 shadow-[0_1px_3px_rgba(31,35,24,0.12)]",
              fav ? "text-orange-600" : "text-ink",
            )}
          >
            <Icon name={fav ? "heartF" : "heart"} size={18} />
          </span>
        </button>
        {out && (
          <span className="absolute inset-0 flex items-center justify-center bg-[rgba(251,250,246,0.62)]">
            <span className="rounded-full bg-ink px-3 py-1.5 text-[12px] font-bold text-white">Rupture de stock</span>
          </span>
        )}
        {low && product.stockLabel && (
          <span className="absolute right-2.5 bottom-2 rounded-[6px] bg-orange-100 px-2 py-[3px] text-[11px] font-bold text-orange-700">
            {product.stockLabel}
          </span>
        )}
      </div>
      <div className="flex flex-col gap-1.5 py-3 pr-3 pl-3.5">
        <div className="flex min-w-0 items-center gap-1 text-[12px] text-muted">
          <Icon name="pin" size={13} />
          <span className="truncate">
            {product.shop.name} · {product.shop.city}
          </span>
        </div>
        <Link
          href={link}
          className="line-clamp-2 min-h-10 text-[15px] leading-5 font-semibold text-ink no-underline after:absolute after:inset-0 hover:text-ink"
        >
          {product.name}
        </Link>
        <RatingInline value={product.ratingAvg} count={product.ratingCount} />
        <div className="mt-0.5 flex items-end justify-between gap-2">
          <div className="flex min-w-0 flex-col">
            {product.compareAtPrice && (
              <span className="text-[12px] text-muted line-through font-tabular">{formatAriary(product.compareAtPrice)}</span>
            )}
            <div className="flex flex-wrap items-baseline gap-[3px]">
              <span
                className={cn(
                  "text-[17px] font-bold font-tabular",
                  out ? "text-muted" : product.compareAtPrice ? "text-orange-700" : "text-ink",
                )}
              >
                {formatAriary(product.price)}
              </span>
              <span className="text-[12px] text-muted">/ {product.unitLabel}</span>
            </div>
          </div>
          {out ? (
            <button
              type="button"
              aria-label={`M’alerter du retour en stock de ${product.name}`}
              onClick={() => toast.show({ tone: "info", title: "Alerte activée", description: `Nous vous prévenons dès le retour de « ${product.name} ».` })}
              className="relative z-10 flex size-11 shrink-0 items-center justify-center rounded-md border-[1.5px] border-line-strong bg-white text-body"
            >
              <Icon name="bell" size={20} />
            </button>
          ) : (
            <button
              type="button"
              aria-label={added ? `${product.name} ajouté au panier` : `Ajouter ${product.name} au panier`}
              onClick={() => {
                setAdded(!added);
                if (!added) toast.show({ title: "Ajouté au panier", description: `${product.name} · 1 ${product.unitLabel}` });
              }}
              className={cn(
                "relative z-10 flex size-11 shrink-0 items-center justify-center rounded-md transition-colors",
                added ? "bg-pomme-700 text-white" : "bg-pomme-500 text-on-primary hover:bg-[#7DB834]",
              )}
            >
              <Icon name={added ? "check" : "plus"} size={20} />
            </button>
          )}
        </div>
      </div>
    </article>
  );
}
