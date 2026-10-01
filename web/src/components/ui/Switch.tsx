"use client";

import { useState, type ReactNode } from "react";
import { cn } from "@/lib/cn";

export interface SwitchProps {
  checked?: boolean;
  defaultChecked?: boolean;
  onChange?: (checked: boolean) => void;
  label: string;
  /** Show the label next to the switch (otherwise it is only announced). */
  showLabel?: boolean;
  description?: ReactNode;
  disabled?: boolean;
  size?: "md" | "sm";
  tone?: "pomme" | "orange";
  className?: string;
}

/** Toggle switch (role="switch"). Controlled or uncontrolled. */
export function Switch({
  checked,
  defaultChecked = false,
  onChange,
  label,
  showLabel = false,
  description,
  disabled,
  size = "md",
  tone = "pomme",
  className,
}: SwitchProps) {
  const [inner, setInner] = useState(defaultChecked);
  const on = checked ?? inner;
  const toggle = () => {
    if (disabled) return;
    const next = !on;
    if (checked === undefined) setInner(next);
    onChange?.(next);
  };
  const track = size === "md" ? "h-[26px] w-11" : "h-6 w-10";
  const knob = size === "md" ? "size-5" : "size-[18px]";
  const button = (
    <button
      type="button"
      role="switch"
      aria-checked={on}
      aria-label={showLabel ? undefined : label}
      disabled={disabled}
      onClick={toggle}
      className={cn(
        "relative inline-flex min-h-11 shrink-0 items-center justify-center bg-transparent p-0 disabled:cursor-not-allowed disabled:opacity-70",
        !showLabel && className,
      )}
    >
      <span
        className={cn(
          "flex items-center rounded-full p-[3px] transition-colors duration-200",
          track,
          on ? (tone === "orange" ? "bg-orange-500" : "bg-pomme-600") : "bg-pebble",
          disabled && "bg-line-strong",
        )}
      >
        <span
          className={cn(
            "rounded-full bg-white shadow-[0_1px_3px_rgba(31,35,24,0.25)] transition-transform duration-200",
            knob,
            on && (size === "md" ? "translate-x-[18px]" : "translate-x-4"),
          )}
        />
      </span>
    </button>
  );
  if (!showLabel) return button;
  return (
    <div className={cn("flex min-h-11 items-center justify-between gap-3", className)}>
      <span className="flex flex-col">
        <span className={cn("text-[15px]", disabled && "text-disabled")} id={undefined}>
          {label}
        </span>
        {description && <span className="text-[12px] text-muted">{description}</span>}
      </span>
      {button}
    </div>
  );
}
