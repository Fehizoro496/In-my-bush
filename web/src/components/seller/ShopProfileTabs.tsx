"use client";

import { useState, type ReactNode } from "react";
import { cn } from "@/lib/cn";
import { Icon } from "@/components/ui/Icon";
import { TabList } from "@/components/ui/Tabs";
import { Select } from "@/components/ui/Form";

/** Follow button (W-Seller header). */
export function FollowButton() {
  const [on, setOn] = useState(false);
  return (
    <button
      type="button"
      aria-pressed={on}
      onClick={() => setOn(!on)}
      className={cn(
        "flex h-12 items-center gap-2 rounded-md border-[1.5px] border-line-strong bg-white px-[18px] text-[15px] font-bold",
        on ? "text-orange-600" : "text-ink",
      )}
    >
      <Icon name={on ? "heartF" : "heart"} size={18} />
      {on ? "Suivi" : "Suivre"}
    </button>
  );
}

/** Products / Avis / Photos tabs with shop search and sort. */
export function ShopTabs({
  productCount,
  reviewCount,
  products,
  reviews,
}: {
  productCount: number;
  reviewCount: number;
  products: ReactNode;
  reviews: ReactNode;
}) {
  const [tab, setTab] = useState<"products" | "reviews" | "photos">("products");
  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-end justify-between gap-3 border-b border-line-strong">
        <TabList
          label="Contenu de la boutique"
          value={tab}
          onChange={setTab}
          className="border-0"
          items={[
            { value: "products", label: `Produits (${productCount})` },
            { value: "reviews", label: `Avis (${reviewCount})` },
            { value: "photos", label: "Photos" },
          ]}
        />
        <div className="flex gap-2.5 pb-2">
          <label className="flex h-10 w-[220px] items-center gap-2 rounded-[10px] border-[1.5px] border-line-strong bg-white px-3 text-[14px] text-muted xl:w-[260px]">
            <Icon name="search" size={16} />
            <span className="sr-only">Rechercher dans la boutique</span>
            <input placeholder="Rechercher dans la boutique" className="min-w-0 flex-1 border-0 bg-transparent text-ink outline-none focus-visible:outline-none" />
          </label>
          <Select
            aria-label="Trier"
            size="sm"
            className="w-[150px] font-semibold"
            options={[
              { value: "pop", label: "Populaires" },
              { value: "new", label: "Nouveautés" },
              { value: "price", label: "Prix croissant" },
            ]}
          />
        </div>
      </div>
      <div role="tabpanel">
        {tab === "products" && products}
        {tab === "reviews" && reviews}
        {tab === "photos" && (
          <div className="grid grid-cols-2 gap-4 md:grid-cols-3">
            {["#FDE6CC", "#FCD9B0", "#F4F0E6", "#E6F3CC", "#FCEBD2", "#EFE3D3"].map((c, i) => (
              <span key={c} role="img" aria-label={`Photo ${i + 1} de l’exploitation`} className="aspect-square rounded-lg" style={{ background: c }} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
