import type { ReactNode } from "react";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "./Icon";

/* ------------------------------------------------------------------ */
/* Skeleton                                                            */
/* ------------------------------------------------------------------ */

export function Skeleton({ className, style }: { className?: string; style?: React.CSSProperties }) {
  return <div aria-hidden className={cn("skeleton rounded-[6px]", className)} style={style} />;
}

/** Skeleton with the exact shape of a ProductCard. */
export function ProductCardSkeleton() {
  return (
    <div className="flex flex-col overflow-hidden rounded-lg border border-line bg-white" aria-hidden>
      <Skeleton className="aspect-[1/0.86] rounded-none" />
      <div className="flex flex-col gap-2.5 p-3.5">
        <Skeleton className="h-2.5 w-3/5" />
        <Skeleton className="h-3.5 w-[90%]" />
        <Skeleton className="h-3.5 w-[70%]" />
        <div className="mt-1.5 flex items-center justify-between">
          <Skeleton className="h-[18px] w-[45%]" />
          <Skeleton className="size-11 rounded-md" />
        </div>
      </div>
    </div>
  );
}

/** Skeleton row for lists (orders, notifications…). */
export function ListRowSkeleton() {
  return (
    <div className="flex items-center gap-3.5 border-b border-divider py-3" aria-hidden>
      <Skeleton className="size-12 shrink-0 rounded-[10px]" />
      <div className="flex flex-1 flex-col gap-2">
        <Skeleton className="h-3 w-[55%]" />
        <Skeleton className="h-2.5 w-[35%]" />
      </div>
      <Skeleton className="h-6 w-20 rounded-full" />
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Empty state                                                         */
/* ------------------------------------------------------------------ */

const EMPTY_TONES = {
  pomme: { bg: "#F0F6E6", ink: "#4A7A12", dot: "#FEE4C7" },
  sand: { bg: "#F4F0E6", ink: "#5B4526", dot: "#E6F3CC" },
  danger: { bg: "#FCEBE9", ink: "#C0352B", dot: "#F4F0E6" },
  orange: { bg: "#FFF4E8", ink: "#D86F12", dot: "#E6F3CC" },
  info: { bg: "#E8F1FA", ink: "#2F6DA8", dot: "#F0F6E6" },
};

export function EmptyState({
  icon,
  title,
  description,
  action,
  tone = "pomme",
  className,
  bordered = true,
}: {
  icon: IconName;
  title: ReactNode;
  description?: ReactNode;
  action?: ReactNode;
  tone?: keyof typeof EMPTY_TONES;
  className?: string;
  bordered?: boolean;
}) {
  const t = EMPTY_TONES[tone];
  return (
    <div
      className={cn(
        "flex flex-col items-center gap-3 px-5 py-7 text-center",
        bordered && "rounded-xl border border-line bg-white",
        className,
      )}
    >
      <div className="relative flex h-24 w-28 items-center justify-center">
        <span className="absolute size-24 rounded-full" style={{ background: t.bg }} />
        <span className="absolute top-1.5 right-0.5 size-[22px] rounded-full" style={{ background: t.dot }} />
        <span className="relative flex" style={{ color: t.ink }}>
          <Icon name={icon} size={40} />
        </span>
      </div>
      <h3 className="m-0 font-display text-[19px] font-bold">{title}</h3>
      {description && <p className="m-0 max-w-[340px] text-[14px] leading-5 text-muted">{description}</p>}
      {action}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Alert (inline)                                                      */
/* ------------------------------------------------------------------ */

const ALERT_TONES = {
  warning: { box: "bg-orange-100 text-warn-ink", icon: "text-orange-700", name: "alert" as IconName },
  danger: { box: "bg-[#FCEBE9] text-[#7A2019]", icon: "text-danger-fg", name: "alert" as IconName },
  info: { box: "bg-info-bg text-info-fg", icon: "text-info-strong", name: "info" as IconName },
  success: { box: "bg-pomme-100 text-[#22380A]", icon: "text-pomme-700", name: "checkCircle" as IconName },
  promo: { box: "bg-orange-50 text-warn-ink", icon: "text-orange-600", name: "percent" as IconName },
};

export function Alert({
  tone = "warning",
  icon,
  children,
  action,
  className,
}: {
  tone?: keyof typeof ALERT_TONES;
  icon?: IconName;
  children: ReactNode;
  action?: ReactNode;
  className?: string;
}) {
  const t = ALERT_TONES[tone];
  return (
    <div
      role={tone === "danger" ? "alert" : "status"}
      className={cn("flex flex-wrap items-center gap-3 rounded-[14px] px-4 py-3 text-[14px] leading-5", t.box, className)}
    >
      <span className={cn("flex shrink-0", t.icon)}>
        <Icon name={icon ?? t.name} size={20} />
      </span>
      <span className="min-w-0 flex-1">{children}</span>
      {action}
    </div>
  );
}
