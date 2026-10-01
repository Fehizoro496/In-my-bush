"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { cn } from "@/lib/cn";
import { formatAriary, initials } from "@/lib/format";
import type { CheckoutDraft, DeliveryMode } from "@/lib/types";
import { Avatar } from "@/components/ui/Avatar";
import { Button } from "@/components/ui/Button";
import { Icon, type IconName } from "@/components/ui/Icon";
import { Input, RadioIndicator, Select } from "@/components/ui/Form";
import { PhotoPlaceholder } from "@/components/ui/Media";

type Pay = "mm" | "card" | "cod";

const PAYMENTS: { value: Pay; title: string; detail: string; icon: IconName; disabled?: boolean }[] = [
  { value: "mm", title: "Mobile Money", detail: "MVola, Orange Money, Airtel Money", icon: "wallet" },
  { value: "card", title: "Carte bancaire", detail: "Visa, Mastercard · bientôt disponible", icon: "card", disabled: true },
  { value: "cod", title: "À la réception", detail: "Espèces au livreur", icon: "package" },
];

function choiceCls(on: boolean) {
  return on ? "border-[1.5px] border-pomme-500 bg-pomme-50" : "border border-line bg-white hover:border-pebble";
}

/** Address, per-shop delivery mode, payment and summary (W-Checkout). */
export function CheckoutForm({ draft }: { draft: CheckoutDraft }) {
  const router = useRouter();
  const [address, setAddress] = useState(draft.addresses.find((a) => a.isDefault)?.id ?? draft.addresses[0]?.id);
  const [modes, setModes] = useState<Record<string, DeliveryMode>>(Object.fromEntries(draft.groups.map((g) => [g.shop.id, "HOME"])));
  const [pay, setPay] = useState<Pay>("mm");
  const [promoOn, setPromoOn] = useState(!!draft.promo);
  const [submitting, setSubmitting] = useState(false);

  const delivery = draft.groups.reduce((s, g) => s + (modes[g.shop.id] === "HOME" ? g.homeFee : 0), 0);
  const discount = promoOn && draft.promo ? draft.promo.amount : 0;
  const total = draft.subtotal + delivery - discount;

  return (
    <form
      className="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_380px] lg:gap-10 xl:grid-cols-[minmax(0,1fr)_420px]"
      onSubmit={(e) => {
        e.preventDefault();
        setSubmitting(true);
        // TODO(api): ordersApi.checkout({ addressId, deliveryModes, payment }) via a server action.
        router.push("/commande/confirmation");
      }}
    >
      <div className="flex flex-col gap-6 lg:gap-7">
        <h1 className="m-0 font-display text-[28px] font-extrabold tracking-[-0.025em] lg:text-[36px]">Livraison &amp; paiement</h1>

        <section className="flex flex-col gap-4 rounded-xl border border-line bg-white p-5 md:p-6">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <h2 className="m-0 text-[19px] font-bold">1 · Adresse de livraison</h2>
            <Button variant="soft" size="sm" icon="plus" className="h-10 rounded-[10px]">
              Nouvelle adresse
            </Button>
          </div>
          <div role="radiogroup" aria-label="Adresse de livraison" className="grid gap-3.5 md:grid-cols-2">
            {draft.addresses.map((a) => {
              const on = a.id === address;
              return (
                <button
                  key={a.id}
                  type="button"
                  role="radio"
                  aria-checked={on}
                  onClick={() => setAddress(a.id)}
                  className={cn("flex gap-3 rounded-lg p-4 text-left text-ink", choiceCls(on))}
                >
                  <span className="mt-0.5">
                    <RadioIndicator checked={on} />
                  </span>
                  <span className="flex flex-col gap-0.5 text-[14px] leading-5">
                    <b className="text-[15px]">{a.label}</b>
                    <span className="text-body">
                      {a.line1}, {a.district}, {a.city}
                    </span>
                    <span className="text-muted">{a.phone}</span>
                  </span>
                </button>
              );
            })}
          </div>
        </section>

        <section className="flex flex-col gap-4 rounded-xl border border-line bg-white p-5 md:p-6">
          <h2 className="m-0 text-[19px] font-bold">2 · Réception par vendeur</h2>
          {draft.groups.map((g) => (
            <div key={g.shop.id} className="overflow-hidden rounded-lg border border-line">
              <div className="flex items-center gap-2.5 bg-bg px-4 py-3">
                <Avatar initials={initials(g.shop.name)} color={g.shop.avatarColor} size={30} />
                <b className="flex-1 text-[15px]">{g.shop.name}</b>
                <span className="text-[13px] text-muted">{g.itemCount} articles</span>
              </div>
              <div role="radiogroup" aria-label={`Réception pour ${g.shop.name}`} className="grid gap-3 p-3.5 md:grid-cols-2 md:px-4">
                {(["HOME", "PICKUP"] as const).map((m) => {
                  const on = modes[g.shop.id] === m;
                  return (
                    <button
                      key={m}
                      type="button"
                      role="radio"
                      aria-checked={on}
                      onClick={() => setModes({ ...modes, [g.shop.id]: m })}
                      className={cn("flex flex-col gap-0.5 rounded-md px-3.5 py-3 text-left text-ink", choiceCls(on))}
                    >
                      <b className="flex justify-between gap-2 text-[14px]">
                        {m === "HOME" ? "Livraison à domicile" : "Retrait sur place"}
                        {m === "HOME" ? <span>{formatAriary(g.homeFee)}</span> : <span className="text-pomme-700">Gratuit</span>}
                      </b>
                      <span className={cn("text-[13px]", on ? "text-body" : "text-muted")}>{m === "HOME" ? g.homeSlot : g.pickupInfo}</span>
                    </button>
                  );
                })}
              </div>
            </div>
          ))}
        </section>

        <section className="flex flex-col gap-4 rounded-xl border border-line bg-white p-5 md:p-6">
          <h2 className="m-0 text-[19px] font-bold">3 · Paiement</h2>
          <div role="radiogroup" aria-label="Moyen de paiement" className="grid gap-3.5 md:grid-cols-3">
            {PAYMENTS.map((m) => {
              const on = pay === m.value;
              return (
                <button
                  key={m.value}
                  type="button"
                  role="radio"
                  aria-checked={on}
                  aria-disabled={m.disabled}
                  onClick={() => !m.disabled && setPay(m.value)}
                  className={cn("flex flex-col gap-2.5 rounded-lg p-4 text-left text-ink", choiceCls(on), m.disabled && "cursor-not-allowed opacity-60")}
                >
                  <span className="flex w-full items-center justify-between">
                    <span className="flex size-10 items-center justify-center rounded-md border border-line bg-white">
                      <Icon name={m.icon} size={20} />
                    </span>
                    <RadioIndicator checked={on} />
                  </span>
                  <b className="text-[15px]">{m.title}</b>
                  <span className="text-[13px] text-muted">{m.detail}</span>
                </button>
              );
            })}
          </div>
          {pay === "mm" && (
            <div className="grid gap-3.5 md:grid-cols-2">
              <Select
                label="Opérateur"
                options={[
                  { value: "MVOLA", label: "MVola" },
                  { value: "ORANGE_MONEY", label: "Orange Money" },
                  { value: "AIRTEL_MONEY", label: "Airtel Money" },
                ]}
              />
              <Input label="Numéro" type="tel" inputMode="tel" placeholder="+261 34 00 000 00" autoComplete="tel" required />
            </div>
          )}
        </section>
      </div>

      <aside
        aria-label="Récapitulatif"
        className="flex flex-col gap-4 rounded-[24px] border border-line bg-white p-6 shadow-[0_6px_20px_rgba(31,35,24,0.06)] lg:sticky lg:top-6"
      >
        <h2 className="m-0 font-display text-[22px] font-bold">Récapitulatif</h2>
        {draft.lines.map((l) => (
          <div key={l.name} className="flex items-center gap-3">
            <span className="relative">
              <PhotoPlaceholder visual={l.visual} iconSize={22} className="size-[52px]" rounded="rounded-md" />
              <span className="absolute -top-1.5 -right-1.5 flex h-5 min-w-5 items-center justify-center rounded-full bg-ink px-1 text-[11px] font-extrabold text-white">
                {l.quantity}
              </span>
            </span>
            <span className="flex min-w-0 flex-1 flex-col">
              <b className="text-[14px]">{l.name}</b>
              <span className="text-[12px] text-muted">{l.shopName}</span>
            </span>
            <b className="text-[14px] font-tabular">{formatAriary(l.total)}</b>
          </div>
        ))}
        {draft.promo && promoOn && (
          <div className="flex gap-2">
            <div className="flex h-11 flex-1 items-center gap-2 rounded-[10px] border-[1.5px] border-pomme-600 bg-pomme-50 px-3 text-[14px] font-bold text-pomme-800">
              <Icon name="tag" size={16} />
              {draft.promo.code}
            </div>
            <button
              type="button"
              aria-label="Retirer le code"
              onClick={() => setPromoOn(false)}
              className="flex size-11 items-center justify-center rounded-[10px] border-[1.5px] border-line-strong bg-white text-muted"
            >
              <Icon name="x" size={16} />
            </button>
          </div>
        )}
        <dl className="m-0 flex flex-col gap-2.5 border-t border-divider pt-3 text-[15px]">
          <div className="flex justify-between">
            <dt className="text-body">Sous-total</dt>
            <dd className="m-0 font-tabular">{formatAriary(draft.subtotal)}</dd>
          </div>
          <div className="flex justify-between">
            <dt className="text-body">Livraison · {draft.groups.length} vendeurs</dt>
            <dd className="m-0 font-tabular">{formatAriary(delivery)}</dd>
          </div>
          {discount > 0 && (
            <div className="flex justify-between text-orange-700">
              <dt>{draft.promo!.label}</dt>
              <dd className="m-0 font-tabular">{formatAriary(-discount)}</dd>
            </div>
          )}
          <div className="flex items-baseline justify-between border-t border-divider pt-2.5">
            <dt className="text-[17px] font-bold">Total</dt>
            <dd className="m-0 font-display text-[30px] font-bold font-tabular">{formatAriary(total)}</dd>
          </div>
        </dl>
        <Button type="submit" size="xl" icon="lock" loading={submitting}>
          Payer {formatAriary(total)}
        </Button>
        <span className="flex gap-2 text-[13px] leading-[19px] text-muted">
          <Icon name="shield" size={16} className="text-pomme-700" />
          Le montant est conservé par In my bush et versé à chaque vendeur après réception.
        </span>
      </aside>
    </form>
  );
}
