"use client";

import { useState } from "react";
import { cn } from "@/lib/cn";
import { Icon } from "./Icon";

export interface QuantityStepperProps {
  value?: number;
  defaultValue?: number;
  min?: number;
  max?: number;
  onChange?: (value: number) => void;
  /** lg = product page (54 px), md = 44 px (default), sm = 40 px (cart), xs = 32 px (tables). */
  size?: "xs" | "sm" | "md" | "lg";
  label?: string;
  className?: string;
  valueClassName?: string;
  warn?: boolean;
}

const SIZES = {
  xs: { btn: "size-8", val: "min-w-10 text-[14px]", icon: 14, radius: "rounded-[9px]" },
  sm: { btn: "size-10", val: "w-9 text-[15px]", icon: 16, radius: "rounded-md" },
  md: { btn: "size-11", val: "w-12 text-[16px]", icon: 18, radius: "rounded-md" },
  lg: { btn: "h-[54px] w-12", val: "w-10 text-[17px]", icon: 18, radius: "rounded-md" },
};

export function QuantityStepper({
  value,
  defaultValue = 1,
  min = 1,
  max = 999,
  onChange,
  size = "md",
  label = "Quantité",
  className,
  valueClassName,
  warn,
}: QuantityStepperProps) {
  const [inner, setInner] = useState(defaultValue);
  const v = value ?? inner;
  const s = SIZES[size];
  const set = (n: number) => {
    const next = Math.max(min, Math.min(max, n));
    if (value === undefined) setInner(next);
    onChange?.(next);
  };
  return (
    <div
      role="group"
      aria-label={label}
      className={cn(
        "inline-flex shrink-0 items-center border-[1.5px] bg-white",
        warn ? "border-[#F7AA5A]" : "border-line-strong",
        s.radius,
        className,
      )}
    >
      <button
        type="button"
        aria-label="Diminuer"
        disabled={v <= min}
        onClick={() => set(v - 1)}
        className={cn("flex items-center justify-center text-ink disabled:text-disabled", s.btn)}
      >
        <Icon name="minus" size={s.icon} />
      </button>
      <output aria-live="polite" className={cn("text-center font-bold font-tabular", s.val, valueClassName)}>
        {v}
      </output>
      <button
        type="button"
        aria-label="Augmenter"
        disabled={v >= max}
        onClick={() => set(v + 1)}
        className={cn("flex items-center justify-center text-ink disabled:text-disabled", s.btn)}
      >
        <Icon name="plus" size={s.icon} />
      </button>
    </div>
  );
}
