import Link from "next/link";
import { formatRating, initials } from "@/lib/format";
import type { ShopSummary } from "@/lib/types";
import { Icon } from "@/components/ui/Icon";

/** Seller card (SellerCard.dc.html). */
export function SellerCard({ shop, href }: { shop: ShopSummary; href?: string }) {
  const since = new Date(shop.createdAt).getFullYear();
  return (
    <article className="flex flex-col overflow-hidden rounded-lg border border-line bg-white">
      <div className="relative h-[76px]" style={{ background: shop.cover.tint }}>
        <span
          className="absolute top-2 right-2.5 text-[10px] font-bold tracking-[0.08em] uppercase opacity-70"
          style={{ color: shop.cover.ink }}
        >
          Photo · exploitation
        </span>
      </div>
      <div className="relative -mt-[30px] flex flex-col gap-2.5 px-4 pb-4">
        <div className="flex items-end justify-between">
          <span className="size-[60px] rounded-full bg-white p-[3px] shadow-[0_2px_6px_rgba(31,35,24,0.12)]">
            <span
              className="flex size-full items-center justify-center rounded-full font-display text-[20px] font-extrabold text-white"
              style={{ background: shop.avatarColor }}
            >
              {initials(shop.name)}
            </span>
          </span>
          {shop.verified && (
            <span className="flex items-center gap-1 rounded-[6px] bg-pomme-100 px-2 py-1 text-[11px] font-bold text-pomme-700">
              <Icon name="shield" size={13} />
              Vérifié
            </span>
          )}
        </div>
        <div className="flex flex-col gap-[3px]">
          <h3 className="m-0 font-display text-[18px] font-bold tracking-[-0.01em]">{shop.name}</h3>
          <span className="flex items-center gap-1 text-[13px] text-muted">
            <Icon name="pin" size={14} />
            {shop.city === shop.region ? shop.city : `${shop.city}, ${shop.region}`}
          </span>
        </div>
        <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-[13px] text-body">
          <span className="flex items-center gap-1">
            <Icon name="star" size={14} className="text-orange-500" />
            <b className="text-ink">{formatRating(shop.ratingAvg)}</b> ({shop.ratingCount})
          </span>
          <span>{shop.productCount} produits</span>
          <span>Depuis {since}</span>
        </div>
        <div className="flex flex-wrap gap-1.5">
          {shop.tags.map((t) => (
            <span key={t} className="rounded-[6px] bg-sand px-2 py-1 text-[12px] font-semibold text-body">
              {t}
            </span>
          ))}
        </div>
        <Link
          href={href ?? `/vendeurs/${shop.slug}`}
          className="mt-1 flex h-11 items-center justify-center gap-1.5 rounded-[10px] border-[1.5px] border-pomme-300 text-[14px] font-bold text-pomme-800 no-underline hover:bg-pomme-50 hover:text-pomme-800"
        >
          Voir la boutique
          <Icon name="arrowR" size={16} />
        </Link>
      </div>
    </article>
  );
}
