import type { ProductSummary } from "../types";

/** Shape returned by ProductSummaryResponse, before presentation defaults. */
export type HomeProductResponse = Omit<ProductSummary, "visual" | "stockLevel" | "categorySlug"> & {
  stockStatus: "IN_STOCK" | "LOW_STOCK" | "OUT_OF_STOCK";
  category: { id: string; slug: string; name: string } | null;
};

export function toHomeProduct(product: HomeProductResponse): ProductSummary {
  const { stockStatus, category, ...fields } = product;
  return {
    ...fields,
    stockLevel: { IN_STOCK: "OK", LOW_STOCK: "LOW", OUT_OF_STOCK: "OUT" }[stockStatus] as ProductSummary["stockLevel"],
    categorySlug: category?.slug ?? "",
    visual: { tint: "#EEF3E4", ink: "#4A7A12", icon: "leaf" },
  };
}
