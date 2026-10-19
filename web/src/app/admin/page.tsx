import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { formatAriary } from "@/lib/format";
export default async function Dashboard() {
  await requireAdmin();
  const d = await adminLive.dashboard();
  const counters = [
    ["Utilisateurs", d.totalUsers], ["Boutiques", d.totalShops], ["Produits", d.totalProducts],
    ["Produits publiés", d.publishedProducts], ["Produits à valider", d.pendingProducts],
    ["Commandes", d.totalOrders], ["Commandes à confirmer", d.pendingOrders], ["Signalements ouverts", d.openReports],
    ["Montant commandé hors annulations et refus", formatAriary(d.totalRevenue)],
    ["Commissions prévues hors annulations et refus", formatAriary(d.totalCommission)],
  ];
  return <><h1 className="font-display text-3xl font-extrabold">Tableau de bord</h1>
    <p className="text-muted">Totaux depuis l’ouverture. Les montants commandés ne représentent pas les encaissements.</p>
    <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">{counters.map(([label, value]) =>
      <section key={label} className="rounded-xl border border-line bg-white p-5"><h2 className="text-sm text-muted">{label}</h2><p className="mt-2 text-2xl font-bold">{value}</p></section>)}</div>
  </>;
}

