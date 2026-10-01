/** Buyer-side mock data (W-Account, W-Order-Detail, W-Favorites, W-Messages, W-Notifications…). */
import type {
  Address,
  AppNotification,
  BuyerOrderDetail,
  BuyerOrderSummary,
  Conversation,
  Message,
  OrderItem,
  User,
  Visual,
} from "@/lib/types";
import { pick, SHOPS } from "./catalog";

export const CURRENT_USER: User = {
  id: "user-hery",
  firstName: "Hery",
  lastName: "Rakoto",
  email: "hery.r@example.mg",
  phone: "+261 34 •• ••• 12",
  avatarUrl: null,
  status: "ACTIVE",
  roles: ["BUYER", "SELLER"],
  createdAt: "2024-03-02T09:00:00+03:00",
  shop: { id: "shop-007", name: "Le Jardin de Hery", slug: "le-jardin-de-hery", status: "ACTIVE" },
};

/** Counters displayed in the header / account navigation. */
export const COUNTERS = {
  cart: 3,
  ordersInProgress: 2,
  unreadMessages: 3,
  reviewsToLeave: 2,
  lowStock: 3,
  ordersToHandle: 3,
  unreadNotifications: 5,
};

export const ADDRESSES: Address[] = [
  {
    id: "addr-1",
    label: "Domicile",
    recipient: "Hery Rakoto",
    phone: "+261 34 •• ••• 12",
    line1: "[ADRESSE]",
    district: "Analakely",
    city: "Antananarivo 101",
    landmark: "portail vert face à l’épicerie",
    isDefault: true,
  },
  {
    id: "addr-2",
    label: "Bureau",
    recipient: "Hery Rakoto",
    phone: "+261 34 •• ••• 12",
    line1: "[ADRESSE]",
    district: "Ankorondrano",
    city: "Antananarivo 101",
    landmark: "immeuble blanc, 2e étage",
    isDefault: false,
  },
];

const v = (tint: string, ink: string, icon: Visual["icon"]): Visual => ({ tint, ink, icon });

export const BUYER_ORDERS: BuyerOrderSummary[] = [
  {
    id: "ord-24817",
    number: "IMB-24817",
    createdAt: "2026-09-26T18:02:00+03:00",
    total: 44250,
    paymentLabel: "Mobile Money",
    status: "IN_DELIVERY",
    itemCount: 5,
    summary: "5 articles · Rucher d’Ambohimanga, Ferme Tsara · arrivée aujourd’hui 10h–11h",
    thumbnails: [v("#FDE6CC", "#B4500A", "sprout"), v("#F6E3D6", "#B4500A", "leaf"), v("#DDEBC9", "#365A10", "leaf")],
    progress: 3,
  },
  {
    id: "ord-24790",
    number: "IMB-24790",
    createdAt: "2026-09-19T11:20:00+03:00",
    total: 27000,
    paymentLabel: "À la réception",
    status: "ACCEPTED",
    itemCount: 2,
    summary: "2 articles · Café des Hautes Terres · livraison prévue lundi",
    thumbnails: [v("#E6DACB", "#5B3A1E", "package"), v("#EFE3D3", "#7A5A2E", "basket")],
    progress: 2,
  },
  {
    id: "ord-24655",
    number: "IMB-24655",
    createdAt: "2026-09-02T15:40:00+03:00",
    total: 15500,
    paymentLabel: "Mobile Money",
    status: "DELIVERED",
    itemCount: 3,
    summary: "3 articles · Atelier Hazo · livrée le 3 sept.",
    thumbnails: [v("#DCE8D2", "#365A10", "sprout"), v("#F4F0E6", "#5B4526", "store")],
    progress: null,
  },
  {
    id: "ord-24512",
    number: "IMB-24512",
    createdAt: "2026-08-12T09:10:00+03:00",
    total: 8000,
    paymentLabel: "Mobile Money",
    status: "CANCELLED",
    itemCount: 1,
    summary: "1 article · Jardins de Behenjy · annulée, remboursée sur MVola",
    thumbnails: [v("#F8DADF", "#9A2F45", "leaf")],
    progress: null,
  },
];

const item = (
  id: string,
  name: string,
  unitPrice: number,
  unitLabel: string,
  quantity: number,
  quantityLabel: string,
  visual: Visual,
): OrderItem => ({
  id,
  productId: `p-${id}`,
  productName: name,
  unitPrice,
  unitLabel,
  quantity,
  quantityLabel,
  lineTotal: unitPrice * quantity,
  visual,
});

export const BUYER_ORDER_DETAIL: BuyerOrderDetail = {
  ...BUYER_ORDERS[0]!,
  parcels: [
    {
      shop: { name: "Rucher d’Ambohimanga", slug: "rucher-ambohimanga", initials: "RA", color: "#D86F12" },
      statusLabel: "En route · 10h–11h",
      statusTone: "info",
      items: [item("oi-1", "Miel de litchi cru", 18000, "pot 500 g", 2, "2 × 18 000 Ar · pot 500 g", v("#FDE6CC", "#B4500A", "sprout"))],
    },
    {
      shop: { name: "Ferme Tsara", slug: "ferme-tsara", initials: "FT", color: "#4A7A12" },
      statusLabel: "Jeudi 8h–12h",
      statusTone: "warning",
      items: [
        item("oi-2", "Tomates cœur de bœuf", 4500, "kg", 1, "1 kg", v("#F6E3D6", "#B4500A", "leaf")),
        item("oi-3", "Brèdes mafana", 1000, "botte", 2, "2 bottes", v("#DDEBC9", "#365A10", "leaf")),
      ],
    },
  ],
  timeline: [
    { label: "Confirmée", detail: "26 sept., 18h02", done: true },
    { label: "Préparée", detail: "27 sept., 16h10", done: true },
    { label: "En route", detail: "Aujourd’hui, 9h32", done: true, current: true },
    { label: "Livrée", detail: "Prévue 10h–11h", done: false },
    { label: "Paiement versé", detail: "Après réception", done: false },
  ],
  tracking: { label: "Livraison 1 / 2 · Rucher d’Ambohimanga", slot: "10h – 11h", courier: "Naina · moto · à 3,2 km" },
  subtotal: 42500,
  deliveryFee: 6000,
  discount: 4250,
  paymentDetail: "Mobile Money · MVola •• 12",
  address: {
    title: "Domicile · Hery Rakoto",
    lines: ["[ADRESSE], Analakely", "Antananarivo 101", "Repère : portail vert en face de l’épicerie"],
  },
  cancellationNote:
    "Annulation impossible : la livraison 1 est en route. La livraison 2 peut encore être modifiée jusqu’à mercredi 18h.",
};

export const FAVORITE_PRODUCTS = pick(
  "miel-de-litchi-cru",
  "avocats-hass",
  "litchis-frais",
  "vanille-bourbon-gousses",
  "confiture-de-goyave-de-chine",
  "savon-au-ravintsara",
  "riz-rouge-bio",
  "cafe-arabica-torrefie",
).map((p) => ({ ...p, isFavorite: true }));

export const FOLLOWED_SHOPS = [SHOPS[1]!, SHOPS[0]!, SHOPS[3]!];

/* ------------------------------------------------------------------ */
/* Messages                                                            */
/* ------------------------------------------------------------------ */

export const CONVERSATIONS: Conversation[] = [
  { id: "conv-1", context: "PURCHASE", counterpart: { name: "Rucher d’Ambohimanga", initials: "RA", color: "#D86F12" }, topic: "Commande IMB-24817", lastMessage: "Le livreur part à 9h30, bonne journée !", lastMessageAt: "9:28", unread: true, order: { number: "IMB-24817", label: "36 000 Ar · En route" }, shopSlug: "rucher-ambohimanga" },
  { id: "conv-2", context: "PURCHASE", counterpart: { name: "Naina (livreur)", initials: "NR", color: "#7A5A2E" }, topic: "Livraison en cours", lastMessage: "Je suis devant le portail bleu ?", lastMessageAt: "9:41", unread: true, order: { number: "IMB-24817", label: "Livraison 1 / 2" } },
  { id: "conv-3", context: "PURCHASE", counterpart: { name: "Atelier Hazo", initials: "AH", color: "#2F6DA8" }, topic: "Savon au ravintsara", lastMessage: "Oui, nous faisons aussi une version sans parfum.", lastMessageAt: "Hier", unread: false, shopSlug: "atelier-hazo" },
  { id: "conv-4", context: "PURCHASE", counterpart: { name: "Ferme Tsara", initials: "FT", color: "#4A7A12" }, topic: "Tomates cœur de bœuf", lastMessage: "Vous : Merci, à jeudi !", lastMessageAt: "Lun.", unread: false, shopSlug: "ferme-tsara" },
  { id: "conv-5", context: "SALE", counterpart: { name: "Mialy R.", initials: "MR", color: "#2F6DA8" }, topic: "Commande IMB-24821", lastMessage: "Est-ce possible de livrer avant 10h ?", lastMessageAt: "9:15", unread: true, order: { number: "IMB-24821", label: "12 000 Ar · Nouvelle" } },
  { id: "conv-6", context: "SALE", counterpart: { name: "Toky A.", initials: "TA", color: "#7A5A2E" }, topic: "Panier de saison", lastMessage: "Vous : Il reste 2 paniers, je vous en garde un.", lastMessageAt: "Hier", unread: false },
  { id: "conv-7", context: "SALE", counterpart: { name: "Équipe In my bush", initials: "IB", color: "#1F2318" }, topic: "Vérification", lastMessage: "Votre boutique est en cours de vérification.", lastMessageAt: "26 sept.", unread: false },
];

const m = (id: string, body: string, time: string, mine: boolean): Message => ({ id, conversationId: "conv-1", body, time, mine });

export const MESSAGES: Record<string, Message[]> = {
  "conv-1": [
    m("m1", "Bonjour ! Le miel sera-t-il bien livré ce matin ? Je pars à 11h30.", "9:02", true),
    m("m2", "Bonjour Hery, oui : il est emballé et part avec Naina vers 9h30.", "9:20", false),
    m("m3", "Vous devriez l’avoir entre 10h et 11h. Gardez le pot à l’abri de la chaleur.", "9:21", false),
    m("m4", "Parfait, merci beaucoup !", "9:24", true),
    m("m5", "Le livreur part à 9h30, bonne journée !", "9:28", false),
  ],
  "conv-5": [
    { id: "s1", conversationId: "conv-5", body: "Bonjour, j’ai commandé des brèdes et des tomates.", time: "9:13", mine: false },
    { id: "s2", conversationId: "conv-5", body: "Est-ce possible de livrer avant 10h ?", time: "9:15", mine: false },
  ],
};

/* ------------------------------------------------------------------ */
/* Notifications                                                       */
/* ------------------------------------------------------------------ */

export const NOTIFICATIONS: AppNotification[] = [
  { id: "n1", context: "PURCHASE", kind: "order", title: "Votre commande est en route", body: "IMB-24817 · Naina arrive entre 10h et 11h.", link: "/compte/commandes/ord-24817", readAt: null, timeLabel: "9:32", group: "Aujourd’hui" },
  { id: "n2", context: "SALE", kind: "sale", title: "Nouvelle commande reçue", body: "Mialy R. · Brèdes ×3, Tomates 2 kg · à confirmer avant 14h.", link: "/vendre/commandes/sord-24821", readAt: null, timeLabel: "9:12", group: "Aujourd’hui", cta: "Confirmer" },
  { id: "n3", context: "PURCHASE", kind: "msg", title: "Rucher d’Ambohimanga vous a écrit", body: "« Le livreur part à 9h30, bonne journée ! »", link: "/compte/messages", readAt: null, timeLabel: "9:28", group: "Aujourd’hui" },
  { id: "n4", context: "SALE", kind: "stock", title: "Stock faible", body: "Carottes nouvelles : plus que 3 kg.", link: "/vendre/produits", readAt: "2026-09-28T08:05:00+03:00", timeLabel: "8:00", group: "Aujourd’hui", cta: "Réassortir" },
  { id: "n5", context: "PURCHASE", kind: "review", title: "Donnez votre avis", body: "Savon au ravintsara · Atelier Hazo", link: "/compte/avis", readAt: null, timeLabel: "Lun.", group: "Cette semaine", cta: "Laisser un avis" },
  { id: "n6", context: "SYSTEM", kind: "promo", title: "Un favori est en promotion", body: "Avocats Hass : −20 % jusqu’à dimanche.", link: "/produits/avocats-hass", readAt: "2026-09-27T10:00:00+03:00", timeLabel: "Dim.", group: "Cette semaine" },
  { id: "n7", context: "SALE", kind: "sale", title: "Paiement versé", body: "Commande IMB-24761 · versé sur MVola •• 12.", link: "/vendre/historique", readAt: "2026-09-27T10:00:00+03:00", timeLabel: "Sam.", group: "Cette semaine" },
];

/* ------------------------------------------------------------------ */
/* Reviews (buyer)                                                     */
/* ------------------------------------------------------------------ */

export const REVIEWS_TO_LEAVE = [
  { id: "todo-1", productName: "Savon au ravintsara", shopName: "Atelier Hazo", deliveredLabel: "livré le 3 sept.", visual: v("#DCE8D2", "#365A10", "sprout") },
  { id: "todo-2", productName: "Bougie à la cire d’abeille", shopName: "Rucher d’Ambohimanga", deliveredLabel: "livré le 3 sept.", visual: v("#F4F0E6", "#5B4526", "store") },
];

export const REVIEW_TAGS = ["Frais", "Parfum agréable", "Bien emballé", "Livré à l’heure", "Conforme à la photo", "Bon rapport qualité-prix"];

export const PUBLISHED_REVIEWS = [
  { id: "pr-1", product: "Tomates cœur de bœuf", shop: "Ferme Tsara", date: "août 2026", rating: 5, text: "Vraiment savoureuses, rien à voir avec celles du marché.", reply: "Merci Hery ! Nouvelle récolte la semaine prochaine." },
  { id: "pr-2", product: "Riz rouge bio", shop: "Coop. Lac Alaotra", date: "juil. 2026", rating: 4, text: "Très bon riz, sac un peu abîmé à l’arrivée.", reply: null },
  { id: "pr-3", product: "Café arabica torréfié", shop: "Café des Hautes Terres", date: "juin 2026", rating: 5, text: "Torréfaction parfaite, arômes de chocolat.", reply: null },
  { id: "pr-4", product: "Miel de litchi cru", shop: "Rucher d’Ambohimanga", date: "mai 2026", rating: 5, text: "Mon miel préféré, je recommande le retrait au rucher.", reply: "Au plaisir de vous revoir au rucher !" },
];

/* ------------------------------------------------------------------ */
/* Payments                                                            */
/* ------------------------------------------------------------------ */

export const PAYMENT_METHODS = [
  { id: "pm-1", title: "MVola", detail: "+261 34 •• ••• 12", icon: "wallet" as const, bg: "#FFF4E8", ink: "#B4500A", isDefault: true },
  { id: "pm-2", title: "Orange Money", detail: "+261 32 •• ••• 48", icon: "wallet" as const, bg: "#FFF1E0", ink: "#D86F12", isDefault: false },
  { id: "pm-3", title: "Paiement à la réception", detail: "Proposé quand le vendeur l’accepte", icon: "package" as const, bg: "#F4F0E6", ink: "#4A4A42", isDefault: false },
];

export const PAYOUTS = [
  { id: "po-1", label: "Jeu. 25 sept.", orderCount: 9, amount: null },
  { id: "po-2", label: "Jeu. 18 sept.", orderCount: 12, amount: null },
  { id: "po-3", label: "Jeu. 11 sept.", orderCount: 8, amount: null },
  { id: "po-4", label: "Jeu. 4 sept.", orderCount: 10, amount: null },
];
