import { cn } from "@/lib/cn";
import { formatAriary } from "@/lib/format";
import type { Visual } from "@/lib/types";
import { Icon } from "./Icon";

/**
 * Photo placeholder: tinted block + icon (+ optional "Photo · X" caption),
 * exactly like the mockups. Swap for <Image> once products have photos.
 */
export function PhotoPlaceholder({
  visual,
  iconSize = 32,
  caption,
  className,
  rounded = "rounded-[14px]",
  iconOpacity = 1,
  style,
}: {
  visual: Visual;
  iconSize?: number;
  caption?: string;
  className?: string;
  rounded?: string;
  iconOpacity?: number;
  style?: React.CSSProperties;
}) {
  return (
    <span
      role="img"
      aria-label={visual.label ? `Photo : ${visual.label}` : "Photo du produit"}
      className={cn("relative flex shrink-0 items-center justify-center overflow-hidden", rounded, className)}
      style={{ background: visual.tint, color: visual.ink, ...style }}
    >
      <span className="flex" style={{ opacity: iconOpacity }}>
        <Icon name={visual.icon} size={iconSize} />
      </span>
      {caption && (
        <span className="absolute bottom-2 left-2.5 text-[10px] font-bold tracking-[0.08em] uppercase opacity-70">
          {caption}
        </span>
      )}
    </span>
  );
}

/** Price + unit ("18 000 Ar / pot 500 g"), with optional struck compare-at price. */
export function PriceTag({
  price,
  unit,
  compareAt,
  size = "md",
  muted,
  className,
}: {
  price: number;
  unit?: string;
  compareAt?: number | null;
  size?: "sm" | "md" | "lg" | "xl";
  muted?: boolean;
  className?: string;
}) {
  const priceCls = {
    sm: "text-[15px] font-bold",
    md: "text-[17px] font-bold",
    lg: "text-[20px] font-bold",
    xl: "font-display text-[32px] font-extrabold md:text-[40px]",
  }[size];
  return (
    <div className={cn("flex min-w-0 flex-col", className)}>
      {compareAt ? (
        <span className="text-[12px] text-muted line-through font-tabular">{formatAriary(compareAt)}</span>
      ) : null}
      <div className="flex flex-wrap items-baseline gap-[3px]">
        <span
          className={cn(
            "font-tabular",
            priceCls,
            muted ? "text-muted" : compareAt ? "text-orange-700" : "text-ink",
          )}
        >
          {formatAriary(price)}
        </span>
        {unit && <span className={cn("text-muted", size === "xl" ? "text-[17px]" : "text-[12px]")}>/ {unit}</span>}
      </div>
    </div>
  );
}
