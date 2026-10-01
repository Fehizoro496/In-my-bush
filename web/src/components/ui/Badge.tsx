import type { ReactNode } from "react";
import { cn } from "@/lib/cn";
import type { OrderStatus, ProductStatus } from "@/lib/types";
import { Icon, type IconName } from "./Icon";

export type BadgeTone =
  | "local"
  | "new"
  | "promo"
  | "info"
  | "success"
  | "warning"
  | "neutral"
  | "danger"
  | "mint";

const BADGE_TONES: Record<BadgeTone, string> = {
  local: "bg-pomme-100 text-pomme-800",
  new: "bg-ink text-white",
  promo: "bg-orange-500 text-on-secondary font-extrabold",
  info: "bg-info-bg text-info-fg",
  success: "bg-success-bg text-success-fg",
  warning: "bg-orange-100 text-orange-700",
  neutral: "bg-sand text-muted",
  danger: "bg-danger-bg text-danger-ink",
  mint: "bg-mint text-pomme-800",
};

/** Small rectangular tag (6 px radius) — "Local", "Nouveau", "−20 %", "Plus que 3"… */
export function Badge({
  tone = "neutral",
  icon,
  children,
  className,
}: {
  tone?: BadgeTone;
  icon?: IconName;
  children: ReactNode;
  className?: string;
}) {
  return (
    <span
      className={cn(
        "inline-flex h-6 items-center gap-1 rounded-[6px] px-2 text-[12px] leading-none font-bold whitespace-nowrap",
        BADGE_TONES[tone],
        className,
      )}
    >
      {icon && <Icon name={icon} size={13} />}
      {children}
    </span>
  );
}

/** Orange counter badge — used for every count (cart, messages, notifications). */
export function CountBadge({
  count,
  className,
  ring = false,
  label,
}: {
  count: number | string;
  className?: string;
  /** White 2 px ring when overlapping an icon. */
  ring?: boolean;
  label?: string;
}) {
  return (
    <span
      aria-label={label}
      className={cn(
        "inline-flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-orange-500 px-1 text-[11px] leading-none font-extrabold text-on-secondary",
        ring && "border-2 border-white",
        className,
      )}
    >
      {count}
    </span>
  );
}

export type StatusTone = "warning" | "success" | "info" | "done" | "danger" | "neutral";

const STATUS_TONES: Record<StatusTone, { bg: string; fg: string; dot: string }> = {
  warning: { bg: "bg-orange-100", fg: "text-orange-800", dot: "bg-orange-500" },
  success: { bg: "bg-success-bg", fg: "text-success-fg", dot: "bg-pomme-600" },
  done: { bg: "bg-success-bg", fg: "text-success-fg", dot: "bg-pomme-700" },
  info: { bg: "bg-info-bg", fg: "text-info-fg", dot: "bg-info-strong" },
  danger: { bg: "bg-danger-bg", fg: "text-danger-ink", dot: "bg-danger-fg" },
  neutral: { bg: "bg-sand", fg: "text-body", dot: "bg-disabled" },
};

/** Rounded status pill with a dot — orders, content, accounts. */
export function StatusPill({
  tone,
  children,
  size = "md",
  dot = true,
  className,
}: {
  tone: StatusTone;
  children: ReactNode;
  size?: "sm" | "md";
  dot?: boolean;
  className?: string;
}) {
  const t = STATUS_TONES[tone];
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full font-bold whitespace-nowrap",
        size === "sm" ? "h-6 pr-2.5 pl-2 text-[12px]" : "h-7 pr-3 pl-2.5 text-[13px]",
        t.bg,
        t.fg,
        !dot && "px-3",
        className,
      )}
    >
      {dot && <span className={cn("size-[7px] shrink-0 rounded-full", t.dot)} />}
      {children}
    </span>
  );
}

/* ---------- status helpers ---------- */

export const BUYER_ORDER_STATUS: Record<OrderStatus, { label: string; tone: StatusTone }> = {
  PENDING_CONFIRMATION: { label: "En attente", tone: "warning" },
  ACCEPTED: { label: "En préparation", tone: "warning" },
  PREPARED: { label: "Préparée", tone: "info" },
  IN_DELIVERY: { label: "En route", tone: "info" },
  DELIVERED: { label: "Livrée", tone: "done" },
  REFUSED: { label: "Refusée", tone: "danger" },
  CANCELLED: { label: "Annulée", tone: "neutral" },
};

export const SELLER_ORDER_STATUS: Record<OrderStatus, { label: string; tone: StatusTone }> = {
  PENDING_CONFIRMATION: { label: "Nouvelle", tone: "warning" },
  ACCEPTED: { label: "À préparer", tone: "info" },
  PREPARED: { label: "Préparée", tone: "info" },
  IN_DELIVERY: { label: "Expédiée", tone: "info" },
  DELIVERED: { label: "Livrée", tone: "done" },
  REFUSED: { label: "Refusée", tone: "danger" },
  CANCELLED: { label: "Annulée", tone: "neutral" },
};

export const PRODUCT_STATUS: Record<ProductStatus, { label: string; tone: StatusTone }> = {
  DRAFT: { label: "Brouillon", tone: "neutral" },
  PENDING_REVIEW: { label: "En validation", tone: "info" },
  PUBLISHED: { label: "En ligne", tone: "done" },
  REJECTED: { label: "Refusé", tone: "danger" },
  ARCHIVED: { label: "Archivé", tone: "neutral" },
};

export function OrderStatusPill({
  status,
  side = "buyer",
  size,
}: {
  status: OrderStatus;
  side?: "buyer" | "seller";
  size?: "sm" | "md";
}) {
  const s = (side === "buyer" ? BUYER_ORDER_STATUS : SELLER_ORDER_STATUS)[status];
  return (
    <StatusPill tone={s.tone} size={size}>
      {s.label}
    </StatusPill>
  );
}
