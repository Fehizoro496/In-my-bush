"use client";

import { useState } from "react";
import { cn } from "@/lib/cn";
import type { AdminProductRow, ReviewCheck } from "@/lib/types";
import { Button } from "@/components/ui/Button";
import { CheckIndicator, RadioIndicator, Select, Textarea } from "@/components/ui/Form";
import { Icon, type IconName } from "@/components/ui/Icon";
import { Modal } from "@/components/ui/Modal";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { TabList } from "@/components/ui/Tabs";
import { useToast } from "@/components/ui/Toast";
import { EmptyState } from "@/components/ui/Feedback";

const CHECK: Record<ReviewCheck, { label: string; cls: string; icon: IconName }> = {
  COMPLETE: { label: "Fiche complète", cls: "bg-success-bg text-success-fg", icon: "checkCircle" },
  TO_CHECK: { label: "À vérifier", cls: "bg-orange-100 text-orange-800", icon: "clock" },
  MISSING_INFO: { label: "Infos manquantes", cls: "bg-danger-bg text-danger-ink", icon: "alert" },
  PHOTOS: { label: "Photos à revoir", cls: "bg-info-bg text-info-fg", icon: "info" },
};

/** Pending products table, bulk approve and the reject modal (A-Products). */
export function ProductModeration({
  rows,
  tabs,
  reasons,
}: {
  rows: AdminProductRow[];
  tabs: readonly { value: string; label: string; count: string; warning?: boolean }[];
  reasons: string[];
}) {
  const toast = useToast();
  const [tab, setTab] = useState(tabs[0]!.value);
  const [list, setList] = useState(rows);
  const [sel, setSel] = useState<string[]>(rows.slice(0, 2).map((r) => r.id));
  const [target, setTarget] = useState<AdminProductRow | null>(null);
  const [reason, setReason] = useState(1);

  const approve = (ids: string[]) => {
    // TODO(api): adminApi.approveProduct(id) for each id
    setList(list.filter((r) => !ids.includes(r.id)));
    setSel(sel.filter((s) => !ids.includes(s)));
    toast.show({ title: ids.length > 1 ? `${ids.length} produits validés` : "Produit validé", description: "Le vendeur est notifié et le produit est en ligne." });
  };

  return (
    <>
      <TabList
        label="Statut des produits"
        value={tab}
        onChange={setTab}
        size="sm"
        className="gap-[26px]"
        items={tabs.map((t) => ({ value: t.value, label: t.label, count: t.count, countTone: t.warning ? "warning" : "neutral" }))}
      />
      <section className="overflow-hidden rounded-[18px] border border-line bg-white">
        <div className="flex flex-wrap items-center gap-2.5 border-b border-divider px-4 py-3.5 md:px-[18px]">
          <label className="flex h-10 w-full items-center gap-2 rounded-[10px] border-[1.5px] border-line-strong px-3 text-[14px] text-muted sm:w-[300px]">
            <Icon name="search" size={16} />
            <span className="sr-only">Rechercher</span>
            <input placeholder="Produit, vendeur, SKU…" className="min-w-0 flex-1 border-0 bg-transparent text-ink outline-none focus-visible:outline-none" />
          </label>
          {["Catégorie", "Région", "Contrôle", "Date de soumission"].map((f) => (
            <Select key={f} aria-label={f} size="sm" className="w-auto min-w-[130px] text-[13px] font-semibold" options={[{ value: "", label: f }]} />
          ))}
          <span className="flex-1" />
          <Button size="sm" icon="check" className="h-10 rounded-[10px] text-[13px]" disabled={sel.length === 0} onClick={() => approve(sel)}>
            Valider la sélection ({sel.length})
          </Button>
        </div>
        {tab !== "PENDING_REVIEW" ? (
          <EmptyState bordered={false} icon="package" tone="sand" title="Vue non chargée" description="Les données de cet onglet viennent de GET /admin/products?status=… (mode API)." />
        ) : (
          <Table minWidth={1040}>
            <THead>
              <Th className="w-5">
                <span className="sr-only">Sélection</span>
              </Th>
              <Th>Produit</Th>
              <Th>Vendeur</Th>
              <Th>Catégorie</Th>
              <Th>Prix</Th>
              <Th>Contrôle</Th>
              <Th>Soumis</Th>
              <Th className="text-right">Décision</Th>
            </THead>
            <tbody>
              {list.map((r) => {
                const on = sel.includes(r.id);
                const c = CHECK[r.check];
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
                        <span className="size-11 shrink-0 rounded-[10px]" style={{ background: r.tint }} aria-hidden />
                        <div className="flex flex-col">
                          <b className="font-semibold">{r.name}</b>
                          <span className="text-[12px] text-muted">
                            {r.photoCount} photos · {r.origin}
                          </span>
                        </div>
                      </div>
                    </Td>
                    <Td>
                      <div className="flex flex-col">
                        <span>{r.seller}</span>
                        <span className={cn("text-[12px]", r.newSeller ? "text-orange-700" : "text-pomme-800")}>{r.sellerNote}</span>
                      </div>
                    </Td>
                    <Td className="text-body">{r.category}</Td>
                    <Td className="whitespace-nowrap font-tabular">{r.priceLabel}</Td>
                    <Td>
                      <span className={cn("inline-flex h-6 items-center gap-1 rounded-[6px] px-2 text-[12px] font-bold whitespace-nowrap", c.cls)}>
                        <Icon name={c.icon} size={13} />
                        {c.label}
                      </span>
                    </Td>
                    <Td className="text-[13px] whitespace-nowrap text-body">{r.submittedLabel}</Td>
                    <Td>
                      <div className="flex justify-end gap-1.5">
                        <button type="button" aria-label={`Voir ${r.name}`} className="flex size-9 items-center justify-center rounded-lg border-[1.5px] border-line-strong bg-white text-body">
                          <Icon name="eye" size={17} />
                        </button>
                        <button
                          type="button"
                          aria-label={`Refuser ${r.name}`}
                          onClick={() => setTarget(r)}
                          className="flex size-9 items-center justify-center rounded-lg border-[1.5px] border-danger-border bg-white text-danger-fg hover:bg-danger-bg"
                        >
                          <Icon name="x" size={17} />
                        </button>
                        <button
                          type="button"
                          aria-label={`Valider ${r.name}`}
                          onClick={() => approve([r.id])}
                          className="flex h-9 items-center gap-1 rounded-lg bg-pomme-500 px-3 text-[13px] font-bold text-on-primary hover:bg-[#7DB834]"
                        >
                          <Icon name="check" size={15} />
                          Valider
                        </button>
                      </div>
                    </Td>
                  </Tr>
                );
              })}
            </tbody>
          </Table>
        )}
        <div className="flex items-center justify-between border-t border-divider px-[18px] py-3 text-[13px] text-muted">
          <span>1–{list.length} sur 24 · 25 par page</span>
          <div className="flex gap-1.5">
            {[1, 2, 3].map((p) => (
              <button key={p} type="button" aria-current={p === 1 ? "page" : undefined} className={cn("size-[34px] rounded-lg font-bold", p === 1 ? "bg-ink text-white" : "border-[1.5px] border-line-strong bg-white text-ink")}>
                {p}
              </button>
            ))}
          </div>
        </div>
      </section>

      <Modal
        open={!!target}
        onClose={() => setTarget(null)}
        title="Refuser ce produit ?"
        description={target ? `${target.name} · ${target.seller}` : undefined}
        leading={<span className="size-12 shrink-0 rounded-md" style={{ background: target?.tint }} aria-hidden />}
        footer={
          <div className="flex w-full flex-wrap items-center justify-between gap-3">
            <span className="text-[12px] text-muted">Le vendeur pourra corriger et resoumettre.</span>
            <div className="flex gap-2.5">
              <Button variant="neutral" className="text-[14px]" onClick={() => setTarget(null)}>
                Annuler
              </Button>
              <Button
                variant="danger"
                className="text-[14px]"
                onClick={() => {
                  // TODO(api): adminApi.rejectProduct(target.id, reasons[reason], message)
                  if (target) setList(list.filter((r) => r.id !== target.id));
                  toast.show({ tone: "info", title: "Produit refusé", description: reasons[reason] });
                  setTarget(null);
                }}
              >
                Refuser le produit
              </Button>
            </div>
          </div>
        }
      >
        <fieldset className="m-0 flex flex-col gap-2 border-0 p-0">
          <legend className="mb-2 p-0 text-[14px] font-bold">Motif</legend>
          <div role="radiogroup" aria-label="Motif du refus" className="flex flex-col gap-2">
            {reasons.map((t, i) => {
              const on = reason === i;
              return (
                <button
                  key={t}
                  type="button"
                  role="radio"
                  aria-checked={on}
                  onClick={() => setReason(i)}
                  className={cn(
                    "flex min-h-11 items-center gap-2.5 rounded-[10px] border-[1.5px] px-3 text-left text-[14px] text-ink",
                    on ? "border-danger-fg bg-[#FCEBE9]" : "border-line-strong bg-white",
                  )}
                >
                  <RadioIndicator checked={on} tone="danger" />
                  {t}
                </button>
              );
            })}
          </div>
        </fieldset>
        <Textarea label="Message au vendeur" rows={3} placeholder="Expliquez ce qui doit être corrigé pour une nouvelle soumission." className="text-[14px]" />
      </Modal>
    </>
  );
}
