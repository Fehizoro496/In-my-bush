import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { PageHeader } from "@/components/layout/Container";
import { Avatar } from "@/components/ui/Avatar";
import { OrderStatusPill } from "@/components/ui/Badge";
import { Button, ButtonLink } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import { PhotoPlaceholder } from "@/components/ui/Media";
import { Breadcrumb, StepBar } from "@/components/ui/Navigation";
import { getMyOrder } from "@/lib/data/account";
import { formatAriary, formatDateTime } from "@/lib/format";
import { ROUTES } from "@/lib/routing/routes";

export const metadata: Metadata = { title: "Suivi de commande" };

const TONE = { info: "text-info-fg", warning: "text-orange-800", success: "text-pomme-800" };

export default async function OrderDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const order = await getMyOrder((await params).id);
  if (!order) notFound();
  const done = order.timeline.filter((s) => s.done).length;

  return (
    <>
      <PageHeader
        size="md"
        eyebrow={<Breadcrumb items={[{ label: "Mes commandes", href: ROUTES.account }, { label: order.number }]} />}
        title={`Commande ${order.number}`}
        titleAside={<OrderStatusPill status={order.status} />}
        subtitle={`Passée le ${formatDateTime(order.createdAt)} · ${order.itemCount} articles · ${order.parcels.length} vendeurs`}
        actions={
          <>
            <Button variant="neutral" icon="download" size="md" className="text-[14px]">
              Facture
            </Button>
            <Button variant="danger-outline" icon="flag" size="md" className="text-[14px]">
              Signaler un problème
            </Button>
          </>
        }
      />
      <div className="grid items-start gap-5 xl:grid-cols-[minmax(0,1fr)_320px]">
        <div className="flex flex-col gap-4">
          {order.tracking && (
            <section className="grid overflow-hidden rounded-xl border border-line bg-white md:grid-cols-[minmax(0,1fr)_260px]">
              <div className="relative min-h-[180px] overflow-hidden bg-[#EEF3E4] md:min-h-[220px]" aria-label="Carte de suivi">
                <span className="absolute top-[110px] -left-5 h-3.5 w-[800px] -rotate-[8deg] bg-white" />
                <span className="absolute top-[140px] left-[60px] w-[320px] -rotate-[8deg] border-t-[3px] border-dashed border-pomme-600" />
                <span className="absolute top-[94px] left-[45%] flex size-10 items-center justify-center rounded-full bg-ink text-white shadow-[0_0_0_8px_rgba(31,35,24,0.12)]">
                  <Icon name="truck" size={20} />
                </span>
                <span className="absolute top-[60px] right-20 size-[34px] -rotate-45 rounded-[999px_999px_999px_4px] bg-pomme-700" />
              </div>
              <div className="flex flex-col justify-center gap-3 p-5">
                <span className="text-[13px] text-muted">{order.tracking.label}</span>
                <b className="font-display text-[30px] leading-none">{order.tracking.slot}</b>
                <span className="text-[14px] text-body">{order.tracking.courier}</span>
                <ButtonLink href={ROUTES.accountMessages} variant="soft" icon="msg" size="md" className="h-[42px] text-[14px]">
                  Écrire au livreur
                </ButtonLink>
              </div>
            </section>
          )}
          <section className="rounded-xl border border-line bg-white px-4 py-5 md:px-[22px]">
            <StepBar
              barHeight={6}
              showCheck
              current={done}
              steps={order.timeline.map((s) => ({ label: s.label, detail: s.detail }))}
            />
          </section>
          {order.parcels.map((p) => (
            <section key={p.shop.slug} className="overflow-hidden rounded-xl border border-line bg-white">
              <div className="flex flex-wrap items-center gap-3 border-b border-divider bg-bg px-4 py-3 md:px-5">
                <Avatar initials={p.shop.initials} color={p.shop.color} size={32} />
                <Link href={ROUTES.shop(p.shop.slug)} className="flex-1 text-[15px] font-bold text-ink no-underline hover:text-pomme-700">
                  {p.shop.name}
                </Link>
                <span className={`text-[13px] font-bold ${TONE[p.statusTone]}`}>{p.statusLabel}</span>
                <ButtonLink href={ROUTES.accountMessages} variant="neutral" icon="msg" size="sm" className="h-[34px] rounded-lg px-2.5 text-[13px]">
                  Contacter
                </ButtonLink>
              </div>
              {p.items.map((it, i) => (
                <div key={it.id} className={`flex items-center gap-3.5 px-4 py-3 md:px-5 ${i > 0 ? "border-t border-divider" : ""}`}>
                  <PhotoPlaceholder visual={it.visual} iconSize={22} className="size-14" rounded="rounded-md" />
                  <span className="flex min-w-0 flex-1 flex-col">
                    <b className="text-[15px]">{it.productName}</b>
                    <span className="text-[13px] text-muted">{it.quantityLabel}</span>
                  </span>
                  <b className="text-[15px] font-tabular">{formatAriary(it.lineTotal)}</b>
                </div>
              ))}
            </section>
          ))}
        </div>
        <aside className="grid gap-4 md:grid-cols-2 xl:grid-cols-1">
          <section className="flex flex-col gap-2.5 rounded-xl border border-line bg-white p-5 text-[14px]">
            <h2 className="m-0 mb-1 text-[16px] font-bold">Paiement</h2>
            <div className="flex justify-between">
              <span className="text-body">Sous-total</span>
              <span>{formatAriary(order.subtotal)}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-body">Livraison</span>
              <span>{formatAriary(order.deliveryFee)}</span>
            </div>
            {order.discount > 0 && (
              <div className="flex justify-between text-orange-700">
                <span>Réduction</span>
                <span>{formatAriary(-order.discount)}</span>
              </div>
            )}
            <div className="flex justify-between border-t border-divider pt-2 text-[16px] font-bold">
              <span>Total</span>
              <span>{formatAriary(order.total)}</span>
            </div>
            <span className="flex items-center gap-1.5 text-[13px] text-muted">
              <Icon name="wallet" size={15} />
              {order.paymentDetail}
            </span>
            <span className="rounded-[10px] bg-pomme-100 px-2.5 py-2 text-[12px] leading-[17px] text-pomme-800">
              Montant conservé par In my bush, versé aux vendeurs après votre réception.
            </span>
          </section>
          <section className="flex flex-col gap-2 rounded-xl border border-line bg-white p-5 text-[14px]">
            <h2 className="m-0 mb-1 text-[16px] font-bold">Adresse</h2>
            <b>{order.address.title}</b>
            <span className="leading-5 text-body">
              {order.address.lines.map((l) => (
                <span key={l} className="block">
                  {l}
                </span>
              ))}
            </span>
          </section>
          <p className="m-0 text-[13px] leading-[19px] text-muted md:col-span-2 xl:col-span-1">{order.cancellationNote}</p>
        </aside>
      </div>
    </>
  );
}
