import type { Metadata } from "next";
import { UsersAdmin } from "@/components/admin/UsersAdmin";
import { getAdminUsers } from "@/lib/data/admin";
import { ADMIN_USER_TABS } from "@/lib/mock/admin";

export const metadata: Metadata = { title: "Utilisateurs" };

export default async function AdminUsersPage() {
  const users = await getAdminUsers();
  return <UsersAdmin users={users} tabs={ADMIN_USER_TABS} />;
}
