import type { Metadata } from "next";
import { PageHeader } from "@/components/layout/Container";
import { FavoritesView } from "@/components/account/FavoritesView";
import { Button } from "@/components/ui/Button";
import { getFavorites } from "@/lib/data/account";

export const metadata: Metadata = { title: "Mes favoris" };

export default async function FavoritesPage() {
  const { products, shops } = await getFavorites();
  return (
    <>
      <PageHeader
        title="Mes favoris"
        subtitle={`${products.length} produits · ${shops.length} producteurs suivis`}
        actions={
          <Button icon="cart" size="md" className="text-[14px]">
            Tout ajouter au panier
          </Button>
        }
      />
      <FavoritesView products={products} shops={shops} />
    </>
  );
}
