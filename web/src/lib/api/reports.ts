/** signalements — POST /reports */
import type { ReportTargetType } from "@/lib/types";
import { apiFetch } from "./client";

export const reportsApi = {
  create: (input: { targetType: ReportTargetType; targetId: string; reason: string; details?: string }) =>
    apiFetch<{ id: string }>("/reports", { method: "POST", body: input }),
};
