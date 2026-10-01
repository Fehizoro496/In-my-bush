import type { Metadata } from "next";
import Link from "next/link";
import { PageHeader } from "@/components/layout/Container";
import { HBarList, LineChart } from "@/components/charts/Charts";
import { AdminKpiCard } from "@/components/seller-dashboard/KpiCard";
import { Button } from "@/components/ui/Button";
import { Select } from "@/components/ui/Form";
import { Icon } from "@/components/ui/Icon";
import { getAdminDashboard } from "@/lib/data/admin";
import { formatNumber } from "@/lib/format";

export const metadata: Metadata = { title: "Dashboard" };

const QUEUE_TONE = {
  warning: { box: "bg-orange-50", ink: "text-orange-700" },
  danger: { box: "bg-[#FCEBE9]", ink: "text-danger-fg" },
  info: { box: "bg-info-bg", ink: "text-info-fg" },
};

export default async function AdminDashboardPage() {
  const d = await getAdminDashboard();
  const maxCat = Math.max(...d.topCategories.map((c) => c.share));
  return (
    <>
      <PageHeader
        size="sm"
        title="Vue d’ensemble"
        subtitle={d.asOf}
        actions={
          <>
            <Select
              aria-label="Période"
              size="sm"
              className="w-[190px] font-semibold"
              options={[
                { value: "30d", label: "30 derniers jours" },
                { value: "7d", label: "7 derniers jours" },
                { value: "12m", label: "12 derniers mois" },
              ]}
            />
            <Button variant="dark" size="sm" icon="download" className="h-10 rounded-[10px] px-3">
              Exporter
            </Button>
          </>
        }
      />
      <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 xl:grid-cols-4">
        {d.kpis.map((k) => (
          <AdminKpiCard key={k.label} {...k} />
        ))}
      </div>
      <div className="grid gap-4 xl:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]">
        <section className="flex flex-col gap-3.5 rounded-[18px] border border-line bg-white px-5 py-5 md:px-6">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <h2 className="m-0 text-[17px] font-bold">Évolution des ventes (GMV, M Ar)</h2>
            <div className="flex gap-4 text-[12px] text-body">
              <span className="flex items-center gap-1.5">
                <span className="h-[3px] w-4 rounded-sm bg-pomme-700" />
                2026
              </span>
              <span className="flex items-center gap-1.5">
                <span className="w-4 border-t-2 border-dashed border-disabled" />
                2025
              </span>
            </div>
          </div>
          <LineChart
            label="Ventes mensuelles 2026 comparées à 2025"
            current={d.gmv.map((g) => g.current)}
            previous={d.gmv.map((g) => g.previous)}
            max={200}
            labels={d.gmv.map((g) => g.month)}
            yTicks={["200", "150", "100", "50", "0"]}
          />
        </section>
        <section className="flex flex-col gap-3.5 rounded-[18px] border border-line bg-white px-5 py-5 md:px-6">
          <h2 className="m-0 text-[17px] font-bold">Catégories les plus populaires</h2>
          <HBarList items={d.topCategories.map((c) => ({ label: c.name, value: c.share, width: Math.round((c.share / maxCat) * 100) }))} />
        </section>
      </div>
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        <section className="flex flex-col gap-3.5 rounded-[18px] border border-line bg-white px-5 py-5 md:px-6">
          <div className="flex items-center justify-between">
            <h2 className="m-0 text-[17px] font-bold">Nouvelles inscriptions</h2>
            <span className="text-[12px] text-muted">par semaine</span>
          </div>
          <div className="flex h-[150px] items-end gap-3 border-b border-line-strong px-1" role="img" aria-label="Inscriptions hebdomadaires : acheteurs et vendeurs">
            {d.signups.map((s, i) => (
              <div key={i} className="flex h-full flex-1 items-end gap-[3px]">
                <span className="flex-1 rounded-t-[4px] bg-lime" style={{ height: `${Math.round((s.buyers / 360) * 100)}%` }} title={`Acheteurs ${s.buyers}`} />
                <span className="flex-1 rounded-t-[4px] bg-orange-700" style={{ height: `${Math.round((s.sellers / 10) * 60)}%` }} title={`Vendeurs ${s.sellers}`} />
              </div>
            ))}
          </div>
          <div className="flex flex-wrap gap-4 text-[12px] text-body">
            <span className="flex items-center gap-1.5">
              <span className="size-2.5 rounded-[3px] bg-lime" />
              Acheteurs · {formatNumber(d.signupTotals.buyers)}
            </span>
            <span className="flex items-center gap-1.5">
              <span className="size-2.5 rounded-[3px] bg-orange-700" />
              Nouveaux vendeurs · {d.signupTotals.sellers}
            </span>
          </div>
        </section>
        <section className="flex flex-col gap-4 rounded-[18px] border border-line bg-white px-5 py-5 md:px-6">
          <div className="flex items-center justify-between">
            <h2 className="m-0 text-[17px] font-bold">Commandes par statut</h2>
            <span className="text-[12px] text-muted">{formatNumber(d.ordersTotal)}</span>
          </div>
          <div className="flex h-4 gap-0.5 overflow-hidden rounded-full" role="img" aria-label="Répartition des commandes par statut">
            {d.ordersByStatus.map((s) => (
              <span key={s.label} style={{ width: `${s.share}%`, background: s.color }} />
            ))}
          </div>
          <ul className="m-0 flex list-none flex-col gap-2.5 p-0">
            {d.ordersByStatus.map((s) => (
              <li key={s.label} className="flex items-center gap-2.5 text-[14px]">
                <span className="size-2.5 rounded-[3px]" style={{ background: s.color }} />
                <span className="flex-1">{s.label}</span>
                <b className="font-tabular">{formatNumber(s.count)}</b>
                <span className="w-11 text-right text-[13px] text-muted">{s.share} %</span>
              </li>
            ))}
          </ul>
        </section>
        <section className="flex flex-col gap-3 rounded-[18px] border border-line bg-white px-5 py-5 md:col-span-2 md:px-6 xl:col-span-1">
          <h2 className="m-0 text-[17px] font-bold">À traiter</h2>
          {d.queue.map((q) => {
            const t = QUEUE_TONE[q.tone];
            return (
              <Link key={q.title} href={q.href} className={`flex items-center gap-3 rounded-md px-3 py-2.5 text-ink no-underline hover:text-ink ${t.box}`}>
                <Icon name={q.icon} size={20} className={t.ink} />
                <span className="flex flex-1 flex-col">
                  <b className="text-[14px]">{q.title}</b>
                  <span className="text-[12px] text-body">{q.detail}</span>
                </span>
                <b className={`font-display text-[20px] ${t.ink}`}>{q.count}</b>
              </Link>
            );
          })}
        </section>
      </div>
    </>
  );
}
