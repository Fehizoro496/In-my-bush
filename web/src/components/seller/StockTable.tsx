"use client";

import Link from "next/link";
import { useState } from "react";
import { cn } from "@/lib/cn";
import { formatAriary } from "@/lib/format";
import type { SellerProductRow } from "@/lib/types";
import { StatusPill, type StatusTone } from "@/components/ui/Badge";
import { ChipGroup } from "@/components/ui/Chip";
import { CheckIndicator, Select } from "@/components/ui/Form";
import { Icon } from "@/components/ui/Icon";
import { PhotoPlaceholder } from "@/components/ui/Media";
import { QuantityStepper } from "@/components/ui/QuantityStepper";
import { Switch } from "@/components/ui/Switch";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { ROUTES } from "@/lib/routing/routes";

type Level = "ok" | "low" | "out" | "wait" | "draft";
const LEVEL: Record<Level, { label: string; tone: StatusTone }> = {
  ok: { label: "En ligne", tone: "done" },
  low: { label: "Stock faible", tone: "warning" },
  out: { label: "Rupture", tone: "neutral" },
  wait: { label: "En validation", tone: "info" },
  draft: { label: "Brouillon", tone: "neutral" },
};

/** Products & stock table with inline stock steppers, visibility and bulk actions (W-Stock). */
export function StockTable({ rows }: { rows: SellerProductRow[] }) {
  const [stock, setStock] = useState<Record<string, number>>(Object.fromEntries(rows.map((r) => [r.id, r.stock])));
  const [visible, setVisible] = useState<Record<string, boolean>>(Object.fromEntries(rows.map((r) => [r.id, r.visible])));
  const [sel, setSel] = useState<string[]>(["sp-b", "sp-d"]);
  const [tab, setTab] = useState("all");
  const [q, setQ] = useState("");

  const level = (r: SellerProductRow): Level => {
    if (r.status === "PENDING_REVIEW") return "wait";
    if (r.status === "DRAFT") return "draft";
    const s = stock[r.id] ?? 0;
    return s === 0 ? "out" : s <= r.lowStockThreshold ? "low" : "ok";
  };
  const shown = rows.filter((r) => {
    const l = level(r);
    const byTab = tab === "all" || (tab === "online" && (l === "ok" || l === "low")) || (tab === "wait" && l === "wait") || (tab === "draft" && l === "draft") || (tab === "out" && l === "out");
    return byTab && r.name.toLowerCase().includes(q.toLowerCase());
  });
  const all = shown.length > 0 && shown.every((r) => sel.includes(r.id));

  return (
    <div className="flex flex-col gap-[18px]">
      <ChipGroup
        label="Statut"
        variant="dark"
        value={tab}
        onChange={setTab}
        className="flex-nowrap overflow-x-auto scrollbar-none"
        options={[
          { value: "all", label: "Tous (14)" },
          { value: "online", label: "En ligne (10)" },
          { value: "wait", label: "En validation (1)" },
          { value: "draft", label: "Brouillons (2)" },
          { value: "out", label: "Rupture (1)" },
        ]}
      />
      <section className="overflow-hidden rounded-xl border border-line bg-white">
        <div className="flex flex-wrap items-center gap-2.5 border-b border-divider px-4 py-3.5 md:px-[18px]">
          <label className="flex h-10 max-w-[320px] min-w-[200px] flex-1 items-center gap-2 rounded-[10px] border-[1.5px] border-line-strong px-3 text-[14px] text-muted">
            <Icon name="search" size={16} />
            <span className="sr-only">Rechercher un produit</span>
            <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Rechercher un produit" className="min-w-0 flex-1 border-0 bg-transparent text-ink outline-none focus-visible:outline-none" />
          </label>
          <Select
            aria-label="Catégorie"
            size="sm"
            className="w-[200px] font-semibold"
            options={[
              { value: "", label: "Catégorie : toutes" },
              { value: "legumes", label: "Légumes" },
              { value: "fruits", label: "Fruits" },
              { value: "paniers", label: "Paniers composés" },
            ]}
          />
          <span className="flex-1" />
          {sel.length > 0 && (
            <div className="flex flex-wrap items-center gap-2 rounded-[10px] bg-ink py-1 pr-1 pl-3 text-[13px] text-white" role="toolbar" aria-label="Actions groupées">
              <b>{sel.length} sélectionnés</b>
              <button type="button" className="h-8 rounded-[7px] bg-white/10 px-2.5 font-bold">
                Masquer
              </button>
              <button type="button" className="h-8 rounded-[7px] bg-white/10 px-2.5 font-bold">
                Modifier le prix
              </button>
              <button type="button" className="h-8 rounded-[7px] bg-danger-fg px-2.5 font-bold">
                Supprimer
              </button>
            </div>
          )}
        </div>
        <Table minWidth={900}>
          <THead>
            <Th className="w-5">
              <button type="button" role="checkbox" aria-checked={all} aria-label="Tout sélectionner" onClick={() => setSel(all ? [] : shown.map((r) => r.id))} className="flex">
                <CheckIndicator checked={all} />
              </button>
            </Th>
            <Th>Produit</Th>
            <Th>Prix</Th>
            <Th>Stock</Th>
            <Th>Ventes 30 j</Th>
            <Th>Statut</Th>
            <Th>Visible</Th>
            <Th className="text-right">Actions</Th>
          </THead>
          <tbody>
            {shown.map((r) => {
              const on = sel.includes(r.id);
              const l = level(r);
              const s = stock[r.id] ?? 0;
              return (
                <Tr key={r.id} selected={on}>
                  <Td>
                    <button
                      type="button"
                      role="checkbox"
                      aria-checked={on}
                      aria-label={`Sélectionner ${r.name}`}
                      onClick={() => setSel(on ? sel.filter((x) => x !== r.id) : [...sel, r.id])}
                      className="flex"
                    >
                      <CheckIndicator checked={on} />
                    </button>
                  </Td>
                  <Td>
                    <div className="flex items-center gap-3">
                      <PhotoPlaceholder visual={r.visual} iconSize={20} className="size-11" rounded="rounded-[10px]" />
                      <div className="flex flex-col">
                        <Link href={ROUTES.sellerProduct(r.id)} className="font-semibold text-ink no-underline hover:text-pomme-700">
                          {r.name}
                        </Link>
                        <span className="text-[12px] text-muted">{r.category}</span>
                      </div>
                    </div>
                  </Td>
                  <Td className="whitespace-nowrap font-tabular">
                    <b>{formatAriary(r.price)}</b> <span className="text-muted">/ {r.unitLabel}</span>
                  </Td>
                  <Td>
                    <QuantityStepper
                      size="xs"
                      min={0}
                      value={s}
                      onChange={(n) => setStock({ ...stock, [r.id]: n })}
                      label={`Stock de ${r.name}`}
                      warn={l === "low"}
                      valueClassName={cn(l === "out" && "text-disabled", l === "low" && "text-orange-700")}
                    />
                    <div className="mt-[3px] text-[11px] text-muted">Alerte à {r.lowStockThreshold}</div>
                  </Td>
                  <Td className="font-tabular">{r.sales30d}</Td>
                  <Td>
                    <StatusPill tone={LEVEL[l].tone} size="sm">
                      {LEVEL[l].label}
                    </StatusPill>
                  </Td>
                  <Td>
                    <Switch
                      size="sm"
                      label={`${r.name} visible sur la marketplace`}
                      checked={!!visible[r.id] && l !== "out" && l !== "wait"}
                      disabled={l === "wait"}
                      onChange={(v) => setVisible({ ...visible, [r.id]: v })}
                    />
                  </Td>
                  <Td>
                    <div className="flex justify-end gap-0.5">
                      <Link
                        href={ROUTES.sellerProduct(r.id)}
                        aria-label={`Modifier ${r.name}`}
                        className="flex size-9 items-center justify-center rounded-lg text-body hover:bg-sand hover:text-ink"
                      >
                        <Icon name="edit" size={17} />
                      </Link>
                      <button type="button" aria-label="Plus d’actions" className="flex size-9 items-center justify-center rounded-lg text-body hover:bg-sand">
                        <Icon name="more" size={17} />
                      </button>
                    </div>
                  </Td>
                </Tr>
              );
            })}
          </tbody>
        </Table>
        <div className="flex items-center justify-between border-t border-divider px-[18px] py-3.5 text-[13px] text-muted">
          <span>1–{shown.length} sur 14</span>
          <div className="flex gap-1.5">
            <button type="button" aria-current="page" className="size-9 rounded-lg bg-ink font-bold text-white">
              1
            </button>
            <button type="button" className="size-9 rounded-lg border-[1.5px] border-line-strong bg-white font-bold text-ink">
              2
            </button>
          </div>
        </div>
      </section>
    </div>
  );
}
