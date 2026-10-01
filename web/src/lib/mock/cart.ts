/** Cart & checkout mock (W-Cart, W-Checkout, W-Confirmation). */
import type { Cart, CheckoutDraft } from "@/lib/types";
import { pick, productBySlug, shopBySlug } from "./catalog";
import { ADDRESSES } from "./account";

const miel = productBySlug("miel-de-litchi-cru")!;
const tomates = productBySlug("tomates-coeur-de-boeuf")!;
const bredes = { ...productBySlug("bredes-mafana")!, shop: { ...productBySlug("bredes-mafana")!.shop, name: "Ferme Tsara" } };

export const CART: Cart = {
  id: "cart-1",
  groups: [
    {
      shop: shopBySlug("rucher-ambohimanga"),
      deliveryLabel: "Livraison demain · 3 000 Ar",
      deliveryFee: 3000,
      items: [{ id: "ci-1", product: miel, quantity: 2 }],
    },
    {
      shop: shopBySlug("ferme-tsara"),
      deliveryLabel: "Livraison jeudi · 3 000 Ar",
      deliveryFee: 3000,
      items: [
        { id: "ci-2", product: tomates, quantity: 1 },
        { id: "ci-3", product: bredes, quantity: 2 },
      ],
    },
  ],
  unavailable: [{ name: "Litchis frais", quantityLabel: "2 kg" }],
};

export const CART_SUGGESTIONS = pick(
  "miel-d-eucalyptus",
  "salade-batavia",
  "pollen-frais",
  "carottes-nouvelles",
  "haricots-verts",
);

export const CHECKOUT: CheckoutDraft = {
  addresses: ADDRESSES,
  groups: [
    { shop: shopBySlug("rucher-ambohimanga"), itemCount: 2, homeSlot: "Demain · 8h–12h", homeFee: 3000, pickupInfo: "Ambohimanga · mer. et sam." },
    { shop: shopBySlug("ferme-tsara"), itemCount: 3, homeSlot: "Jeudi · 8h–12h", homeFee: 3000, pickupInfo: "Antsirabe · du lun. au sam." },
  ],
  lines: [
    { name: "Miel de litchi cru", shopName: "Rucher d’Ambohimanga", quantity: 2, total: 36000, visual: miel.visual },
    { name: "Tomates cœur de bœuf", shopName: "Ferme Tsara", quantity: 1, total: 4500, visual: tomates.visual },
    { name: "Brèdes mafana", shopName: "Ferme Tsara", quantity: 2, total: 2000, visual: bredes.visual },
  ],
  subtotal: 42500,
  deliveryTotal: 6000,
  promo: { code: "BIENVENUE", label: "Réduction −10 %", amount: 4250 },
  total: 44250,
};

export const CONFIRMATION = {
  orderNumber: "IMB-24817",
  orderId: "ord-24817",
  firstName: "Hery",
  total: 44250,
  paymentLabel: "Mobile Money",
  itemCount: 5,
  subtotal: 42500,
  delivery: 6000,
  discount: { code: "BIENVENUE", amount: 4250 },
  address: "Domicile · [ADRESSE], Analakely",
  deliveries: [
    { initials: "RA", color: "#D86F12", name: "Rucher d’Ambohimanga", items: "2 × Miel de litchi cru", when: "Livraison demain, 8h–12h" },
    { initials: "FT", color: "#4A7A12", name: "Ferme Tsara", items: "Tomates · Brèdes mafana", when: "Livraison jeudi, 8h–12h" },
  ],
};
