import type { AuditEvent } from "@/lib/api/admin-contract";
import { AUDIT_ACTION } from "@/lib/admin/labels";
import { AdminTag } from "./AdminTag";

const when = (value: string) => new Date(value).toLocaleString("fr-FR", {
  timeZone: "Indian/Antananarivo", day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit",
});

/** Decisions taken on one account, shop or report, newest first, with who took them and why. */
export function AdminHistory({ events, empty = "Aucune décision pour l’instant." }: { events: AuditEvent[]; empty?: string }) {
  return <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-5">
    <h2 className="font-bold">Historique des décisions</h2>
    {events.length === 0 ? <p className="text-muted">{empty}</p> : <ol className="m-0 flex list-none flex-col gap-3 p-0">
      {events.map(e => <li key={e.id} className="flex flex-col gap-1 border-t border-divider pt-3 first:border-0 first:pt-0">
        <span className="flex flex-wrap items-center gap-2"><AdminTag tags={AUDIT_ACTION} value={e.action} />
          <span className="text-[13px] text-muted">{when(e.createdAt)} · {e.actorName ?? "Compte supprimé"}</span></span>
        {e.reason && <p className="m-0 whitespace-pre-wrap">{e.reason}</p>}
      </li>)}
    </ol>}
  </section>;
}

/** One figure of a backoffice sheet. */
export function AdminFact({ label, children }: { label: string; children: React.ReactNode }) {
  return <div className="rounded-lg bg-bg px-3.5 py-3"><dt className="text-[12px] text-muted">{label}</dt><dd className="m-0 font-bold">{children}</dd></div>;
}
