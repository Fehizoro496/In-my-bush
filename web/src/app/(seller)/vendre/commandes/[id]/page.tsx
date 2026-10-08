import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { SellerOrderHeader } from "@/components/orders/SellerOrderActions";
import { Avatar } from "@/components/ui/Avatar";
import { ButtonLink } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import { PhotoPlaceholder } from "@/components/ui/Media";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { getSellerOrder } from "@/lib/data/seller";
import { formatAriary } from "@/lib/format";
import { ROUTES } from "@/lib/routing/routes";

export const metadata: Metadata = { title: "Commande reçue" };

export default async function OrderReceivedPage({ params }: { params: Promise<{ id: string }> }) {
  const order = await getSellerOrder((await params).id);
  if (!order) notFound();
  return (
    <>
      <SellerOrderHeader order={order} />
      <div className="grid items-start gap-5 xl:grid-cols-[minmax(0,1fr)_300px]">
        <div className="flex flex-col gap-4">
          <section className="overflow-hidden rounded-xl border border-line bg-white">
            <Table minWidth={520}>
              <THead>
                <Th>Article</Th>
                <Th>Quantité</Th>
                <Th>Prix unitaire</Th>
                <Th className="text-right">Total</Th>
              </THead>
              <tbody>
                {order.items.map((it) => (
                  <Tr key={it.id}>
                    <Td>
                      <div className="flex items-center gap-3">
                        <PhotoPlaceholder visual={it.visual} iconSize={20} className="size-11" rounded="rounded-[10px]" />
                        <b className="font-semibold">{it.productName}</b>
                      </div>
                    </Td>
                    <Td>{it.quantityLabel}</Td>
                    <Td className="text-body">{formatAriary(it.unitPrice)}</Td>
                    <Td className="text-right font-bold font-tabular">{formatAriary(it.lineTotal)}</Td>
                  </Tr>
                ))}
              </tbody>
            </Table>
          </section>
          <section className="grid gap-5 rounded-xl border border-line bg-white px-5 py-5 text-[14px] md:grid-cols-2 md:px-[22px]">
            <div className="flex gap-3">
              <Icon name={order.delivery.mode === "HOME" ? "truck" : "store"} size={20} className="text-pomme-700" />
              <span className="flex flex-col gap-[3px]">
                <b>{order.delivery.mode === "HOME" ? "Livraison à domicile" : "Retrait sur place"}</b>
                <span className="text-body">{order.delivery.slot}</span>
                <span className="text-body">{order.delivery.address}</span>
                <span className="text-muted">{order.delivery.landmark}</span>
              </span>
            </div>
            <div className="flex gap-3">
              <Icon name="wallet" size={20} className="text-pomme-700" />
              <span className="flex flex-col gap-[3px]">
                <b>{order.payment.label}</b>
                {order.payment.notes.map((n) => (
                  <span key={n} className="text-body">
                    {n}
                  </span>
                ))}
              </span>
            </div>
          </section>
        </div>
        <aside className="grid gap-4 md:grid-cols-2 xl:grid-cols-1">
          <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-[18px]">
            <div className="flex items-center gap-3">
              <Avatar initials={order.client.initials} color={order.client.color} size={44} />
              <span className="flex flex-col">
                <b className="text-[15px]">{order.client.name}</b>
                <span className="text-[12px] text-muted">{order.client.since}</span>
              </span>
            </div>
            <div className="rounded-md bg-sand px-3 py-2.5 text-[13px] leading-[19px] text-text-soft">
              {order.client.lastMessage}
              <span className="mt-1 block text-[11px] text-muted">{order.client.lastMessageAt}</span>
            </div>
            <ButtonLink href={ROUTES.accountMessages} variant="soft" icon="msg" className="h-10 text-[14px]">
              Répondre
            </ButtonLink>
          </section>
          <section className="flex flex-col gap-2 self-start rounded-xl border border-line bg-white p-[18px] text-[14px]">
            <h2 className="m-0 mb-1 text-[16px] font-bold">Vos revenus</h2>
            <div className="flex justify-between gap-2">
              <span className="text-body">Articles</span>
              <span>{formatAriary(order.revenue.items)}</span>
            </div>
            <div className="flex justify-between gap-2">
              <span className="text-body">Livraison (payée par la cliente)</span>
              <span>{formatAriary(order.revenue.delivery)}</span>
            </div>
            <div className="flex justify-between gap-2">
              <span className="text-body">Commission In my bush</span>
              <span>−[MONTANT]</span>
            </div>
            <div className="flex justify-between border-t border-divider pt-2 text-[16px] font-bold">
              <span>Vous recevez</span>
              <span className="text-pomme-800">[NET]</span>
            </div>
          </section>
        </aside>
      </div>
    </>
  );
}
