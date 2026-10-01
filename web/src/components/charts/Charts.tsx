import { cn } from "@/lib/cn";

/** Vertical bar chart (CSS). The last bar is highlighted. */
export function BarChart({
  values,
  max,
  yTicks,
  xLabels,
  height = 220,
  label,
  valueLabel,
  showValues,
  gap = 4,
  className,
}: {
  values: number[];
  max: number;
  yTicks?: string[];
  xLabels: string[];
  height?: number;
  label: string;
  valueLabel?: (v: number, i: number) => string;
  showValues?: boolean;
  gap?: number;
  className?: string;
}) {
  return (
    <figure className={cn("m-0 grid gap-2", yTicks ? "grid-cols-[36px_minmax(0,1fr)]" : "grid-cols-1", className)} aria-label={label}>
      {yTicks && (
        <div className="flex flex-col justify-between pb-5 text-right text-[11px] text-muted" style={{ height }} aria-hidden>
          {yTicks.map((t) => (
            <span key={t}>{t}</span>
          ))}
        </div>
      )}
      <div className="flex flex-col gap-1.5">
        <div
          role="list"
          className="flex items-end border-b border-line-strong"
          style={{
            height: height - 20,
            gap,
            background: yTicks ? "linear-gradient(#F1EEE5 1px, transparent 1px) 0 0 / 100% 25%" : undefined,
          }}
        >
          {values.map((v, i) => {
            const text = valueLabel ? valueLabel(v, i) : String(v);
            return (
              <div key={i} role="listitem" className="flex h-full flex-1 flex-col items-center justify-end gap-1" title={text}>
                {showValues && <span className="text-[11px] text-muted">{text}</span>}
                <span
                  aria-label={text}
                  className={cn("w-full rounded-t-[4px]", showValues && "rounded-t-[6px]", i === values.length - 1 ? "bg-pomme-600" : "bg-pomme-300")}
                  style={{ height: `${Math.round((v / max) * 100)}%` }}
                />
              </div>
            );
          })}
        </div>
        <div className="flex justify-between text-[11px] text-muted" aria-hidden>
          {xLabels.map((l, i) => (
            <span key={`${l}-${i}`} className={cn(xLabels.length === values.length && "flex-1 basis-0 text-center")}>
              {l}
            </span>
          ))}
        </div>
      </div>
    </figure>
  );
}

/** Line chart (SVG): current series with area + dashed comparison series. */
export function LineChart({
  current,
  previous,
  max,
  labels,
  yTicks,
  label,
  height = 220,
}: {
  current: number[];
  previous?: number[];
  max: number;
  labels: string[];
  yTicks: string[];
  label: string;
  height?: number;
}) {
  const W = 680;
  const H = height;
  const pts = (arr: number[]) => arr.map((v, i) => [Math.round((i * W) / (arr.length - 1)), Math.round(H - (v / max) * H)] as const);
  const path = (p: readonly (readonly [number, number])[]) => p.map((q, i) => `${i ? "L" : "M"}${q[0]} ${q[1]}`).join(" ");
  const c = pts(current);
  const last = c[c.length - 1]!;
  return (
    <div className="grid grid-cols-[32px_minmax(0,1fr)] gap-2">
      <div className="flex flex-col justify-between text-right text-[11px] text-muted" style={{ height: H }} aria-hidden>
        {yTicks.map((t) => (
          <span key={t}>{t}</span>
        ))}
      </div>
      <div className="flex flex-col gap-1.5">
        <svg width="100%" height={H} viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="none" role="img" aria-label={label} className="block overflow-visible">
          <path d={`M0 0H${W}M0 ${H / 4}H${W}M0 ${H / 2}H${W}M0 ${(3 * H) / 4}H${W}M0 ${H}H${W}`} stroke="#F1EEE5" strokeWidth={1} vectorEffect="non-scaling-stroke" />
          {previous && <path d={path(pts(previous))} fill="none" stroke="#A3A094" strokeWidth={2} strokeDasharray="5 5" vectorEffect="non-scaling-stroke" />}
          <path d={`${path(c)} L${W} ${H} L0 ${H} Z`} fill="rgba(140,198,63,0.16)" />
          <path d={path(c)} fill="none" stroke="#4A7A12" strokeWidth={2.5} strokeLinejoin="round" strokeLinecap="round" vectorEffect="non-scaling-stroke" />
          <circle cx={last[0]} cy={last[1]} r={5} fill="#FFFFFF" stroke="#4A7A12" strokeWidth={2.5} vectorEffect="non-scaling-stroke" />
        </svg>
        <div className="flex justify-between text-[11px] text-muted" aria-hidden>
          {labels.map((m, i) => (
            <span key={m} className={i % 2 ? "hidden sm:inline" : undefined}>
              {m}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
}

/** Horizontal progress bar list (top categories). */
export function HBarList({ items }: { items: { label: string; value: number; width: number }[] }) {
  return (
    <ul className="m-0 flex list-none flex-col gap-3.5 p-0">
      {items.map((c) => (
        <li key={c.label} className="flex flex-col gap-[5px]">
          <div className="flex justify-between text-[13px]">
            <span className="font-semibold">{c.label}</span>
            <span className="text-body font-tabular">{c.value} %</span>
          </div>
          <span className="h-2 overflow-hidden rounded-full bg-divider">
            <span className="block h-full rounded-full bg-pomme-600" style={{ width: `${c.width}%` }} />
          </span>
        </li>
      ))}
    </ul>
  );
}
