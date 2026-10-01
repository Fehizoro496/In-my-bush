import { cn } from "@/lib/cn";
import { formatRating } from "@/lib/format";
import { Icon } from "./Icon";

/** Read-only star rating (orange stars, grey remainder). */
export function Stars({
  value,
  size = 17,
  className,
  emptyClassName = "text-pebble",
}: {
  value: number;
  size?: number;
  className?: string;
  emptyClassName?: string;
}) {
  const full = Math.round(value);
  return (
    <span
      role="img"
      aria-label={`Note ${formatRating(value)} sur 5`}
      className={cn("inline-flex gap-px text-orange-500", className)}
    >
      {[1, 2, 3, 4, 5].map((n) => (
        <span key={n} className={cn("flex", n > full && emptyClassName)}>
          <Icon name="star" size={size} />
        </span>
      ))}
    </span>
  );
}

/** Compact "★ 4,8 (126)" rating used on cards. */
export function RatingInline({
  value,
  count,
  size = 14,
  className,
}: {
  value: number;
  count?: number;
  size?: number;
  className?: string;
}) {
  return (
    <span className={cn("inline-flex items-center gap-1 text-[13px]", className)}>
      <span className="flex text-orange-500">
        <Icon name="star" size={size} />
      </span>
      <span className="font-semibold">{formatRating(value)}</span>
      {count != null && <span className="text-muted">({count})</span>}
    </span>
  );
}

/** Horizontal distribution bars (5★ … 1★). */
export function RatingBars({
  breakdown,
  className,
  compact,
}: {
  breakdown: { stars: number; count: number }[];
  className?: string;
  compact?: boolean;
}) {
  const total = breakdown.reduce((s, b) => s + b.count, 0) || 1;
  return (
    <div className={cn("flex flex-col", compact ? "gap-[7px]" : "gap-2", className)}>
      {breakdown.map((b) => (
        <div
          key={b.stars}
          className={cn("flex items-center gap-3 text-body", compact ? "gap-2.5 text-[12px] text-muted" : "text-[13px]")}
        >
          <span className={compact ? "w-7" : "w-11"}>{b.stars} ★</span>
          <span className={cn("flex-1 overflow-hidden rounded-full bg-divider", compact ? "h-[7px]" : "h-2")}>
            <span className="block h-full bg-orange-500" style={{ width: `${Math.round((b.count / total) * 100)}%` }} />
          </span>
          <span className={cn("text-right", compact ? "w-5" : "w-8")}>{b.count}</span>
        </div>
      ))}
    </div>
  );
}
