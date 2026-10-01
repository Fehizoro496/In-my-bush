import { cn } from "@/lib/cn";
import type { ProductSummary } from "@/lib/types";
import { ProductCard } from "./ProductCard";

/** Responsive product grid: 2 cols phone · 3 tablet · `cols` desktop. */
export function ProductGrid({
  products,
  cols = 5,
  className,
}: {
  products: ProductSummary[];
  cols?: 3 | 4 | 5;
  className?: string;
}) {
  const desk = { 3: "lg:grid-cols-3", 4: "lg:grid-cols-3 xl:grid-cols-4", 5: "lg:grid-cols-4 xl:grid-cols-5" }[cols];
  return (
    <div className={cn("grid grid-cols-2 gap-3 sm:gap-4 md:grid-cols-3 lg:gap-5 xl:gap-6", desk, className)}>
      {products.map((p) => (
        <ProductCard key={p.id} product={p} />
      ))}
    </div>
  );
}
