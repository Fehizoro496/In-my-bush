import type { Metadata } from "next";
import { NotificationsView } from "@/components/notifications/NotificationsView";
import { getNotifications } from "@/lib/data/account";

export const metadata: Metadata = { title: "Notifications" };

export default async function NotificationsPage() {
  const notifications = await getNotifications();
  return <NotificationsView notifications={notifications} />;
}
