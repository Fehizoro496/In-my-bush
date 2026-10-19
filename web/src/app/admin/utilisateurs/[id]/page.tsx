import Link from "next/link";
import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminActionForm } from "@/components/admin/AdminActionForm";
import { AdminFact, AdminHistory } from "@/components/admin/AdminHistory";
import { dateLabel } from "@/components/admin/AdminPageTools";
import { sheetOrNotFound } from "@/lib/admin/sheet";
import { AdminTag } from "@/components/admin/AdminTag";
import { ROLE, SHOP_STATUS, USER_STATUS } from "@/lib/admin/labels";
import { ROUTES } from "@/lib/routing/routes";
import type { UserStatus } from "@/lib/types";

const ACTIONS: Record<UserStatus, { value: string; label: string }[]> = {
  ACTIVE: [{ value: "suspend", label: "Suspendre" }, { value: "ban", label: "Bannir" }],
  SUSPENDED: [{ value: "reactivate", label: "Réactiver" }, { value: "ban", label: "Bannir" }],
  BANNED: [{ value: "reactivate", label: "Réactiver" }],
};

export default async function UserSheet({ params }: { params: Promise<{ id: string }> }) {
  const current = await requireAdmin();
  const { user: u, shop, orderCount, reportCount, history } = await sheetOrNotFound(adminLive.user((await params).id));
  return <>
    <p className="text-sm"><Link href={ROUTES.adminUsers}>Utilisateurs</Link> / {u.firstName} {u.lastName}</p>
    <div className="flex flex-wrap items-center gap-3">
      <h1 className="font-display text-3xl font-extrabold">{u.firstName} {u.lastName}</h1>
      <AdminTag tags={USER_STATUS} value={u.status} />
      {u.roles.map(r => <AdminTag key={r} tags={ROLE} value={r} />)}
    </div>
    <dl className="m-0 grid gap-3 sm:grid-cols-2 xl:grid-cols-5">
      <AdminFact label="E-mail">{u.email ?? "—"}</AdminFact>
      <AdminFact label="Téléphone">{u.phone}</AdminFact>
      <AdminFact label="Inscription">{dateLabel(u.createdAt)}</AdminFact>
      <AdminFact label="Commandes passées">{orderCount}</AdminFact>
      <AdminFact label="Signalements reçus">{reportCount}</AdminFact>
    </dl>
    {shop && <section className="flex flex-col gap-2 rounded-xl border border-line bg-white p-5">
      <h2 className="font-bold">Boutique</h2>
      <p className="m-0 flex flex-wrap items-center gap-2"><Link href={ROUTES.adminShop(shop.id)} className="font-bold">{shop.name}</Link>
        <AdminTag tags={SHOP_STATUS} value={shop.status} /></p>
      {u.status !== "ACTIVE" && shop.status !== "SUSPENDED" && <p role="note" className="m-0 rounded-lg bg-orange-100 p-3 text-orange-800">
        La boutique reste visible et peut recevoir des commandes : suspendez-la depuis sa fiche pour bloquer ses ventes.</p>}
    </section>}
    <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-5">
      <h2 className="font-bold">Décision</h2>
      {u.id === current.id ? <p className="m-0 text-muted">C’est votre compte : vous ne pouvez pas le suspendre ni le bannir.</p> : <>
        <p className="m-0 text-muted">Une suspension ou un bannissement ferme aussitôt les sessions du compte ; la personne est prévenue par SMS avec le motif.</p>
        <AdminActionForm id={u.id} reason actions={ACTIONS[u.status]} />
      </>}
    </section>
    <AdminHistory events={history} /></>;
}
