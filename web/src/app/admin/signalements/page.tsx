import Link from "next/link";
import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminFilter, AdminPager, AdminTableCard, dateLabel, pageParam, tableRows, textParam, type Search } from "@/components/admin/AdminPageTools";
import { AdminTag } from "@/components/admin/AdminTag";
import { REPORT_STATUS, REPORT_TARGET } from "@/lib/admin/labels";
import { ROUTES } from "@/lib/routing/routes";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
export default async function Reports({ searchParams }: { searchParams: Promise<Search> }) {
  await requireAdmin();
  const q = await searchParams;
  const query = { status: textParam(q, "status") || "OPEN", type: textParam(q, "type") };
  const rows = await tableRows("reports");
  const data = await adminLive.reports({ ...query, status: query.status === "ALL" ? "" : query.status }, pageParam(q), rows);
  return <><h1 className="font-display text-3xl font-extrabold">Signalements</h1>
    <form action={ROUTES.adminReports} className="flex flex-wrap items-end gap-3">
      <AdminFilter name="status" label="Statut" value={query.status} options={[["ALL","Tous"],["OPEN","Ouverts"],["IN_REVIEW","En cours"],["RESOLVED","Résolus"],["DISMISSED","Classés sans suite"]]} />
      <AdminFilter name="type" label="Contenu" value={query.type} options={[["", "Tous"], ...Object.entries(REPORT_TARGET)]} />
      <button className="rounded-lg bg-ink px-4 py-2 text-white">Filtrer</button>
    </form>
    <AdminTableCard table="reports" rows={rows} empty={!data.items.length && "Aucun signalement pour ce filtre."}><Table fill minWidth={760}>
      <THead><Th>Motif</Th><Th>Contenu</Th><Th className="hidden xl:table-cell">Détails</Th><Th>Statut</Th><Th>Reçu le</Th></THead><tbody>
      {data.items.map(r => <Tr key={r.id}>
        <Td className="w-1/4 max-w-0 truncate font-bold" title={r.reason}><Link href={ROUTES.adminReport(r.id)}>{r.reason}</Link></Td>
        <Td>{REPORT_TARGET[r.targetType] ?? r.targetType}</Td>
        <Td className="hidden w-1/3 max-w-0 truncate xl:table-cell" title={r.details ?? undefined}>{r.details ?? "—"}</Td>
        <Td><AdminTag tags={REPORT_STATUS} value={r.status} /></Td>
        <Td>{dateLabel(r.createdAt)}</Td>
      </Tr>)}
    </tbody></Table></AdminTableCard>
    <AdminPager sizes={false} data={data} path={ROUTES.adminReports} query={query} /></>;
}
