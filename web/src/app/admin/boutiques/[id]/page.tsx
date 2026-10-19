import Link from "next/link";
import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminActionForm } from "@/components/admin/AdminActionForm";
import { AdminFact, AdminHistory } from "@/components/admin/AdminHistory";
import { dateLabel } from "@/components/admin/AdminPageTools";
import { sheetOrNotFound } from "@/lib/admin/sheet";
import { AdminTag } from "@/components/admin/AdminTag";
import { PRODUCT_STATUS, SHOP_STATUS, USER_STATUS } from "@/lib/admin/labels";
import { ROUTES, withQuery } from "@/lib/routing/routes";

/** What a suspension changes, shown before the decision and while it lasts. */
const SUSPENSION_EFFECTS = [
  "La boutique et ses produits disparaissent du catalogue et de la recherche.",
  "Ses produits ne peuvent plus être ajoutés au panier ni commandés.",
  "Les commandes déjà passées ne sont pas annulées : le vendeur doit les honorer.",
  "Le vendeur est prévenu avec le motif et ne peut pas rouvrir sa boutique lui-même.",
];

export default async function ShopSheet({ params }: { params: Promise<{ id: string }> }) {
  await requireAdmin();
  const { shop: s, orderCount, reportCount, history } = await sheetOrNotFound(adminLive.shop((await params).id));
  const suspended = s.status === "SUSPENDED";
  return <>
    <p className="text-sm"><Link href={ROUTES.adminShops}>Boutiques</Link> / {s.name}</p>
    <div className="flex flex-wrap items-center gap-3">
      <h1 className="font-display text-3xl font-extrabold">{s.name}</h1>
      <AdminTag tags={SHOP_STATUS} value={s.status} />
      {!suspended && <Link href={ROUTES.shop(s.slug)} target="_blank" className="text-sm">Voir la page publique</Link>}
    </div>
    {s.description && <p className="m-0 whitespace-pre-wrap">{s.description}</p>}
    <dl className="m-0 grid gap-3 sm:grid-cols-2 xl:grid-cols-5">
      <AdminFact label="Propriétaire"><span className="flex flex-wrap items-center gap-2"><Link href={ROUTES.adminUser(s.ownerId)}>{s.ownerName}</Link>
        {s.ownerStatus !== "ACTIVE" && <AdminTag tags={USER_STATUS} value={s.ownerStatus} />}</span></AdminFact>
      <AdminFact label="Téléphone">{s.ownerPhone}</AdminFact>
      <AdminFact label="Localisation">{[s.city, s.region].filter(Boolean).join(", ") || "—"}</AdminFact>
      <AdminFact label="Commandes reçues">{orderCount}</AdminFact>
      <AdminFact label="Signalements reçus">{reportCount}</AdminFact>
    </dl>
    <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-5">
      <h2 className="font-bold">Produits</h2>
      <ul className="m-0 flex list-none flex-wrap gap-2 p-0">
        {Object.entries(s.productCounts).map(([status, count]) => <li key={status}>
          <Link href={withQuery(ROUTES.adminProducts, { shopId: s.id, status })} className="flex items-center gap-2 rounded-lg border border-line px-3 py-1.5 no-underline">
            <AdminTag tags={PRODUCT_STATUS} value={status} /><b>{count}</b></Link></li>)}
      </ul>
      <p className="m-0 text-sm text-muted">Ouverte le {dateLabel(s.createdAt)} · {s.ratingCount} avis</p>
    </section>
    <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-5">
      <h2 className="font-bold">{suspended ? "Boutique suspendue" : "Suspendre la boutique"}</h2>
      <ul className="m-0 flex flex-col gap-1 pl-5 text-[14px]">{SUSPENSION_EFFECTS.map(e => <li key={e}>{e}</li>)}</ul>
      {suspended
        ? <AdminActionForm id={s.id} actions={[{ value: "reactivateShop", label: "Réactiver la boutique" }]} />
        : <AdminActionForm id={s.id} reason actions={[{ value: "suspendShop", label: "Suspendre la boutique" }]} />}
    </section>
    <AdminHistory events={history} /></>;
}
