import type { Metadata } from "next";
import { Container } from "@/components/layout/Container";
import { BecomeSellerWizard } from "@/components/seller/BecomeSellerWizard";

export const metadata: Metadata = { title: "Ouvrir ma boutique" };

/** Logged-in user without a shop (proxy: session required, SELLER role not required). */
export default function BecomeSellerPage() {
  return (
    <main className="pt-6 pb-16 lg:pt-9">
      <Container>
        <BecomeSellerWizard />
      </Container>
    </main>
  );
}
