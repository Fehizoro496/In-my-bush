import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminFilter, AdminTableCard, AdminPager, dateLabel, pageParam, tableRows, textParam, type Search } from "@/components/admin/AdminPageTools";
import { ROUTES } from "@/lib/routing/routes";
import { formatAriary } from "@/lib/format";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { AdminTag } from "@/components/admin/AdminTag";
import { ORDER_STATUS, PAYMENT_STATUS } from "@/lib/admin/labels";
export default async function Orders({searchParams}: {searchParams: Promise<Search>}) {
  await requireAdmin(); const q = await searchParams; const status = textParam(q,"status");
  const rows = await tableRows("orders");
  const data = await adminLive.orders(status,pageParam(q),rows);
  return <><h1 className="font-display text-3xl font-extrabold">Commandes</h1>
    <form action={ROUTES.adminOrders} className="flex items-end gap-3"><AdminFilter name="status" label="Statut" value={status} options={[["","Tous"],["PENDING_CONFIRMATION","À confirmer"],["ACCEPTED","Acceptées"],["PREPARED","Préparées"],["IN_DELIVERY","En livraison"],["DELIVERED","Livrées"],["REFUSED","Refusées"],["CANCELLED","Annulées"]]} /><button className="rounded-lg bg-ink px-4 py-2 text-white">Filtrer</button></form>
    <AdminTableCard table="orders" rows={rows} empty={!data.items.length && "Aucune commande pour ce filtre."}><Table fill minWidth={850}><THead><Th>Commande</Th><Th>Date</Th><Th>Acheteur</Th><Th>Boutique</Th><Th>Total</Th><Th>Statut</Th><Th>Paiement</Th></THead><tbody>
      {data.items.map(o => <Tr key={o.id}><Td className="font-bold whitespace-nowrap">{o.number}</Td><Td>{dateLabel(o.createdAt)}</Td><Td className="w-1/6 max-w-0 truncate" title={o.buyerName}>{o.buyerName}</Td><Td className="w-1/6 max-w-0 truncate" title={o.shopName}>{o.shopName}</Td><Td className="whitespace-nowrap">{formatAriary(o.total)}</Td><Td><AdminTag tags={ORDER_STATUS} value={o.status} /></Td><Td><AdminTag tags={PAYMENT_STATUS} value={o.paymentStatus} /></Td></Tr>)}
    </tbody></Table></AdminTableCard><AdminPager sizes={false} data={data} path={ROUTES.adminOrders} query={{status}} /></>;
}

