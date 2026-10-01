"use client";

import { useState } from "react";
import { cn } from "@/lib/cn";
import { formatAriary } from "@/lib/format";
import type { AdminOrderRow } from "@/lib/types";
import { StatusPill, type StatusTone } from "@/components/ui/Badge";
import { Select } from "@/components/ui/Form";
import { Icon } from "@/components/ui/Icon";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { TabList } from "@/components/ui/Tabs";

const STATUS: Record<AdminOrderRow["status"], { label: string; tone: StatusTone }> = {
  DELIVERED: { label: "Livrée", tone: "done" },
  IN_DELIVERY: { label: "En route", tone: "info" },
  PREPARING: { label: "Préparation", tone: "info" },
  PENDING: { label: "En attente", tone: "warning" },
  DISPUTE: { label: "Litige", tone: "danger" },
  CANCELLED: { label: "Annulée", tone: "neutral" },
};
const PAY: Record<AdminOrderRow["paymentStatus"], { label: string; cls: string }> = {
  HELD: { label: "Payé · séquestre", cls: "text-info-strong" },
  RELEASED: { label: "Versé au vendeur", cls: "text-pomme-700" },
  COD: { label: "À encaisser", cls: "text-orange-700" },
  REFUNDED: { label: "Remboursé", cls: "text-muted" },
};

/** Orders / transactions (A-Orders). */
export function OrdersAdmin({
  rows,
  stats,
}: {
  rows: AdminOrderRow[];
  stats: { label: string; value: string; delta: string; tone: "up" | "neutral" | "danger" }[];
}) {
  const [view, setView] = useState<"orders" | "transactions">("orders");
  const [dispute, setDispute] = useState(false);
  const shown = rows.filter((r) => (dispute ? r.status === "DISPUTE" : true));
  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-3">
        <h1 className="sr-only">Commandes</h1>
        <TabList
          variant="segmented-dark"
          label="Vue"
          value={view}
          onChange={setView}
          items={[
            { value: "orders", label: "Commandes", icon: "receipt" },
            { value: "transactions", label: "Transactions", icon: "wallet" },
          ]}
        />
        <Select
          aria-label="Période"
          size="sm"
          className="w-[210px] font-semibold"
          options={[
            { value: "sept", label: "1 – 28 sept. 2026" },
            { value: "aug", label: "Août 2026" },
          ]}
        />
      </div>
      <div className="grid grid-cols-2 gap-3.5 xl:grid-cols-4">
        {stats.map((k) => (
          <div key={k.label} className={cn("flex flex-col gap-1.5 rounded-lg border bg-white px-[18px] py-4", k.tone === "danger" ? "border-[#F1C7C2]" : "border-line")}>
            <span className="text-[13px] font-semibold text-body">{k.label}</span>
            <span className="font-display text-[24px] font-extrabold font-tabular md:text-[26px]">{k.value}</span>
            <span className={cn("text-[12px] font-bold", k.tone === "up" ? "text-pomme-700" : k.tone === "danger" ? "text-danger-fg" : "text-muted")}>{k.delta}</span>
          </div>
        ))}
      </div>
      <section className="overflow-hidden rounded-[18px] border border-line bg-white">
        <div className="flex flex-wrap items-center gap-2.5 border-b border-divider px-4 py-3">
          <label className="flex h-[38px] w-full items-center gap-2 rounded-[10px] border-[1.5px] border-line-strong px-3 text-[14px] text-muted sm:w-[300px]">
            <Icon name="search" size={16} />
            <span className="sr-only">Rechercher une commande</span>
            <input placeholder="N° commande, client, vendeur…" className="min-w-0 flex-1 border-0 bg-transparent text-ink outline-none focus-visible:outline-none" />
          </label>
          <Select aria-label="Statut" size="sm" className="h-[38px] w-[150px] text-[13px] font-semibold" options={[{ value: "", label: "Statut : tous" }, ...Object.entries(STATUS).map(([v, s]) => ({ value: v, label: s.label }))]} />
          <Select aria-label="Paiement" size="sm" className="h-[38px] w-[170px] text-[13px] font-semibold" options={[{ value: "", label: "Paiement : tous" }, ...Object.entries(PAY).map(([v, s]) => ({ value: v, label: s.label }))]} />
          <button
            type="button"
            aria-pressed={dispute}
            onClick={() => setDispute(!dispute)}
            className={cn(
              "h-[38px] rounded-[10px] border-[1.5px] px-3 text-[13px] font-semibold",
              dispute ? "border-danger-fg bg-danger-bg text-danger-ink" : "border-line-strong bg-white text-ink",
            )}
          >
            Litiges uniquement
          </button>
        </div>
        <Table minWidth={900}>
          <THead>
            <Th>{view === "orders" ? "Commande" : "Transaction"}</Th>
            <Th>Client</Th>
            <Th>Vendeur(s)</Th>
            <Th className="text-right">Total</Th>
            <Th>Paiement</Th>
            <Th>Statut</Th>
            <Th>
              <span className="sr-only">Actions</span>
            </Th>
          </THead>
          <tbody>
            {shown.map((r) => (
              <Tr key={r.id}>
                <Td>
                  <b>{view === "orders" ? r.number : `TX-${r.number.slice(4)}`}</b>
                  <div className="text-[12px] text-muted">{r.dateLabel}</div>
                </Td>
                <Td>{r.client}</Td>
                <Td className="text-body">{r.sellers}</Td>
                <Td className="text-right font-bold font-tabular">{formatAriary(r.total)}</Td>
                <Td>
                  <div className="flex flex-col">
                    <span>{r.paymentMethod}</span>
                    <span className={cn("text-[12px] font-bold", PAY[r.paymentStatus].cls)}>{PAY[r.paymentStatus].label}</span>
                  </div>
                </Td>
                <Td>
                  <StatusPill tone={STATUS[r.status].tone} size="sm">
                    {STATUS[r.status].label}
                  </StatusPill>
                </Td>
                <Td>
                  <div className="flex justify-end gap-1">
                    <button type="button" aria-label={`Voir ${r.number}`} className="flex size-[34px] items-center justify-center rounded-lg text-body hover:bg-sand">
                      <Icon name="eye" size={17} />
                    </button>
                    <button type="button" aria-label="Plus d’actions" className="flex size-[34px] items-center justify-center rounded-lg text-body hover:bg-sand">
                      <Icon name="more" size={17} />
                    </button>
                  </div>
                </Td>
              </Tr>
            ))}
          </tbody>
        </Table>
        <div className="flex items-center justify-between border-t border-divider px-4 py-3 text-[13px] text-muted">
          <span>1–{shown.length} sur 3 942</span>
          <div className="flex items-center gap-1.5">
            <button type="button" aria-current="page" className="size-[34px] rounded-lg bg-ink font-bold text-white">
              1
            </button>
            <button type="button" className="size-[34px] rounded-lg border-[1.5px] border-line-strong bg-white font-bold text-ink">
              2
            </button>
            <span className="w-6 text-center">…</span>
            <button type="button" className="h-[34px] min-w-10 rounded-lg border-[1.5px] border-line-strong bg-white px-2 font-bold text-ink">
              438
            </button>
          </div>
        </div>
      </section>
    </>
  );
}
