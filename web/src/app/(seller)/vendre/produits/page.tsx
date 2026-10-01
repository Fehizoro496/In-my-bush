import type { Metadata } from "next";
import { PageHeader } from "@/components/layout/Container";
import { StockTable } from "@/components/seller/StockTable";
import { Button, ButtonLink } from "@/components/ui/Button";
import { getSellerProducts } from "@/lib/data/seller";

export const metadata: Metadata = { title: "Mes produits & stock" };

export default async function StockPage() {
  const rows = await getSellerProducts();
  return (
    <>
      <PageHeader
        title="Mes produits & stock"
        subtitle="14 produits · stock mis à jour il y a 5 min"
        actions={
          <>
            <Button variant="neutral" icon="download" className="px-3.5 text-[14px]">
              Exporter
            </Button>
            <ButtonLink href="/vendre/produits/nouveau" icon="plus" className="px-4 text-[14px]">
              Ajouter un produit
            </ButtonLink>
          </>
        }
      />
      <StockTable rows={rows} />
    </>
  );
}
