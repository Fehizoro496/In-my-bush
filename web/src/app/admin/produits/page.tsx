import Link from "next/link";
import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminProductsTable } from "@/components/admin/AdminProductsTable";
import { AdminFilter, AdminPager, AdminTableCard, dateLabel, pageParam, tableRows, textParam, type Search } from "@/components/admin/AdminPageTools";
import { ROUTES } from "@/lib/routing/routes";
const UUID = /^[0-9a-f-]{36}$/i;
export default async function Products({ searchParams }: { searchParams: Promise<Search> }) {
  await requireAdmin();
  const q = await searchParams;
  const status = textParam(q, "status") || "PENDING_REVIEW";
  const query = { status, q: textParam(q, "q"), categoryId: textParam(q, "categoryId"), shopId: textParam(q, "shopId") };
  const shopId = UUID.test(query.shopId) ? query.shopId : "";
  const rows = await tableRows("products");
  const [data, categories, shop] = await Promise.all([
    adminLive.products({ ...query, shopId, status: status === "ALL" ? "" : status }, pageParam(q), rows),
    adminLive.categories(),
    shopId ? adminLive.shop(shopId).then(d => d.shop) : null,
  ]);
  return <><h1 className="font-display text-3xl font-extrabold">Modération des produits</h1>
    {shop && <p className="text-muted">Produits de la boutique <Link href={ROUTES.adminShop(shop.id)} className="font-bold">{shop.name}</Link> ·{" "}
      <Link href={ROUTES.adminProducts}>voir tous les produits</Link></p>}
    <form action={ROUTES.adminProducts} className="flex flex-wrap items-end gap-3">
      {shop && <input type="hidden" name="shopId" value={shop.id} />}
      <label className="flex flex-col gap-1 text-sm">Produit ou boutique<input name="q" defaultValue={query.q} className="rounded-lg border border-line bg-white p-2" /></label>
      <AdminFilter name="status" label="Statut" value={status} options={[["ALL","Tous"],["PENDING_REVIEW","À valider"],["PUBLISHED","Publiés"],["REJECTED","Refusés ou retirés"],["DRAFT","Brouillons"],["ARCHIVED","Archivés"]]} />
      <AdminFilter name="categoryId" label="Catégorie" value={query.categoryId} options={[["", "Toutes"],
        ...categories.filter(c => c.active).map((c): [string, string] => [c.id, c.parentId ? `— ${c.name}` : c.name])]} />
      <button className="rounded-lg bg-ink px-4 py-2 text-white">Filtrer</button>
    </form>
    <AdminTableCard table="products" rows={rows} empty={!data.items.length && "Aucun produit pour ce filtre."}>
      <AdminProductsTable items={data.items.map(p => ({ ...p, submitted: dateLabel(p.createdAt) }))} />
    </AdminTableCard>
    <AdminPager sizes={false} data={data} path={ROUTES.adminProducts} query={{ ...query, shopId }} /></>;
}
