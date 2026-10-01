import type { Metadata } from "next";
import { ReportsAdmin } from "@/components/admin/ReportsAdmin";
import { getAdminReports } from "@/lib/data/admin";

export const metadata: Metadata = { title: "Signalements" };

export default async function AdminReportsPage() {
  const reports = await getAdminReports();
  return <ReportsAdmin reports={reports} />;
}
