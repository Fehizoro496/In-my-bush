import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminCategoriesTable, AdminCategoryCreate } from "@/components/admin/AdminCategories";
import { AdminPager, AdminTableCard, pageParam, tableRows, type Search } from "@/components/admin/AdminPageTools";
import { pageOf } from "@/lib/admin/pagination";
import { ROUTES } from "@/lib/routing/routes";
export default async function Categories({ searchParams }: { searchParams: Promise<Search> }) {
  await requireAdmin();
  const q = await searchParams;
  const rows = await tableRows("categories");
  const all = await adminLive.categories();
  const data = pageOf(all, pageParam(q), rows);
  return <><div className="flex flex-wrap items-center justify-between gap-3">
      <h1 className="font-display text-3xl font-extrabold">Catégories</h1>
      <AdminCategoryCreate all={all} />
    </div>
    <p className="text-muted">Ordre d’affichage du catalogue. Une catégorie désactivée n’apparaît plus et ses produits sont déplacés.</p>
    <AdminTableCard table="categories" rows={rows} empty={!data.items.length && "Aucune catégorie."}>
      <AdminCategoriesTable items={data.items} all={all} />
    </AdminTableCard>
    <AdminPager sizes={false} data={data} path={ROUTES.adminCategories} /></>;
}
