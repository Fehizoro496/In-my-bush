"use client";

import { useId, useRef, useState, type KeyboardEvent, type ReactNode } from "react";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "./Icon";

export interface TabItem<T extends string = string> {
  value: T;
  label: ReactNode;
  /** Counter rendered next to the label. */
  count?: ReactNode;
  countTone?: "orange" | "neutral" | "warning";
  icon?: IconName;
  disabled?: boolean;
}

export type TabVariant = "underline" | "segmented" | "heading" | "segmented-dark";

/**
 * Accessible tablist (arrow keys move focus). Controlled or uncontrolled.
 * Variants:
 *  - underline: 3 px green inset bar under the active tab
 *  - segmented: sand track with a white active pill ("J’achète / Je vends", periods)
 *  - heading: big Bricolage titles (home product rails)
 */
export function TabList<T extends string>({
  items,
  value,
  defaultValue,
  onChange,
  variant = "underline",
  label,
  idBase,
  className,
  size = "md",
  fullWidth,
}: {
  items: TabItem<T>[];
  value?: T;
  defaultValue?: T;
  onChange?: (value: T) => void;
  variant?: TabVariant;
  label: string;
  idBase?: string;
  className?: string;
  size?: "sm" | "md";
  fullWidth?: boolean;
}) {
  const [inner, setInner] = useState<T>(defaultValue ?? items[0]!.value);
  const current = value ?? inner;
  const refs = useRef<(HTMLButtonElement | null)[]>([]);
  const auto = useId();
  const base = idBase ?? auto;

  const select = (v: T) => {
    if (value === undefined) setInner(v);
    onChange?.(v);
  };

  const onKeyDown = (e: KeyboardEvent<HTMLButtonElement>, i: number) => {
    const enabled = items.map((it, idx) => (it.disabled ? -1 : idx)).filter((x) => x >= 0);
    const pos = enabled.indexOf(i);
    let next: number | undefined;
    if (e.key === "ArrowRight") next = enabled[(pos + 1) % enabled.length];
    if (e.key === "ArrowLeft") next = enabled[(pos - 1 + enabled.length) % enabled.length];
    if (e.key === "Home") next = enabled[0];
    if (e.key === "End") next = enabled[enabled.length - 1];
    if (next !== undefined) {
      e.preventDefault();
      refs.current[next]?.focus();
      select(items[next]!.value);
    }
  };

  const container = {
    underline: "flex gap-7 overflow-x-auto border-b border-line-strong scrollbar-none",
    heading: "flex gap-6 overflow-x-auto scrollbar-none md:gap-8",
    segmented: cn("inline-flex rounded-md bg-sand p-1", fullWidth && "grid w-full auto-cols-fr grid-flow-col"),
    "segmented-dark": cn("inline-flex gap-2 rounded-md bg-[#EDEAE1] p-1", fullWidth && "grid w-full auto-cols-fr grid-flow-col"),
  }[variant];

  return (
    <div role="tablist" aria-label={label} className={cn(container, className)}>
      {items.map((it, i) => {
        const active = it.value === current;
        const cls = {
          underline: cn(
            "flex h-[46px] shrink-0 items-center gap-1.5 bg-transparent px-0 text-[15px] whitespace-nowrap",
            size === "sm" && "h-11 text-[14px]",
            active ? "font-bold text-ink shadow-[inset_0_-3px_0_#8CC63F]" : "font-medium text-muted hover:text-ink",
          ),
          heading: cn(
            "shrink-0 bg-transparent px-0 pb-2 font-display text-[24px] font-bold tracking-[-0.02em] whitespace-nowrap md:text-[30px]",
            active ? "text-ink shadow-[inset_0_-3px_0_#8CC63F]" : "text-disabled hover:text-muted",
          ),
          segmented: cn(
            "flex items-center justify-center gap-1.5 rounded-sm px-3.5 font-bold whitespace-nowrap",
            size === "sm" ? "h-[38px] text-[13px]" : "h-10 text-[14px]",
            active ? "bg-white text-ink shadow-[0_1px_3px_rgba(31,35,24,0.1)]" : "bg-transparent font-semibold text-body hover:text-ink",
          ),
          "segmented-dark": cn(
            "flex h-[38px] items-center justify-center gap-1.5 rounded-sm px-4 text-[14px] font-bold whitespace-nowrap",
            active ? "bg-white text-ink shadow-[0_1px_2px_rgba(31,35,24,0.1)]" : "bg-transparent text-body hover:text-ink",
          ),
        }[variant];
        const countCls =
          it.countTone === "warning"
            ? "bg-orange-100 text-orange-800 rounded-full px-[7px] py-px text-[12px] font-bold"
            : it.countTone === "neutral"
              ? "bg-sand text-body rounded-full px-[7px] py-px text-[12px] font-bold"
              : "flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-orange-500 px-1 text-[11px] font-extrabold text-on-secondary";
        return (
          <button
            key={it.value}
            ref={(el) => {
              refs.current[i] = el;
            }}
            type="button"
            role="tab"
            id={`${base}-tab-${it.value}`}
            aria-selected={active}
            aria-controls={`${base}-panel-${it.value}`}
            tabIndex={active ? 0 : -1}
            disabled={it.disabled}
            onClick={() => select(it.value)}
            onKeyDown={(e) => onKeyDown(e, i)}
            className={cn(cls, it.disabled && "cursor-not-allowed text-disabled")}
          >
            {it.icon && <Icon name={it.icon} size={16} />}
            {it.label}
            {it.count != null && <span className={countCls}>{it.count}</span>}
          </button>
        );
      })}
    </div>
  );
}

/** Tabs with panels (panels are pre-rendered React nodes, safe to pass from a Server Component). */
export function Tabs<T extends string>({
  items,
  panels,
  defaultValue,
  variant = "underline",
  label,
  className,
  listClassName,
  aside,
}: {
  items: TabItem<T>[];
  panels: Partial<Record<T, ReactNode>>;
  defaultValue?: T;
  variant?: TabVariant;
  label: string;
  className?: string;
  listClassName?: string;
  /** Rendered to the right of the tab list (e.g. "Voir tout"). */
  aside?: ReactNode;
}) {
  const [value, setValue] = useState<T>(defaultValue ?? items[0]!.value);
  const base = useId();
  return (
    <div className={className}>
      <div className={cn("flex items-end justify-between gap-4", listClassName)}>
        <TabList items={items} value={value} onChange={setValue} variant={variant} label={label} idBase={base} />
        {aside}
      </div>
      <div role="tabpanel" id={`${base}-panel-${value}`} aria-labelledby={`${base}-tab-${value}`}>
        {panels[value]}
      </div>
    </div>
  );
}
