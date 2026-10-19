import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminActionForm } from "@/components/admin/AdminActionForm";
import { AdminFilter, AdminKeepSize, AdminPager, dateLabel, pageParam, sizeParam, textParam, type Search } from "@/components/admin/AdminPageTools";
import { ROUTES } from "@/lib/routing/routes";
export default async function Reports({searchParams}: {searchParams: Promise<Search>}) {
  await requireAdmin(); const q = await searchParams; const status = textParam(q,"status") || "OPEN";
  const data = await adminLive.reports(status === "ALL" ? "" : status,pageParam(q),sizeParam(q));
  return <><h1 className="font-display text-3xl font-extrabold">Signalements</h1>
    <form action={ROUTES.adminReports} className="flex items-end gap-3"><AdminKeepSize q={q} /><AdminFilter name="status" label="Statut" value={status} options={[["ALL","Tous"],["OPEN","Ouverts"],["IN_REVIEW","En cours"],["RESOLVED","Résolus"],["DISMISSED","Classés sans suite"]]} /><button className="rounded-lg bg-ink px-4 py-2 text-white">Filtrer</button></form>
    {!data.items.length && <p>Aucun signalement pour ce filtre.</p>}
    {data.items.map(r => <article key={r.id} className="rounded-xl border border-line bg-white p-5">
      <h2 className="font-bold">{r.reason}</h2><p className="text-sm text-muted">{r.targetType} · {r.targetId} · {dateLabel(r.createdAt)} · {r.status}</p><p className="my-3 whitespace-pre-wrap">{r.details}</p>
      {r.resolutionNote && <p>Note : {r.resolutionNote}</p>}
      {["OPEN","IN_REVIEW"].includes(r.status) && <AdminActionForm id={r.id} reason actions={[{value:"RESOLVED",label:"Résoudre"},{value:"DISMISSED",label:"Classer sans suite"}]} />}
    </article>)}<AdminPager data={data} path={ROUTES.adminReports} query={{status}} /></>;
}

