import type { Metadata } from "next";
import Link from "next/link";
import { PageHeader } from "@/components/layout/Container";
import { BarChart } from "@/components/charts/Charts";
import { PeriodSwitch } from "@/components/seller-dashboard/PeriodSwitch";
import { StatusPill, type StatusTone } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { SimplePager } from "@/components/ui/Navigation";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { getSalesHistory } from "@/lib/data/seller";
import { formatAriary } from "@/lib/format";
import type { SaleRow } from "@/lib/types";
import { ROUTES } from "@/lib/routing/routes";

export const metadata: Metadata = { title: "Historique des ventes" };

const PAYOUT: Record<SaleRow["payout"], { label: string; tone: StatusTone }> = {
  PAID: { label: "Versé", tone: "success" },
  PENDING: { label: "En attente", tone: "warning" },
  REFUNDED: { label: "Remboursé", tone: "neutral" },
};

const KPIS = [
  { t: "Ventes brutes", v: "8,25 M Ar", d: "214 commandes", green: false },
  { t: "Commission In my bush", v: "−[MONTANT]", d: "Taux : [TAUX]", green: false },
  { t: "Net versé", v: "[NET]", d: "52 versements", green: true },
  { t: "Panier moyen", v: "38 500 Ar", d: "▲ +6 % sur un an", green: false },
];

export default async function SalesHistoryPage() {
  const { monthly, rows } = await getSalesHistory();
  return (
    <>
      <PageHeader
        title="Historique des ventes"
        actions={
          <>
            <PeriodSwitch options={["30 j", "6 mois", "12 mois", "2025"]} defaultValue="12 mois" />
            <Button variant="neutral" icon="download" className="px-3.5 text-[14px]">
              Exporter CSV
            </Button>
          </>
        }
      />
      <div className="grid grid-cols-2 gap-3.5 xl:grid-cols-4">
        {KPIS.map((k) => (
          <div key={k.t} className="flex flex-col gap-1.5 rounded-lg border border-line bg-white px-[18px] py-4">
            <span className="text-[13px] font-semibold text-body">{k.t}</span>
            <b className={`font-display text-[24px] md:text-[26px] ${k.green ? "text-pomme-800" : ""}`}>{k.v}</b>
            <span className="text-[12px] text-muted">{k.d}</span>
          </div>
        ))}
      </div>
      <section className="flex flex-col gap-3 rounded-xl border border-line bg-white px-5 py-5 md:px-[22px]">
        <div className="flex items-baseline justify-between">
          <h2 className="m-0 text-[17px] font-bold">Ventes mensuelles</h2>
          <span className="text-[12px] text-muted">en millions d’Ar</span>
        </div>
        <BarChart
          label="Ventes mensuelles sur 12 mois"
          values={monthly.map((m) => m.amount / 1_000_000)}
          max={1.3}
          height={200}
          gap={14}
          showValues
          valueLabel={(v) => v.toFixed(2).replace(/0$/, "").replace(".", ",")}
          xLabels={monthly.map((m) => m.month)}
        />
      </section>
      <section className="overflow-hidden rounded-xl border border-line bg-white">
        <Table minWidth={720}>
          <THead>
            <Th>Date</Th>
            <Th>Commande</Th>
            <Th>Client</Th>
            <Th>Articles</Th>
            <Th className="text-right">Montant</Th>
            <Th>Versement</Th>
          </THead>
          <tbody>
            {rows.map((r) => (
              <Tr key={r.id}>
                <Td className="text-body">{r.date}</Td>
                <Td>
                  <Link href={ROUTES.sellerOrder("sord-24788")} className="font-bold no-underline">
                    {r.orderNumber}
                  </Link>
                </Td>
                <Td>{r.client}</Td>
                <Td className="text-body">{r.items}</Td>
                <Td className={`text-right font-bold font-tabular ${r.payout === "REFUNDED" ? "text-muted" : ""}`}>{formatAriary(r.amount)}</Td>
                <Td>
                  <StatusPill tone={PAYOUT[r.payout].tone} size="sm" dot={false}>
                    {PAYOUT[r.payout].label}
                  </StatusPill>
                </Td>
              </Tr>
            ))}
          </tbody>
        </Table>
        <SimplePager summary="1–7 sur 214 ventes" />
      </section>
    </>
  );
}
