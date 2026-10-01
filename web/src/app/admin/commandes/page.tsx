import type { Metadata } from "next";
import { OrdersAdmin } from "@/components/admin/OrdersAdmin";
import { getAdminOrders } from "@/lib/data/admin";

export const metadata: Metadata = { title: "Commandes" };

export default async function AdminOrdersPage() {
  const { rows, stats } = await getAdminOrders();
  return <OrdersAdmin rows={rows} stats={stats} />;
}
