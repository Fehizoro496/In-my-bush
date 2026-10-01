"use client";

import { useState, type ReactNode } from "react";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "./Icon";

export type ChipVariant = "mint" | "dark" | "category";

/**
 * Toggleable filter chip (pill, 38 px). Selected style:
 *  - "mint": light green (filters, tags)
 *  - "dark": ink background (segment-like filters)
 */
export function FilterChip({
  children,
  selected,
  defaultSelected = false,
  onToggle,
  icon,
  variant = "mint",
  size = "md",
  className,
  disabled,
}: {
  children: ReactNode;
  selected?: boolean;
  defaultSelected?: boolean;
  onToggle?: (selected: boolean) => void;
  icon?: IconName;
  variant?: "mint" | "dark" | "darkgreen";
  size?: "sm" | "md";
  className?: string;
  disabled?: boolean;
}) {
  const [inner, setInner] = useState(defaultSelected);
  const on = selected ?? inner;
  const onCls =
    variant === "dark"
      ? "border-ink bg-ink text-white"
      : variant === "darkgreen"
        ? "border-pomme-900 bg-pomme-900 text-pomme-50"
        : "border-pomme-500 bg-mint text-pomme-800";
  return (
    <button
      type="button"
      aria-pressed={on}
      disabled={disabled}
      onClick={() => {
        const next = !on;
        if (selected === undefined) setInner(next);
        onToggle?.(next);
      }}
      className={cn(
        "inline-flex shrink-0 items-center gap-1.5 rounded-full border-[1.5px] font-semibold whitespace-nowrap transition-colors duration-[120ms]",
        size === "md" ? "h-[38px] px-3.5 text-[14px]" : "h-9 px-3 text-[13px] font-bold",
        on ? onCls : "border-line-strong bg-white text-ink hover:border-pebble hover:bg-sand",
        disabled && "border-dashed text-disabled",
        className,
      )}
    >
      {icon && <Icon name={icon} size={16} />}
      {children}
    </button>
  );
}

/** Static chip with an optional remove button (active filter, delivery zone…). */
export function RemovableChip({
  children,
  onRemove,
  size = "md",
  className,
}: {
  children: ReactNode;
  onRemove?: () => void;
  size?: "sm" | "md";
  className?: string;
}) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-0.5 rounded-full bg-mint font-bold text-pomme-800",
        size === "md" ? "h-[34px] pr-1.5 pl-3 text-[13px]" : "h-[30px] pr-1 pl-2.5 text-[13px]",
        className,
      )}
    >
      {children}
      <button
        type="button"
        aria-label={`Retirer ${typeof children === "string" ? children : "le filtre"}`}
        onClick={onRemove}
        className="flex size-[26px] items-center justify-center rounded-full text-pomme-800 hover:bg-pomme-300/50"
      >
        <Icon name="x" size={14} />
      </button>
    </span>
  );
}

/** Group of single-select chips. */
export function ChipGroup<T extends string>({
  options,
  value,
  defaultValue,
  onChange,
  variant = "dark",
  size = "md",
  label,
  className,
}: {
  options: { value: T; label: ReactNode }[];
  value?: T;
  defaultValue?: T;
  onChange?: (v: T) => void;
  variant?: "mint" | "dark" | "darkgreen";
  size?: "sm" | "md";
  label: string;
  className?: string;
}) {
  const [inner, setInner] = useState<T | undefined>(defaultValue ?? options[0]?.value);
  const current = value ?? inner;
  return (
    <div role="group" aria-label={label} className={cn("flex flex-wrap gap-2", className)}>
      {options.map((o) => (
        <FilterChip
          key={o.value}
          variant={variant}
          size={size}
          selected={current === o.value}
          onToggle={() => {
            if (value === undefined) setInner(o.value);
            onChange?.(o.value);
          }}
        >
          {o.label}
        </FilterChip>
      ))}
    </div>
  );
}
