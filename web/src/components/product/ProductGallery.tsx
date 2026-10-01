"use client";

import { useState } from "react";
import { cn } from "@/lib/cn";
import type { ProductDetail } from "@/lib/types";
import { Icon } from "@/components/ui/Icon";

/** Thumbnails + main photo (W-Product). */
export function ProductGallery({ images, badge }: { images: ProductDetail["images"]; badge?: string }) {
  const [cur, setCur] = useState(0);
  const main = images[cur]!;
  return (
    <div className="flex min-w-0 flex-col-reverse gap-3 md:grid md:grid-cols-[88px_minmax(0,1fr)] md:gap-4">
      <div className="flex gap-3 overflow-x-auto scrollbar-none md:flex-col">
        {images.map((img, i) => (
          <button
            key={img.id}
            type="button"
            aria-label={`Photo ${i + 1}`}
            aria-pressed={i === cur}
            onClick={() => setCur(i)}
            className={cn(
              "flex size-[72px] shrink-0 items-center justify-center rounded-[14px] border-2 md:size-[88px]",
              i === cur ? "border-ink" : "border-transparent",
            )}
            style={{ background: img.visual.tint, color: img.visual.ink }}
          >
            <Icon name={img.visual.icon} size={28} />
          </button>
        ))}
      </div>
      <div
        className="relative flex aspect-square items-center justify-center rounded-[24px] md:aspect-auto md:h-[480px] xl:h-[600px]"
        style={{ background: main.visual.tint, color: main.visual.ink }}
      >
        <span className="flex opacity-50" aria-hidden>
          <Icon name={images[0]!.visual.icon} size={160} />
        </span>
        <span className="absolute bottom-[18px] left-5 text-[12px] font-bold tracking-[0.08em] uppercase opacity-70">
          Photo produit · {cur + 1} / {images.length}
        </span>
        {badge && (
          <span className="absolute top-5 left-5 inline-flex h-7 items-center gap-1 rounded-lg bg-white px-2.5 text-[13px] font-bold text-pomme-800">
            <Icon name="pin" size={14} />
            {badge}
          </span>
        )}
        <button
          type="button"
          aria-label="Agrandir la photo"
          className="absolute right-5 bottom-5 flex size-11 items-center justify-center rounded-full bg-white/95 text-ink"
        >
          <Icon name="search" size={20} />
        </button>
      </div>
    </div>
  );
}
