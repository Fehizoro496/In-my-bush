"use client";

import { useState } from "react";
import type { ProductSummary, ShopSummary } from "@/lib/types";
import { TabList } from "@/components/ui/Tabs";
import { Alert } from "@/components/ui/Feedback";
import { ProductCard } from "@/components/product/ProductCard";
import { SellerCard } from "@/components/seller/SellerCard";

export function FavoritesView({ products, shops }: { products: ProductSummary[]; shops: ShopSummary[] }) {
  const [tab, setTab] = useState<"products" | "shops">("products");
  return (
    <div className="flex flex-col gap-[18px]">
      <TabList
        label="Favoris"
        value={tab}
        onChange={setTab}
        items={[
          { value: "products", label: `Produits (${products.length})` },
          { value: "shops", label: `Producteurs (${shops.length})` },
        ]}
      />
      <Alert tone="promo" action={<a href="#" className="font-bold text-orange-800 no-underline">Gérer les alertes</a>}>
        <b>2 favoris en promotion</b> et 1 de retour en stock · alertes activées
      </Alert>
      {tab === "products" ? (
        <div className="grid grid-cols-2 gap-3 sm:gap-4 md:grid-cols-3 xl:grid-cols-4 xl:gap-5">
          {products.map((p) => (
            <ProductCard key={p.id} product={p} />
          ))}
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3 xl:gap-5">
          {shops.map((s) => (
            <SellerCard key={s.id} shop={s} />
          ))}
        </div>
      )}
    </div>
  );
}
