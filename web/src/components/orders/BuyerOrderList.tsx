"use client";

import { useState } from "react";
import { formatAriary, formatDate } from "@/lib/format";
import type { BuyerOrderSummary } from "@/lib/types";
import { OrderStatusPill } from "@/components/ui/Badge";
import { ButtonLink } from "@/components/ui/Button";
import { EmptyState } from "@/components/ui/Feedback";
import { PhotoPlaceholder } from "@/components/ui/Media";
import { StepBar } from "@/components/ui/Navigation";
import { TabList } from "@/components/ui/Tabs";

type Tab = "all" | "progress" | "delivered" | "cancelled";
const TRACK = [{ label: "Confirmée" }, { label: "Préparation" }, { label: "En route" }, { label: "Livrée" }];
const IN_PROGRESS = ["PENDING_CONFIRMATION", "ACCEPTED", "PREPARED", "IN_DELIVERY"];

/** Buyer orders with status tabs (W-Account). */
export function BuyerOrderList({ orders }: { orders: BuyerOrderSummary[] }) {
  const [tab, setTab] = useState<Tab>("all");
  const inProgress = orders.filter((o) => IN_PROGRESS.includes(o.status)).length;
  const shown = orders.filter((o) =>
    tab === "all"
      ? true
      : tab === "progress"
        ? IN_PROGRESS.includes(o.status)
        : tab === "delivered"
          ? o.status === "DELIVERED"
          : o.status === "CANCELLED" || o.status === "REFUSED",
  );

  return (
    <div className="flex flex-col gap-5">
      <TabList
        label="Filtrer les commandes"
        value={tab}
        onChange={setTab}
        items={[
          { value: "all", label: "Toutes" },
          { value: "progress", label: `En cours (${inProgress})` },
          { value: "delivered", label: "Livrées" },
          { value: "cancelled", label: "Annulées" },
        ]}
      />
      {shown.length === 0 && <EmptyState icon="package" title="Aucune commande" description="Aucune commande dans cette catégorie." />}
      {shown.map((o) => {
        const href = `/compte/commandes/${o.id}`;
        return (
          <article key={o.id} className="overflow-hidden rounded-xl border border-line bg-white">
            <div className="grid grid-cols-2 items-center gap-4 border-b border-divider bg-bg px-4 py-4 text-[14px] md:grid-cols-[repeat(4,minmax(0,1fr))_auto] md:px-[22px]">
              {[
                ["Commande", o.number],
                ["Passée le", formatDate(o.createdAt)],
                ["Total", formatAriary(o.total)],
                ["Paiement", o.paymentLabel],
              ].map(([k, v]) => (
                <div key={k} className="flex flex-col gap-0.5">
                  <span className="text-[12px] text-muted">{k}</span>
                  <b className="font-tabular">{v}</b>
                </div>
              ))}
              <span className="col-span-2 md:col-span-1">
                <OrderStatusPill status={o.status} />
              </span>
            </div>
            <div className="grid items-center gap-6 px-4 py-[18px] md:grid-cols-[minmax(0,1fr)_240px] md:px-[22px] xl:grid-cols-[minmax(0,1fr)_260px]">
              <div className="flex flex-col gap-3">
                <div className="flex gap-2.5">
                  {o.thumbnails.map((t, i) => (
                    <PhotoPlaceholder key={i} visual={t} iconSize={26} className="size-16" rounded="rounded-md" />
                  ))}
                </div>
                <span className="text-[14px] text-body">{o.summary}</span>
                {o.progress !== null && <StepBar steps={TRACK} current={o.progress} className="max-w-[520px]" />}
              </div>
              <div className="flex flex-col gap-2">
                {o.status === "IN_DELIVERY" && (
                  <>
                    <ButtonLink href={href} icon="truck" size="md" className="h-[42px] text-[14px]">
                      Suivre la livraison
                    </ButtonLink>
                    <ButtonLink href="/compte/messages" variant="neutral" icon="msg" size="md" className="h-[42px] text-[14px]">
                      Contacter les vendeurs
                    </ButtonLink>
                  </>
                )}
                {(o.status === "ACCEPTED" || o.status === "PENDING_CONFIRMATION" || o.status === "PREPARED") && (
                  <>
                    <ButtonLink href={href} variant="neutral" icon="eye" size="md" className="h-[42px] text-[14px]">
                      Voir le détail
                    </ButtonLink>
                    <button type="button" className="flex h-[42px] items-center justify-center gap-1.5 rounded-[10px] text-[14px] font-bold text-danger-fg hover:bg-danger-bg">
                      Annuler
                    </button>
                  </>
                )}
                {o.status === "DELIVERED" && (
                  <>
                    <ButtonLink href="/compte/avis" icon="starO" size="md" className="h-[42px] text-[14px]">
                      Laisser un avis
                    </ButtonLink>
                    <ButtonLink href="/panier" variant="neutral" icon="refresh" size="md" className="h-[42px] text-[14px]">
                      Racheter
                    </ButtonLink>
                    <button type="button" className="flex h-[42px] items-center justify-center gap-1.5 rounded-[10px] text-[14px] font-bold text-body hover:bg-sand">
                      Facture
                    </button>
                  </>
                )}
                {(o.status === "CANCELLED" || o.status === "REFUSED") && (
                  <ButtonLink href={href} variant="neutral" icon="eye" size="md" className="h-[42px] text-[14px]">
                    Voir le détail
                  </ButtonLink>
                )}
              </div>
            </div>
          </article>
        );
      })}
    </div>
  );
}
