import type { Metadata } from "next";
import Link from "next/link";
import { PageHeader } from "@/components/layout/Container";
import { Avatar } from "@/components/ui/Avatar";
import { Button } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import { getSellerOrders } from "@/lib/data/seller";
import { formatAriary } from "@/lib/format";
import { cn } from "@/lib/cn";
import type { OrderStatus, SellerOrderCard } from "@/lib/types";
import { ROUTES } from "@/lib/routing/routes";

export const metadata: Metadata = { title: "Commandes reçues" };

const COLUMNS: { title: string; dot: string; statuses: OrderStatus[]; cta?: string; total?: number }[] = [
  { title: "À confirmer", dot: "bg-orange-500", statuses: ["PENDING_CONFIRMATION"], cta: "Accepter" },
  { title: "À préparer", dot: "bg-info-strong", statuses: ["ACCEPTED", "PREPARED"], cta: "Marquer préparée" },
  { title: "En livraison", dot: "bg-info-strong", statuses: ["IN_DELIVERY"] },
  { title: "Terminées", dot: "bg-pomme-700", statuses: ["DELIVERED", "REFUSED", "CANCELLED"], total: 34 },
];

function OrderCard({ o, cta }: { o: SellerOrderCard; cta?: string }) {
  const href = ROUTES.sellerOrder(o.id);
  return (
    <article className={cn("flex flex-col gap-2 rounded-[14px] border bg-white p-3", o.urgent ? "border-orange-300" : "border-line")}>
      <div className="flex items-center gap-2">
        <Avatar initials={o.client.initials} color={o.client.color} size={30} />
        <span className="flex min-w-0 flex-1 flex-col">
          <b className="text-[13px]">{o.client.name}</b>
          <span className="text-[11px] text-muted">{o.number}</span>
        </span>
        <b className="text-[13px] font-tabular">{formatAriary(o.total)}</b>
      </div>
      <span className="text-[13px] leading-[18px] text-text-soft">{o.itemsLabel}</span>
      <span className={cn("flex items-center gap-[5px] text-[12px] font-semibold", o.urgent ? "text-orange-700" : "text-body")}>
        <Icon name={o.whenIcon} size={13} />
        {o.whenLabel}
      </span>
      <Link
        href={href}
        className={cn(
          "flex h-9 items-center justify-center rounded-sm text-[13px] font-bold no-underline",
          cta ? "bg-pomme-500 text-on-primary hover:text-on-primary" : "border-[1.5px] border-line-strong text-ink hover:text-ink",
        )}
      >
        {cta ?? "Voir le détail"}
      </Link>
    </article>
  );
}

export default async function OrdersReceivedPage() {
  const orders = await getSellerOrders();
  return (
    <>
      <PageHeader
        title="Commandes reçues"
        subtitle="38 ce mois · 1 à confirmer avant 14h"
        actions={
          <>
            <label className="flex h-[42px] w-full items-center gap-2 rounded-[10px] border-[1.5px] border-line-strong bg-white px-3 text-[14px] text-muted sm:w-[240px]">
              <Icon name="search" size={16} />
              <span className="sr-only">Rechercher une commande</span>
              <input placeholder="Client, n° commande…" className="min-w-0 flex-1 border-0 bg-transparent text-ink outline-none focus-visible:outline-none" />
            </label>
            <Button variant="neutral" icon="receipt" className="h-[42px] px-3 text-[14px]">
              Bons de préparation
            </Button>
          </>
        }
      />
      <div className="-mx-4 flex snap-x gap-3.5 overflow-x-auto px-4 pb-2 md:-mx-8 md:px-8 lg:mx-0 lg:grid lg:grid-cols-2 lg:overflow-visible lg:px-0 xl:grid-cols-4">
        {COLUMNS.map((c) => {
          const cards = orders.filter((o) => c.statuses.includes(o.status));
          return (
            <section key={c.title} aria-label={c.title} className="flex w-[280px] shrink-0 snap-start flex-col gap-2.5 self-start rounded-[18px] bg-sand p-3 lg:w-auto">
              <div className="flex items-center gap-2 px-1 py-0.5">
                <span className={cn("size-2 rounded-full", c.dot)} />
                <b className="flex-1 text-[14px]">{c.title}</b>
                <span className="flex h-[22px] min-w-[22px] items-center justify-center rounded-full bg-white px-1.5 text-[12px] font-extrabold">{c.total ?? cards.length}</span>
              </div>
              {cards.map((o) => (
                <OrderCard key={o.id} o={o} cta={c.cta} />
              ))}
            </section>
          );
        })}
      </div>
    </>
  );
}
