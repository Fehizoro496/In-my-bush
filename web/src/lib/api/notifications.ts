/** notifications — GET /notifications?context= · POST /notifications/{id}/read · /notifications/read-all · GET /notifications/unread-count */
import type { AppNotification, NotificationContext, Page } from "@/lib/types";
import { apiFetch } from "./client";

export const notificationsApi = {
  list: (context?: NotificationContext) => apiFetch<Page<AppNotification>>("/notifications", { query: { context } }),
  markRead: (id: string) => apiFetch<void>(`/notifications/${id}/read`, { method: "POST" }),
  markAllRead: () => apiFetch<void>("/notifications/read-all", { method: "POST" }),
  unreadCount: () => apiFetch<{ count: number }>("/notifications/unread-count"),
};
