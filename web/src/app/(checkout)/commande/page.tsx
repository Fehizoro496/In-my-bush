import type { Metadata } from "next";
import { Container } from "@/components/layout/Container";
import { CheckoutForm } from "@/components/checkout/CheckoutForm";
import { getCheckoutDraft } from "@/lib/data/cart";

export const metadata: Metadata = { title: "Livraison & paiement" };

export default async function CheckoutPage() {
  const draft = await getCheckoutDraft();
  return (
    <main className="pt-6 pb-16 lg:pt-10">
      <Container>
        <CheckoutForm draft={draft} />
      </Container>
    </main>
  );
}
