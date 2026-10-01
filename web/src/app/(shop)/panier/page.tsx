import type { Metadata } from "next";
import { Container } from "@/components/layout/Container";
import { CartView } from "@/components/cart/CartView";
import { ProductGrid } from "@/components/product/ProductGrid";
import { getCart, getCartSuggestions } from "@/lib/data/cart";

export const metadata: Metadata = { title: "Mon panier" };

export default async function CartPage() {
  const [cart, suggestions] = await Promise.all([getCart(), getCartSuggestions()]);
  return (
    <main className="pt-6 pb-16 lg:pt-8">
      <Container className="flex flex-col gap-10">
        <CartView cart={cart} />
        <section className="flex flex-col gap-[18px]">
          <div className="flex flex-wrap items-baseline gap-x-3.5 gap-y-1">
            <h2 className="m-0 font-display text-[24px] font-bold lg:text-[26px]">Chez les mêmes producteurs</h2>
            <span className="text-[14px] text-muted">sans frais de livraison supplémentaires</span>
          </div>
          <ProductGrid products={suggestions} />
        </section>
      </Container>
    </main>
  );
}
