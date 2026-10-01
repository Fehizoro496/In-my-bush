"use client";

import { useState } from "react";
import { cn } from "@/lib/cn";
import type { AdminReport, ReportTargetType } from "@/lib/types";
import { StatusPill } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { ChipGroup } from "@/components/ui/Chip";
import { Textarea } from "@/components/ui/Form";
import { Icon, type IconName } from "@/components/ui/Icon";
import { useToast } from "@/components/ui/Toast";
import { EmptyState } from "@/components/ui/Feedback";

const TYPE: Record<ReportTargetType, { label: string; icon: IconName; bg: string; ink: string }> = {
  PRODUCT: { label: "Produit", icon: "package", bg: "#FFF1E0", ink: "#B4500A" },
  REVIEW: { label: "Avis", icon: "starO", bg: "#E8F1FA", ink: "#2F6DA8" },
  SHOP: { label: "Vendeur", icon: "store", bg: "#FCEBE9", ink: "#C0352B" },
  USER: { label: "Utilisateur", icon: "user", bg: "#FCEBE9", ink: "#C0352B" },
  MESSAGE: { label: "Message", icon: "msg", bg: "#F4F0E6", ink: "#4A4A42" },
};
type Filter = "all" | ReportTargetType;

/** Reports queue + detail with moderation actions (A-Reports). */
export function ReportsAdmin({ reports }: { reports: AdminReport[] }) {
  const toast = useToast();
  const [filter, setFilter] = useState<Filter>("all");
  const [list, setList] = useState(reports);
  const shown = list.filter((r) => filter === "all" || r.targetType === filter);
  const [selId, setSelId] = useState(reports[0]?.id);
  const d = shown.find((r) => r.id === selId) ?? shown[0];

  const resolve = (label: string) => {
    if (!d) return;
    // TODO(api): adminApi.updateReport(d.id, { status: "RESOLVED" | "DISMISSED", note })
    setList(list.filter((r) => r.id !== d.id));
    toast.show({ title: label, description: `SIG-${d.number} · ${d.target}` });
  };

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div className="flex flex-col gap-1">
          <h1 className="m-0 font-display text-[26px] font-extrabold tracking-[-0.02em] md:text-[30px]">Signalements</h1>
          <span className="text-[14px] text-muted">{list.length} ouverts · {list.filter((r) => r.priority).length} prioritaires · délai moyen de traitement 5 h</span>
        </div>
        <ChipGroup
          label="Type de signalement"
          size="sm"
          value={filter}
          onChange={setFilter}
          className="flex-nowrap overflow-x-auto scrollbar-none"
          options={[
            { value: "all", label: "Tous" },
            { value: "PRODUCT", label: "Produits" },
            { value: "SHOP", label: "Vendeurs" },
            { value: "REVIEW", label: "Avis" },
            { value: "MESSAGE", label: "Messages" },
          ]}
        />
      </div>
      <div className="grid items-start gap-5 xl:grid-cols-[440px_minmax(0,1fr)]">
        <section aria-label="File des signalements" className="overflow-hidden rounded-[18px] border border-line bg-white">
          {shown.length === 0 && <EmptyState bordered={false} icon="flag" title="File vide" description="Aucun signalement ouvert pour ce type." />}
          <ul className="m-0 list-none p-0">
            {shown.map((r, i) => {
              const t = TYPE[r.targetType];
              const on = d?.id === r.id;
              return (
                <li key={r.id} className={i > 0 ? "border-t border-divider" : undefined}>
                  <button
                    type="button"
                    aria-current={on ? "true" : undefined}
                    onClick={() => setSelId(r.id)}
                    className={cn("flex w-full gap-3 px-4 py-3.5 text-left text-ink", on ? "bg-pomme-50 shadow-[inset_0_0_0_1.5px_#B2DA6A]" : "bg-white hover:bg-bg")}
                  >
                    <span className="flex size-9 shrink-0 items-center justify-center rounded-[10px]" style={{ background: t.bg, color: t.ink }}>
                      <Icon name={t.icon} size={18} />
                    </span>
                    <span className="flex min-w-0 flex-1 flex-col gap-[3px]">
                      <span className="flex justify-between gap-2">
                        <b className="text-[14px]">{r.reason}</b>
                        <span className="text-[12px] whitespace-nowrap text-muted">{r.whenLabel}</span>
                      </span>
                      <span className="truncate text-[13px] text-body">
                        {t.label} · {r.target}
                      </span>
                      <span className="mt-0.5 flex gap-1.5">
                        {r.priority && <span className="inline-flex h-5 items-center rounded-[6px] bg-danger-bg px-[7px] text-[11px] font-extrabold text-danger-ink">Prioritaire</span>}
                        <span className="inline-flex h-5 items-center rounded-[6px] bg-sand px-[7px] text-[11px] font-bold text-body">{r.count} signalement(s)</span>
                      </span>
                    </span>
                  </button>
                </li>
              );
            })}
          </ul>
        </section>
        {d && (
          <section aria-label="Détail du signalement" className="flex flex-col gap-[18px] rounded-[18px] border border-line bg-white p-5 md:p-6">
            <div className="flex items-start justify-between gap-3">
              <div className="flex flex-col gap-1">
                <span className="overline text-muted">
                  {TYPE[d.targetType].label} · SIG-{d.number}
                </span>
                <h2 className="m-0 font-display text-[24px] font-bold">{d.reason}</h2>
              </div>
              <StatusPill tone="warning" size="sm">
                Ouvert
              </StatusPill>
            </div>
            <div className="flex gap-3.5 rounded-[14px] border border-line bg-bg p-4">
              <span className="size-[72px] shrink-0 rounded-md" style={{ background: d.tint }} aria-hidden />
              <div className="flex flex-col gap-1">
                <b className="text-[16px]">{d.target}</b>
                <span className="text-[13px] text-muted">{d.meta}</span>
                <p className="m-0 mt-1.5 text-[14px] leading-[21px] text-text-soft">{d.excerpt}</p>
              </div>
            </div>
            <dl className="m-0 grid gap-3 sm:grid-cols-3">
              {[
                ["Signalé par", d.reportedBy],
                ["Signalements", `${d.count} en 7 jours`],
                ["Historique vendeur", d.history],
              ].map(([k, v]) => (
                <div key={k} className="rounded-md bg-bg px-3.5 py-3">
                  <dt className="text-[12px] text-muted">{k}</dt>
                  <dd className="m-0 text-[14px] font-bold">{v}</dd>
                </div>
              ))}
            </dl>
            <Textarea label="Note interne" rows={3} placeholder="Visible uniquement par l’équipe de modération" className="text-[14px]" />
            <div className="flex flex-wrap justify-end gap-2.5 border-t border-divider pt-3.5">
              <Button variant="neutral" className="text-[14px]" onClick={() => resolve("Classé sans suite")}>
                Classer sans suite
              </Button>
              <Button variant="neutral" icon="mail" className="text-[14px]" onClick={() => resolve("Vendeur averti")}>
                Avertir le vendeur
              </Button>
              <Button variant="secondary" icon="eye" className="text-[14px]" onClick={() => resolve("Contenu masqué")}>
                Masquer le contenu
              </Button>
              <Button variant="danger" icon="ban" className="text-[14px]" onClick={() => resolve("Vendeur suspendu")}>
                Suspendre le vendeur
              </Button>
            </div>
          </section>
        )}
      </div>
    </>
  );
}
