import Link from "next/link";
import { adminLive } from "@/lib/api/admin-live";
import { requireAdmin } from "@/lib/auth/require-user";
import { AdminActionForm } from "@/components/admin/AdminActionForm";
import { AdminFilter, AdminTableCard, AdminPager, dateLabel, pageParam, tableRows, textParam, type Search } from "@/components/admin/AdminPageTools";
import { ROUTES } from "@/lib/routing/routes";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { AdminTag } from "@/components/admin/AdminTag";
import { ROLE, USER_STATUS } from "@/lib/admin/labels";
export default async function Users({searchParams}: {searchParams: Promise<Search>}) {
  const current = await requireAdmin();
  const q = await searchParams;
  const query = {q:textParam(q,"q"), role:textParam(q,"role"), status:textParam(q,"status")};
  const rows = await tableRows("users");
  const data = await adminLive.users({...query,page:pageParam(q),size:rows});
  return <><h1 className="font-display text-3xl font-extrabold">Utilisateurs et vendeurs</h1>
    <form action={ROUTES.adminUsers} className="flex flex-wrap items-end gap-3">
      <label className="flex flex-col gap-1 text-sm">Nom, e-mail ou téléphone<input name="q" defaultValue={query.q} className="rounded-lg border border-line bg-white p-2" /></label>
      <AdminFilter name="role" label="Rôle" value={query.role} options={[["","Tous"],["BUYER","Acheteur"],["SELLER","Vendeur"],["ADMIN","Administrateur"]]} />
      <AdminFilter name="status" label="Statut" value={query.status} options={[["","Tous"],["ACTIVE","Actif"],["SUSPENDED","Suspendu"],["BANNED","Banni"]]} />
      <button className="rounded-lg bg-ink px-4 py-2 text-white">Rechercher</button>
    </form>
    <AdminTableCard table="users" rows={rows} empty={!data.items.length && "Aucun utilisateur pour ces critères."}><Table fill minWidth={850}><THead><Th>Nom</Th><Th>E-mail</Th><Th className="hidden xl:table-cell">Téléphone</Th><Th>Rôles</Th><Th>Statut</Th><Th className="hidden xl:table-cell">Inscription</Th><Th>Action</Th></THead><tbody>
      {data.items.map(u => <Tr key={u.id}><Td className="font-bold whitespace-nowrap"><Link href={ROUTES.adminUser(u.id)}>{u.firstName} {u.lastName}</Link></Td><Td className="max-w-0 w-1/5 truncate" title={u.email ?? undefined}>{u.email ?? "—"}</Td><Td className="hidden whitespace-nowrap xl:table-cell">{u.phone}</Td>
        <Td><span className="flex gap-1">{u.roles.map(r => <AdminTag key={r} tags={ROLE} value={r} />)}</span></Td><Td><AdminTag tags={USER_STATUS} value={u.status} /></Td><Td className="hidden xl:table-cell">{dateLabel(u.createdAt)}</Td>
        <Td>{u.id === current.id ? "Votre compte" : <AdminActionForm compact id={u.id} reason actions={u.status === "ACTIVE" ? [{value:"suspend",label:"Suspendre"},{value:"ban",label:"Bannir"}] : [{value:"reactivate",label:"Réactiver"}]} />}</Td></Tr>)}
    </tbody></Table></AdminTableCard>
    <AdminPager sizes={false} data={data} path={ROUTES.adminUsers} query={query} /></>;
}

