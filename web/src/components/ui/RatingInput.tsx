"use client";

import { useState } from "react";
import { cn } from "@/lib/cn";
import { Icon } from "./Icon";

const LABELS = ["", "Décevant", "Moyen", "Correct", "Très bien", "Excellent"];

/** Star picker (44 px targets, 34 px stars) with a text label. */
export function RatingInput({
  value,
  defaultValue = 0,
  onChange,
  name = "rating",
  className,
}: {
  value?: number;
  defaultValue?: number;
  onChange?: (v: number) => void;
  name?: string;
  className?: string;
}) {
  const [inner, setInner] = useState(defaultValue);
  const v = value ?? inner;
  return (
    <div className={cn("flex flex-wrap items-center gap-3.5", className)}>
      <div role="radiogroup" aria-label="Votre note" className="flex gap-1">
        {[1, 2, 3, 4, 5].map((n) => (
          <button
            key={n}
            type="button"
            role="radio"
            aria-checked={v === n}
            aria-label={`${n} étoile${n > 1 ? "s" : ""}`}
            onClick={() => {
              if (value === undefined) setInner(n);
              onChange?.(n);
            }}
            className={cn("flex size-11 items-center justify-center", n <= v ? "text-orange-500" : "text-line-strong")}
          >
            <Icon name="star" size={34} />
          </button>
        ))}
      </div>
      <input type="hidden" name={name} value={v} />
      {v > 0 && <b className="text-[16px] text-orange-700">{LABELS[v]}</b>}
    </div>
  );
}
