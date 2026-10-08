import type { Metadata } from "next";
import Link from "next/link";
import { PageHeader } from "@/components/layout/Container";
import { BarChart } from "@/components/charts/Charts";
import { KpiCard } from "@/components/seller-dashboard/KpiCard";
import { PeriodSwitch } from "@/components/seller-dashboard/PeriodSwitch";
import { OrderStatusPill } from "@/components/ui/Badge";
import { Button, ButtonLink } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import { PhotoPlaceholder } from "@/components/ui/Media";
import { Stars } from "@/components/ui/Rating";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { getSellerDashboard } from "@/lib/data/seller";
import { formatAriary, formatCompactAriary, formatRating } from "@/lib/format";
import { ROUTES } from "@/lib/routing/routes";

export const metadata: Metadata = { title: "Tableau de bord vendeur" };

export default async function SellerDashboardPage() {
  const d = await getSellerDashboard();
  const k = d.kpis;
  return (
    <>
      <PageHeader
        eyebrow={
          <span className="flex items-center gap-1.5 text-[13px] font-semibold text-pomme-800">
            <span className="size-2 rounded-full bg-pomme-600" />
            {d.shopName} · boutique en ligne
          </span>
        }
        title="Tableau de bord"
        actions={
          <>
            <PeriodSwitch options={["7 jours", "30 jours", "12 mois"]} defaultValue="30 jours" />
            <ButtonLink href={ROUTES.shop("le-jardin-de-hery")} variant="neutral" icon="eye" size="md" className="px-3.5 text-[14px]">
              Ma boutique
            </ButtonLink>
            <ButtonLink href={ROUTES.sellerProductNew} icon="plus" size="md" className="px-4 text-[14px]">
              Ajouter un produit
            </ButtonLink>
          </>
        }
      />

      <div className="grid grid-cols-2 gap-3.5 md:grid-cols-3 xl:grid-cols-5">
        <KpiCard tone="dark" title="Chiffre des ventes" value={formatCompactAriary(k.salesTotal)} sub={`▲ +${k.salesTrend} % vs mois dernier`} subTone="up" icon="trend" />
        <KpiCard title="Commandes reçues" value={String(k.ordersReceived)} sub={`${k.ordersToPrepare} à préparer`} subTone="warning" icon="receipt" />
        <KpiCard title="Produits actifs" value={String(k.activeProducts)} sub={`${k.drafts} brouillons`} icon="package" />
        <KpiCard tone="warning" title="Bientôt en rupture" value={String(k.lowStock)} sub="Seuil d’alerte atteint" subTone="warning" icon="alert" />
        <KpiCard title="Note moyenne" value={formatRating(k.ratingAvg)} sub={`${k.ratingCount} avis · ${k.positiveShare} % positifs`} subTone="success" icon="star" />
      </div>

      <div className="grid gap-5 xl:grid-cols-[minmax(0,1.7fr)_minmax(0,1fr)]">
        <section className="flex flex-col gap-[18px] rounded-xl border border-line bg-white p-5 md:p-[22px]">
          <div className="flex items-baseline justify-between gap-2">
            <h2 className="m-0 text-[18px] font-bold">Ventes · 30 derniers jours</h2>
            <span className="text-[13px] text-muted">en milliers d’Ar</span>
          </div>
          <BarChart
            label="Ventes quotidiennes des 30 derniers jours"
            values={d.dailySales.map((s) => s.amount / 1000)}
            max={80}
            yTicks={["80", "60", "40", "20", "0"]}
            xLabels={["29 août", "8 sept.", "18 sept.", "28 sept."]}
            valueLabel={(v) => formatAriary(v * 1000)}
          />
        </section>
        <section className="flex flex-col gap-3.5 rounded-xl border border-orange-300 bg-white p-5 md:p-[22px]">
          <div className="flex items-center justify-between gap-2">
            <h2 className="m-0 flex items-center gap-2 text-[18px] font-bold">
              <Icon name="alert" size={18} className="text-orange-700" />
              Bientôt en rupture
            </h2>
            <Link href={ROUTES.sellerProducts} className="text-[13px] font-bold no-underline">
              Gérer le stock
            </Link>
          </div>
          {d.lowStockProducts.map((p) => (
            <div key={p.id} className="flex items-center gap-3">
              <PhotoPlaceholder visual={p.visual} iconSize={20} className="size-11" rounded="rounded-[10px]" />
              <span className="flex min-w-0 flex-1 flex-col">
                <b className="text-[14px]">{p.name}</b>
                <span className="text-[12px] font-bold text-orange-700">{p.left}</span>
              </span>
              <Button variant="neutral" size="sm" className="rounded-lg px-3 text-[13px]">
                Réassortir
              </Button>
            </div>
          ))}
        </section>
      </div>

      <div className="grid gap-5 xl:grid-cols-[minmax(0,1.7fr)_minmax(0,1fr)]">
        <section className="overflow-hidden rounded-xl border border-line bg-white">
          <div className="flex items-center justify-between px-5 py-[18px] md:px-[22px]">
            <h2 className="m-0 text-[18px] font-bold">Commandes reçues</h2>
            <Link href={ROUTES.sellerOrders} className="text-[13px] font-bold no-underline">
              Tout voir ({k.ordersReceived})
            </Link>
          </div>
          <Table minWidth={560}>
            <THead>
              <Th>Commande</Th>
              <Th>Client</Th>
              <Th>Réception</Th>
              <Th className="text-right">Total</Th>
              <Th>Statut</Th>
            </THead>
            <tbody>
              {d.recentOrders.map((o) => (
                <Tr key={o.id}>
                  <Td>
                    <Link href={ROUTES.sellerOrder(o.id)} className="font-bold text-ink no-underline hover:text-pomme-700">
                      {o.number}
                    </Link>
                    <div className="text-[12px] text-muted">{o.createdLabel}</div>
                  </Td>
                  <Td>{o.client.name}</Td>
                  <Td className="text-body">{o.receptionLabel}</Td>
                  <Td className="text-right font-bold font-tabular">{formatAriary(o.total)}</Td>
                  <Td>
                    <OrderStatusPill status={o.status} side="seller" size="sm" />
                  </Td>
                </Tr>
              ))}
            </tbody>
          </Table>
        </section>
        <section className="flex flex-col gap-3.5 rounded-xl border border-line bg-white p-5 md:p-[22px]">
          <div className="flex items-baseline justify-between">
            <h2 className="m-0 text-[18px] font-bold">Avis récents</h2>
            <span className="flex items-center gap-1 text-[14px] font-bold">
              <Icon name="star" size={15} className="text-orange-500" />
              {formatRating(k.ratingAvg)} · {k.ratingCount}
            </span>
          </div>
          {d.recentReviews.map((r) => (
            <div key={r.id} className="flex flex-col gap-1 border-b border-divider pb-3 last:border-0">
              <div className="flex justify-between text-[13px]">
                <b>{r.author.name}</b>
                <Stars value={r.rating} size={13} />
              </div>
              <p className="m-0 text-[14px] leading-5 text-text-soft">{r.comment}</p>
              <span className="text-[12px] text-muted">
                {r.productName} ·{" "}
                <Link href={ROUTES.sellerReviews} className="font-bold no-underline">
                  Répondre
                </Link>
              </span>
            </div>
          ))}
        </section>
      </div>
    </>
  );
}
