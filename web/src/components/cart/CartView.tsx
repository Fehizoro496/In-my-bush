"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { formatAriary, initials } from "@/lib/format";
import type { Cart } from "@/lib/types";
import { Alert, EmptyState } from "@/components/ui/Feedback";
import { Icon } from "@/components/ui/Icon";
import { PhotoPlaceholder } from "@/components/ui/Media";
import { QuantityStepper } from "@/components/ui/QuantityStepper";
import { ButtonLink } from "@/components/ui/Button";
import { Avatar } from "@/components/ui/Avatar";

/** Cart grouped by shop + order summary (W-Cart). */
export function CartView({ cart }: { cart: Cart }) {
  const [qty, setQty] = useState<Record<string, number>>(
    Object.fromEntries(cart.groups.flatMap((g) => g.items.map((i) => [i.id, i.quantity]))),
  );
  const [removed, setRemoved] = useState<string[]>([]);
  const [promo, setPromo] = useState("");

  const groups = cart.groups
    .map((g) => ({ ...g, items: g.items.filter((i) => !removed.includes(i.id)) }))
    .filter((g) => g.items.length > 0);
  const { count, subtotal, delivery } = useMemo(() => {
    let c = 0;
    let s = 0;
    for (const g of groups) for (const i of g.items) {
      c += qty[i.id] ?? 0;
      s += (qty[i.id] ?? 0) * i.product.price;
    }
    return { count: c, subtotal: s, delivery: groups.reduce((a, g) => a + g.deliveryFee, 0) };
  }, [groups, qty]);

  if (groups.length === 0) {
    return (
      <EmptyState
        icon="basket"
        title="Votre panier est vide"
        description="Les produits de saison vous attendent chez les producteurs près de chez vous."
        action={<ButtonLink href="/catalogue">Explorer le marché</ButtonLink>}
        className="py-12"
      />
    );
  }

  return (
    <div className="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_360px] lg:gap-8 xl:grid-cols-[minmax(0,1fr)_400px]">
      <div className="flex flex-col gap-[18px]">
        <div className="flex flex-wrap items-end justify-between gap-3">
          <h1 className="m-0 font-display text-[30px] font-extrabold tracking-[-0.025em] lg:text-[38px]">
            Mon panier <span className="font-semibold text-muted">({count})</span>
          </h1>
          <Link href="/catalogue" className="flex items-center gap-1.5 text-[15px] font-bold no-underline">
            <Icon name="arrowL" size={16} />
            Continuer mes achats
          </Link>
        </div>
        {groups.map((g) => (
          <section key={g.shop.id} aria-label={`Articles de ${g.shop.name}`} className="overflow-hidden rounded-xl border border-line bg-white">
            <div className="flex flex-wrap items-center gap-3 border-b border-divider bg-bg px-4 py-3.5 md:px-5">
              <Avatar initials={initials(g.shop.name)} color={g.shop.avatarColor} size={36} />
              <span className="flex min-w-0 flex-1 flex-col">
                <Link href={`/vendeurs/${g.shop.slug}`} className="text-[15px] font-bold text-ink no-underline hover:text-pomme-700">
                  {g.shop.name}
                </Link>
                <span className="text-[12px] text-muted">{g.shop.city === "Ambohimanga" ? g.shop.region : g.shop.city}</span>
              </span>
              <span className="flex items-center gap-1.5 text-[13px] font-bold text-pomme-700">
                <Icon name="truck" size={16} />
                {g.deliveryLabel}
              </span>
            </div>
            {g.items.map((it, idx) => (
              <div
                key={it.id}
                className={`grid grid-cols-[72px_minmax(0,1fr)_40px] items-center gap-x-3 gap-y-3 px-4 py-4 md:grid-cols-[88px_minmax(0,1fr)_140px_120px_44px] md:gap-[18px] md:px-5 ${idx > 0 ? "border-t border-divider" : ""}`}
              >
                <PhotoPlaceholder visual={it.product.visual} className="size-[72px] md:size-[88px]" />
                <div className="flex min-w-0 flex-col gap-1">
                  <Link href={`/produits/${it.product.slug}`} className="text-[16px] font-bold text-ink no-underline hover:text-pomme-700">
                    {it.product.name}
                  </Link>
                  <span className="text-[13px] text-muted">
                    {formatAriary(it.product.price)} / {it.product.unitLabel}
                  </span>
                  <button type="button" className="mt-0.5 self-start px-1 text-[12px] font-bold text-muted hover:text-ink">
                    Mettre de côté
                  </button>
                </div>
                <button
                  type="button"
                  aria-label={`Retirer ${it.product.name}`}
                  onClick={() => setRemoved([...removed, it.id])}
                  className="col-start-3 row-start-1 flex size-10 items-center justify-center rounded-[10px] text-muted hover:bg-sand md:col-start-5"
                >
                  <Icon name="trash" size={18} />
                </button>
                <QuantityStepper
                  size="sm"
                  value={qty[it.id] ?? 1}
                  onChange={(n) => setQty({ ...qty, [it.id]: n })}
                  label={`Quantité de ${it.product.name}`}
                  className="col-span-2 col-start-1 justify-self-start md:col-span-1 md:col-start-3 md:row-start-1"
                />
                <b className="col-start-2 row-start-2 text-right text-[17px] font-tabular md:col-start-4 md:row-start-1 col-span-2 md:col-span-1">
                  {formatAriary((qty[it.id] ?? 1) * it.product.price)}
                </b>
              </div>
            ))}
          </section>
        ))}
        {cart.unavailable.map((u) => (
          <Alert
            key={u.name}
            tone="danger"
            action={
              <Link href="/catalogue" className="font-bold text-danger-ink no-underline">
                Voir des alternatives
              </Link>
            }
          >
            <b>
              {u.name} ({u.quantityLabel})
            </b>{" "}
            ne sont plus disponibles et ont été retirés du panier.
          </Alert>
        ))}
      </div>

      <aside
        aria-label="Récapitulatif"
        className="flex flex-col gap-4 rounded-[24px] border border-line bg-white p-6 shadow-[0_6px_20px_rgba(31,35,24,0.06)] lg:sticky lg:top-6 lg:mt-[62px]"
      >
        <h2 className="m-0 font-display text-[22px] font-bold">Récapitulatif</h2>
        <form
          className="flex gap-2"
          onSubmit={(e) => {
            e.preventDefault();
          }}
        >
          <label htmlFor="promo" className="sr-only">
            Code promo
          </label>
          <input
            id="promo"
            value={promo}
            onChange={(e) => setPromo(e.target.value)}
            placeholder="Code promo"
            className="h-[46px] min-w-0 flex-1 rounded-[10px] border-[1.5px] border-dashed border-stone px-3 text-[15px] outline-none focus:border-solid focus:border-pomme-600"
          />
          <button type="submit" className="h-[46px] rounded-[10px] bg-ink px-3.5 text-[14px] font-bold text-white">
            Appliquer
          </button>
        </form>
        <dl className="m-0 flex flex-col gap-2.5 text-[15px]">
          <div className="flex justify-between">
            <dt className="text-body">Sous-total ({count} articles)</dt>
            <dd className="m-0 font-tabular">{formatAriary(subtotal)}</dd>
          </div>
          <div className="flex justify-between">
            <dt className="text-body">Livraison estimée · {groups.length} vendeurs</dt>
            <dd className="m-0 font-tabular">{formatAriary(delivery)}</dd>
          </div>
          <div className="flex items-baseline justify-between border-t border-divider pt-3">
            <dt className="text-[17px] font-bold">Total</dt>
            <dd className="m-0 font-display text-[30px] font-bold font-tabular">{formatAriary(subtotal + delivery)}</dd>
          </div>
        </dl>
        <ButtonLink href="/commande" size="xl" iconRight="arrowR">
          Passer commande
        </ButtonLink>
        <div className="flex flex-col gap-2.5 pt-1.5 text-[13px] text-body">
          <span className="flex items-center gap-2">
            <Icon name="shield" size={16} className="text-pomme-700" />
            Paiement protégé jusqu’à la réception
          </span>
          <span className="flex items-center gap-2">
            <Icon name="wallet" size={16} className="text-pomme-700" />
            Mobile Money ou paiement à la réception
          </span>
        </div>
      </aside>
    </div>
  );
}
