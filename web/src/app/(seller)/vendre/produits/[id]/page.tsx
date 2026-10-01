import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { EditProductView } from "@/components/seller/EditProductView";
import { getSellerProduct } from "@/lib/data/seller";

export const metadata: Metadata = { title: "Modifier un produit" };

export default async function EditProductPage({ params }: { params: Promise<{ id: string }> }) {
  const product = await getSellerProduct((await params).id);
  if (!product) notFound();
  return <EditProductView product={product} />;
}
