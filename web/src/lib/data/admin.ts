import "server-only";
import { adminApi } from "@/lib/api/admin";
import {
  ADMIN_DASHBOARD,
  ADMIN_ORDERS,
  ADMIN_ORDER_STATS,
  ADMIN_PENDING_PRODUCTS,
  ADMIN_REPORTS,
  ADMIN_USERS,
} from "@/lib/mock/admin";
import { USE_MOCKS, mock } from "./config";

export async function getAdminDashboard() {
  return USE_MOCKS ? mock(ADMIN_DASHBOARD) : adminApi.dashboard();
}

export async function getAdminProducts() {
  return USE_MOCKS ? mock(ADMIN_PENDING_PRODUCTS) : (await adminApi.products("PENDING_REVIEW")).items;
}

export async function getAdminUsers() {
  return USE_MOCKS ? mock(ADMIN_USERS) : (await adminApi.users()).items;
}

export async function getAdminOrders() {
  if (USE_MOCKS) return mock({ rows: ADMIN_ORDERS, stats: ADMIN_ORDER_STATS });
  return { rows: (await adminApi.orders()).items, stats: ADMIN_ORDER_STATS };
}

export async function getAdminReports() {
  return USE_MOCKS ? mock(ADMIN_REPORTS) : (await adminApi.reports()).items;
}
