import type { Metadata } from "next";
import { AdminSidebar, AdminTopbar } from "@/components/layout/AdminNav";

export const metadata: Metadata = { title: { default: "Backoffice", template: "%s · Backoffice In my bush" } };

/** /admin/* — protected by src/proxy.ts (role ADMIN). Desktop-first; sidebar becomes a drawer below 1024 px. */
export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-dvh bg-admin-bg">
      <AdminSidebar />
      <div className="flex min-w-0 flex-1 flex-col">
        <AdminTopbar />
        <main className="flex flex-col gap-5 px-4 pt-6 pb-10 md:px-8 md:pt-7">{children}</main>
      </div>
    </div>
  );
}
