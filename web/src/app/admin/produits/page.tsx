import type { Metadata } from "next";
import { PageHeader } from "@/components/layout/Container";
import { ProductModeration } from "@/components/admin/ProductModeration";
import { Button } from "@/components/ui/Button";
import { getAdminProducts } from "@/lib/data/admin";
import { ADMIN_PRODUCT_TABS, REJECTION_REASONS } from "@/lib/mock/admin";

export const metadata: Metadata = { title: "Produits" };

export default async function AdminProductsPage() {
  const rows = await getAdminProducts();
  return (
    <>
      <PageHeader
        size="sm"
        title="Produits"
        subtitle="5 214 publiés · 24 en attente de validation"
        actions={
          <Button variant="neutral" size="sm" icon="download" className="h-10 rounded-[10px] px-3 text-[14px]">
            Exporter CSV
          </Button>
        }
      />
      <ProductModeration rows={rows} tabs={ADMIN_PRODUCT_TABS} reasons={REJECTION_REASONS} />
    </>
  );
}
