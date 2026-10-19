import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminProductsTable } from "@/components/admin/AdminProductsTable";
import { AdminFilter, AdminPager, AdminTableCard, dateLabel, pageParam, tableRows, textParam, type Search } from "@/components/admin/AdminPageTools";
import { ROUTES } from "@/lib/routing/routes";
export default async function Products({ searchParams }: { searchParams: Promise<Search> }) {
  await requireAdmin();
  const q = await searchParams;
  const status = textParam(q, "status") || "PENDING_REVIEW";
  const rows = await tableRows("products");
  const data = await adminLive.products(status === "ALL" ? "" : status, pageParam(q), rows);
  return <><h1 className="font-display text-3xl font-extrabold">Modération des produits</h1>
    <form action={ROUTES.adminProducts} className="flex items-end gap-3">
      <AdminFilter name="status" label="Statut" value={status} options={[["ALL","Tous"],["PENDING_REVIEW","À valider"],["PUBLISHED","Publiés"],["REJECTED","Refusés"],["DRAFT","Brouillons"],["ARCHIVED","Archivés"]]} />
      <button className="rounded-lg bg-ink px-4 py-2 text-white">Filtrer</button>
    </form>
    <AdminTableCard table="products" rows={rows} empty={!data.items.length && "Aucun produit pour ce filtre."}>
      <AdminProductsTable items={data.items.map(p => ({ ...p, submitted: dateLabel(p.createdAt) }))} />
    </AdminTableCard>
    <AdminPager sizes={false} data={data} path={ROUTES.adminProducts} query={{ status }} /></>;
}
