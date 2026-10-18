import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminPager, AdminTableCard, dateLabel, pageParam, tableRows, type Search } from "@/components/admin/AdminPageTools";
import { ROUTES } from "@/lib/routing/routes";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { AdminTag } from "@/components/admin/AdminTag";
import { AUDIT_ACTION, TARGET_TYPE } from "@/lib/admin/labels";
export default async function Audit({ searchParams }: { searchParams: Promise<Search> }) {
  await requireAdmin(); const q = await searchParams; const rows = await tableRows("audit"); const data = await adminLive.audit(pageParam(q), rows);
  return <><h1 className="font-display text-3xl font-extrabold">Journal d’administration</h1>
    <AdminTableCard table="audit" rows={rows} empty={!data.items.length && "Aucune action enregistrée."}><Table fill minWidth={900}><THead><Th>Date</Th><Th>Heure</Th><Th>Administrateur</Th><Th>Action</Th><Th>Type de cible</Th><Th className="hidden xl:table-cell">Identifiant</Th><Th>Motif</Th></THead><tbody>
      {data.items.map(e => <Tr key={e.id}><Td>{dateLabel(e.createdAt)}</Td><Td>{new Date(e.createdAt).toLocaleTimeString("fr-FR", { timeZone: "Indian/Antananarivo", hour: "2-digit", minute: "2-digit" })}</Td><Td>{e.actorName ?? "Compte supprimé"}</Td><Td><AdminTag tags={AUDIT_ACTION} value={e.action} /></Td><Td>{TARGET_TYPE[e.targetType] ?? e.targetType}</Td><Td className="hidden w-1/6 max-w-0 truncate font-mono text-[12px] xl:table-cell" title={e.targetId ?? undefined}>{e.targetId ?? "—"}</Td><Td className="w-1/4 max-w-0 truncate" title={e.reason ?? undefined}>{e.reason ?? "—"}</Td></Tr>)}
    </tbody></Table></AdminTableCard>
    <AdminPager sizes={false} data={data} path={ROUTES.adminAudit} /></>;
}
