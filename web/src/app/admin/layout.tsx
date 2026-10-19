import type { Metadata } from "next";
import { AdminSidebar, AdminTopbar } from "@/components/layout/AdminNav";
import { requireAdmin } from "@/lib/auth/require-user";
import { adminLive } from "@/lib/api/admin-live";

export const metadata: Metadata = { title: { default: "Backoffice", template: "%s · Backoffice In my bush" } };

/** /admin/* — protected by src/proxy.ts (role ADMIN). Desktop-first; sidebar becomes a drawer below 1024 px. */
export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const user = await requireAdmin();
  const counts = await adminLive.dashboard();
  return (
    // From 1024 px the shell is exactly one screen high: <main> scrolls when its content is taller,
    // and paginated tables (AdminTableCard) take the height left instead of lengthening the page.
    <div className="flex min-h-dvh bg-admin-bg lg:h-dvh lg:overflow-hidden">
      <AdminSidebar user={user} counts={counts} />
      <div className="flex min-w-0 flex-1 flex-col lg:min-h-0">
        <AdminTopbar user={user} counts={counts} />
        <main className="flex flex-col gap-5 px-4 pt-6 pb-10 md:px-8 md:pt-7 lg:min-h-0 lg:flex-1 lg:overflow-y-auto lg:pb-6">{children}</main>
      </div>
    </div>
  );
}
