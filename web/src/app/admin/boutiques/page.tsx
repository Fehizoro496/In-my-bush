import Link from "next/link";
import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminFilter, AdminPager, AdminTableCard, dateLabel, pageParam, tableRows, textParam, type Search } from "@/components/admin/AdminPageTools";
import { AdminTag } from "@/components/admin/AdminTag";
import { SHOP_STATUS, USER_STATUS } from "@/lib/admin/labels";
import { ROUTES } from "@/lib/routing/routes";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
export default async function Shops({ searchParams }: { searchParams: Promise<Search> }) {
  await requireAdmin();
  const q = await searchParams;
  const query = { q: textParam(q, "q"), status: textParam(q, "status") };
  const rows = await tableRows("shops");
  const data = await adminLive.shops(query, pageParam(q), rows);
  return <><h1 className="font-display text-3xl font-extrabold">Boutiques</h1>
    <form action={ROUTES.adminShops} className="flex flex-wrap items-end gap-3">
      <label className="flex flex-col gap-1 text-sm">Boutique, ville ou propriétaire<input name="q" defaultValue={query.q} className="rounded-lg border border-line bg-white p-2" /></label>
      <AdminFilter name="status" label="Statut" value={query.status} options={[["", "Tous"], ["ACTIVE", "Ouvertes"], ["PAUSED", "En pause"], ["SUSPENDED", "Suspendues"]]} />
      <button className="rounded-lg bg-ink px-4 py-2 text-white">Rechercher</button>
    </form>
    <AdminTableCard table="shops" rows={rows} empty={!data.items.length && "Aucune boutique pour ces critères."}><Table fill minWidth={850}>
      <THead><Th>Boutique</Th><Th>Propriétaire</Th><Th className="hidden xl:table-cell">Ville</Th><Th>En ligne</Th><Th>À valider</Th><Th>Statut</Th><Th className="hidden xl:table-cell">Ouverte le</Th></THead><tbody>
      {data.items.map(s => <Tr key={s.id}>
        <Td className="w-1/4 max-w-0 truncate font-bold" title={s.name}><Link href={ROUTES.adminShop(s.id)}>{s.name}</Link></Td>
        <Td><span className="flex flex-wrap items-center gap-2"><Link href={ROUTES.adminUser(s.ownerId)}>{s.ownerName}</Link>
          {s.ownerStatus !== "ACTIVE" && <AdminTag tags={USER_STATUS} value={s.ownerStatus} />}</span></Td>
        <Td className="hidden xl:table-cell">{s.city ?? "—"}</Td>
        <Td>{s.productCounts.PUBLISHED ?? 0}</Td><Td>{s.productCounts.PENDING_REVIEW ?? 0}</Td>
        <Td><AdminTag tags={SHOP_STATUS} value={s.status} /></Td>
        <Td className="hidden xl:table-cell">{dateLabel(s.createdAt)}</Td>
      </Tr>)}
    </tbody></Table></AdminTableCard>
    <AdminPager sizes={false} data={data} path={ROUTES.adminShops} query={query} /></>;
}
