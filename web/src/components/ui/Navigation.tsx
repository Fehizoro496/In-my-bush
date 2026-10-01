import Link from "next/link";
import type { ReactNode } from "react";
import { cn } from "@/lib/cn";
import { Icon } from "./Icon";

/* ------------------------------------------------------------------ */
/* Breadcrumb                                                          */
/* ------------------------------------------------------------------ */

export function Breadcrumb({
  items,
  className,
}: {
  items: { label: string; href?: string }[];
  className?: string;
}) {
  return (
    <nav aria-label="Fil d’Ariane" className={cn("text-[13px] text-muted", className)}>
      <ol className="m-0 flex list-none flex-wrap items-center gap-1.5 p-0">
        {items.map((it, i) => {
          const last = i === items.length - 1;
          return (
            <li key={`${it.label}-${i}`} className="flex items-center gap-1.5">
              {i > 0 && <Icon name="chevR" size={14} />}
              {it.href && !last ? (
                <Link href={it.href} className="text-muted no-underline hover:text-ink">
                  {it.label}
                </Link>
              ) : (
                <span aria-current={last ? "page" : undefined} className={last ? "font-semibold text-ink" : undefined}>
                  {it.label}
                </span>
              )}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}

/* ------------------------------------------------------------------ */
/* Pagination                                                          */
/* ------------------------------------------------------------------ */

function pageList(current: number, total: number): (number | "…")[] {
  if (total <= 5) return Array.from({ length: total }, (_, i) => i + 1);
  if (current <= 3) return [1, 2, 3, "…", total];
  if (current >= total - 2) return [1, "…", total - 2, total - 1, total];
  return [1, "…", current, "…", total];
}

/** Numbered pagination. `hrefFor(page)` builds the link of each page (1-based). */
export function Pagination({
  page,
  totalPages,
  hrefFor,
  summary,
  size = "md",
  className,
}: {
  page: number;
  totalPages: number;
  hrefFor: (page: number) => string;
  summary?: ReactNode;
  size?: "md" | "sm";
  className?: string;
}) {
  const box = size === "md" ? "min-w-10 h-10 rounded-[10px]" : "min-w-[34px] h-[34px] rounded-lg";
  const nav = (
    <nav aria-label="Pagination" className="flex items-center gap-1.5">
      {size === "md" && (
        <Link
          href={hrefFor(Math.max(1, page - 1))}
          aria-label="Page précédente"
          aria-disabled={page <= 1}
          className={cn(
            "flex items-center justify-center border-[1.5px] border-line-strong bg-white text-ink",
            box,
            page <= 1 && "pointer-events-none text-disabled",
          )}
        >
          <Icon name="chevL" size={18} />
        </Link>
      )}
      {pageList(page, totalPages).map((p, i) =>
        p === "…" ? (
          <span key={`e${i}`} className="flex w-[30px] items-center justify-center text-muted">
            …
          </span>
        ) : (
          <Link
            key={p}
            href={hrefFor(p)}
            aria-current={p === page ? "page" : undefined}
            className={cn(
              "flex items-center justify-center px-2 text-[14px] font-bold no-underline",
              box,
              p === page
                ? "bg-ink text-white hover:text-white"
                : "border-[1.5px] border-line-strong bg-white text-ink hover:bg-bg hover:text-ink",
            )}
          >
            {p}
          </Link>
        ),
      )}
      {size === "md" && (
        <Link
          href={hrefFor(Math.min(totalPages, page + 1))}
          aria-label="Page suivante"
          aria-disabled={page >= totalPages}
          className={cn(
            "flex items-center justify-center border-[1.5px] border-line-strong bg-white text-ink",
            box,
            page >= totalPages && "pointer-events-none text-disabled",
          )}
        >
          <Icon name="chevR" size={18} />
        </Link>
      )}
    </nav>
  );
  if (!summary) return <div className={className}>{nav}</div>;
  return (
    <div className={cn("flex flex-wrap items-center justify-between gap-3", className)}>
      <span className="text-[14px] text-muted">{summary}</span>
      {nav}
    </div>
  );
}

/** "Précédent · Suivant" text pagination (tables). */
export function SimplePager({ summary, hasPrev = false, hasNext = true }: { summary: ReactNode; hasPrev?: boolean; hasNext?: boolean }) {
  return (
    <div className="flex flex-wrap items-center justify-between gap-2 border-t border-divider px-4 py-3 text-[13px] text-muted md:px-5">
      <span>{summary}</span>
      <span className="flex gap-3">
        <button type="button" disabled={!hasPrev} className="font-bold text-pomme-700 disabled:text-disabled">
          Précédent
        </button>
        <button type="button" disabled={!hasNext} className="font-bold text-pomme-700 disabled:text-disabled">
          Suivant
        </button>
      </span>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Step progress                                                       */
/* ------------------------------------------------------------------ */

/**
 * Segmented progress (order tracking). Each step: bar + label (+ detail).
 * `current` = number of completed steps.
 */
export function StepBar({
  steps,
  current,
  className,
  showCheck,
  barHeight = 5,
}: {
  steps: { label: string; detail?: string }[];
  current: number;
  className?: string;
  showCheck?: boolean;
  barHeight?: number;
}) {
  return (
    <ol
      className={cn("m-0 grid list-none gap-1.5 p-0 md:gap-2", className)}
      style={{ gridTemplateColumns: `repeat(${steps.length}, minmax(0, 1fr))` }}
    >
      {steps.map((s, i) => {
        const done = i < current;
        return (
          <li key={s.label} className="flex min-w-0 flex-col gap-1.5" aria-current={i === current - 1 ? "step" : undefined}>
            <span className={cn("rounded-[4px]", done ? "bg-pomme-500" : "bg-line-strong")} style={{ height: barHeight }} />
            <span
              className={cn(
                "flex items-center gap-1.5 text-[12px] md:text-[13px]",
                i <= current ? "text-ink" : "text-muted",
                i === current - 1 ? "font-bold" : "font-medium",
              )}
            >
              {showCheck && done && <Icon name="checkCircle" size={15} className="text-pomme-700" />}
              <span className="truncate">{s.label}</span>
            </span>
            {s.detail && <span className="text-[12px] text-muted">{s.detail}</span>}
          </li>
        );
      })}
    </ol>
  );
}

/** Numbered checkout steps (1 · 2 · 3 · 4). */
export function NumberedSteps({
  steps,
  className,
}: {
  steps: { label: string; state: "done" | "current" | "todo" }[];
  className?: string;
}) {
  return (
    <ol aria-label="Étapes" className={cn("m-0 flex list-none items-center gap-2 p-0 text-[14px] md:gap-3.5", className)}>
      {steps.map((s, i) => (
        <li
          key={s.label}
          aria-current={s.state === "current" ? "step" : undefined}
          className={cn(
            "flex items-center gap-2",
            s.state === "todo" ? "text-muted" : "text-ink",
            s.state === "current" ? "font-bold" : "font-medium",
          )}
        >
          <span
            className={cn(
              "flex size-[26px] items-center justify-center rounded-full text-[12px] font-extrabold",
              s.state === "done" && "bg-pomme-500 text-on-primary",
              s.state === "current" && "bg-ink text-white",
              s.state === "todo" && "bg-fog text-muted",
            )}
          >
            {s.state === "done" ? <Icon name="check" size={14} /> : i + 1}
          </span>
          <span className={cn(s.state !== "current" && "hidden xl:inline")}>{s.label}</span>
          {i < steps.length - 1 && <span className="ml-1.5 hidden h-0.5 w-6 bg-line-strong md:block xl:w-10" />}
        </li>
      ))}
    </ol>
  );
}
