"use client";

import Link from "next/link";
import { useState } from "react";
import type { ProductSummary } from "@/lib/types";
import { TabList } from "@/components/ui/Tabs";
import { ProductGrid } from "@/components/product/ProductGrid";
import { ROUTES } from "@/lib/routing/routes";

/** "Recommandé pour vous / Nouveautés / Populaires" rail (W-Home). */
export function ProductRails({ rails }: { rails: { reco: ProductSummary[]; news: ProductSummary[]; popular: ProductSummary[] } }) {
  const [tab, setTab] = useState<"reco" | "news" | "popular">("reco");
  return (
    <section className="flex flex-col gap-5" aria-label="Sélection de produits">
      <div className="flex items-end justify-between gap-4">
        <TabList
          variant="heading"
          label="Sélections"
          value={tab}
          onChange={setTab}
          items={[
            { value: "reco", label: "Recommandé pour vous" },
            { value: "news", label: "Nouveautés" },
            { value: "popular", label: "Populaires" },
          ]}
        />
        <Link href={ROUTES.catalogue} className="hidden shrink-0 pb-2.5 text-[15px] font-bold no-underline sm:block">
          Voir tout
        </Link>
      </div>
      <div role="tabpanel">
        <ProductGrid products={rails[tab]} />
      </div>
    </section>
  );
}
