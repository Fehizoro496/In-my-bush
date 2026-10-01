import type { Metadata } from "next";
import { ProductForm } from "@/components/seller/ProductForm";

export const metadata: Metadata = { title: "Ajouter un produit" };

export default function AddProductPage() {
  return <ProductForm />;
}
