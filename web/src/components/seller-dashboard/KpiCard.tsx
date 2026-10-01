import Link from "next/link";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "@/components/ui/Icon";

export type KpiTone = "dark" | "default" | "warning";

/** Seller KPI tile (W-Sell-Dashboard). */
export function KpiCard({
  title,
  value,
  sub,
  icon,
  tone = "default",
  subTone = "muted",
}: {
  title: string;
  value: string;
  sub: string;
  icon: IconName;
  tone?: KpiTone;
  subTone?: "up" | "warning" | "muted" | "success";
}) {
  const box = { dark: "bg-pomme-900 border-pomme-900 text-pomme-50", default: "bg-white border-line text-ink", warning: "bg-orange-50 border-orange-300 text-ink" }[tone];
  const subCls = { up: "text-lime", warning: "text-orange-700", muted: "text-muted", success: "text-pomme-800" }[subTone];
  return (
    <div className={cn("flex flex-col gap-2.5 rounded-[18px] border p-[18px]", box)}>
      <div className="flex items-center justify-between gap-2">
        <span className="text-[13px] font-semibold opacity-85">{title}</span>
        <Icon name={icon} size={18} className="opacity-80" />
      </div>
      <span className="font-display text-[26px] leading-none font-extrabold font-tabular xl:text-[30px]">{value}</span>
      <span className={cn("text-[12px] font-bold", subCls)}>{sub}</span>
    </div>
  );
}

/** Admin KPI tile (A-Dashboard): clickable, icon in a tinted square. */
export function AdminKpiCard({
  label,
  value,
  delta,
  tone,
  icon,
  href,
  highlight,
}: {
  label: string;
  value: string;
  delta: string;
  tone: "up" | "down" | "warning" | "danger" | "neutral";
  icon: IconName;
  href: string;
  highlight?: boolean;
}) {
  const deltaCls = { up: "text-pomme-700", down: "text-orange-700", warning: "text-orange-700", danger: "text-danger-fg", neutral: "text-muted" }[tone];
  const iconCls = tone === "warning" ? "bg-orange-100 text-orange-700" : tone === "danger" ? "bg-[#FCEBE9] text-danger-fg" : "bg-pomme-100 text-pomme-700";
  return (
    <Link
      href={href}
      className={cn(
        "flex flex-col gap-2 rounded-lg border px-[18px] py-4 text-ink no-underline transition-shadow hover:text-ink hover:shadow-md",
        highlight ? "border-orange-300 bg-[#FFF7EE]" : "border-line bg-white",
      )}
    >
      <div className="flex items-center justify-between gap-2">
        <span className="text-[13px] font-semibold text-body">{label}</span>
        <span className={cn("flex size-8 items-center justify-center rounded-sm", iconCls)}>
          <Icon name={icon} size={17} />
        </span>
      </div>
      <span className="font-display text-[26px] leading-none font-extrabold font-tabular xl:text-[28px]">{value}</span>
      <span className={cn("text-[12px] font-bold", deltaCls)}>{delta}</span>
    </Link>
  );
}
