import Link from "next/link";
import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminActionForm } from "@/components/admin/AdminActionForm";
import { AdminFact, AdminHistory } from "@/components/admin/AdminHistory";
import { dateLabel } from "@/components/admin/AdminPageTools";
import { sheetOrNotFound } from "@/lib/admin/sheet";
import { AdminReportTarget } from "@/components/admin/AdminReportTarget";
import { AdminTag } from "@/components/admin/AdminTag";
import { REPORT_STATUS, REPORT_TARGET } from "@/lib/admin/labels";
import { ROUTES } from "@/lib/routing/routes";

export default async function ReportSheet({ params }: { params: Promise<{ id: string }> }) {
  await requireAdmin();
  const d = await sheetOrNotFound(adminLive.report((await params).id));
  const r = d.report;
  const closed = r.status === "RESOLVED" || r.status === "DISMISSED";
  return <>
    <p className="text-sm"><Link href={ROUTES.adminReports}>Signalements</Link> / {r.reason}</p>
    <div className="flex flex-wrap items-center gap-3">
      <h1 className="font-display text-3xl font-extrabold">{r.reason}</h1>
      <AdminTag tags={REPORT_STATUS} value={r.status} />
    </div>
    <dl className="m-0 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
      <AdminFact label="Contenu signalé">{REPORT_TARGET[r.targetType] ?? r.targetType}</AdminFact>
      <AdminFact label="Signalé par">{d.reporterName ?? "Compte supprimé"}</AdminFact>
      <AdminFact label="Reçu le">{dateLabel(r.createdAt)}</AdminFact>
      <AdminFact label="Signalements sur ce contenu">{d.targetReportCount}</AdminFact>
    </dl>
    {r.details && <section className="rounded-xl border border-line bg-white p-5"><h2 className="mb-1 font-bold">Message du signaleur</h2>
      <p className="m-0 whitespace-pre-wrap">{r.details}</p></section>}
    <AdminReportTarget type={r.targetType} target={d.target} />
    <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-5">
      <h2 className="font-bold">Décision</h2>
      {closed ? <p className="m-0">
        {r.status === "RESOLVED" ? "Résolu" : "Classé sans suite"}
        {d.resolvedByName && <> par {d.resolvedByName}</>}{r.resolvedAt && <> le {dateLabel(r.resolvedAt)}</>} : {r.resolutionNote}
      </p> : <>
        {r.status === "OPEN" && <AdminActionForm id={r.id} actions={[{ value: "IN_REVIEW", label: "Prendre en charge" }]} />}
        <p className="m-0 text-muted">Le motif de la décision est conservé dans l’historique. Le signaleur apprend seulement l’issue, jamais le motif ni les notes.</p>
        <AdminActionForm id={r.id} reason actions={[{ value: "RESOLVED", label: "Résoudre" }, { value: "DISMISSED", label: "Classer sans suite" }]} />
      </>}
    </section>
    <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-5">
      <h2 className="font-bold">Notes internes</h2>
      {d.notes.length === 0 && <p className="m-0 text-muted">Aucune note.</p>}
      {d.notes.map(n => <article key={n.id} className="rounded-lg bg-bg p-3">
        <p className="m-0 text-[13px] text-muted">{n.authorName ?? "Compte supprimé"} · {dateLabel(n.createdAt)}</p>
        <p className="m-0 whitespace-pre-wrap">{n.body}</p></article>)}
      {!closed && <AdminActionForm id={r.id} reason actions={[{ value: "note", label: "Ajouter la note" }]} />}
    </section>
    <AdminHistory events={d.history} /></>;
}
