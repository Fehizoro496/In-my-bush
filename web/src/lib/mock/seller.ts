/** Seller-side mock data — shop "Le Jardin de Hery" (W-Sell-Dashboard, W-Stock, W-Orders-Received…). */
import type {
  Review,
  SaleRow,
  SellerDashboard,
  SellerOrderCard,
  SellerOrderDetail,
  SellerProductRow,
  Visual,
} from "@/lib/types";

const v = (tint: string, ink: string, icon: Visual["icon"] = "leaf"): Visual => ({ tint, ink, icon });

const DAILY = [22, 35, 28, 40, 31, 55, 62, 30, 26, 38, 44, 36, 58, 70, 33, 29, 41, 47, 39, 60, 74, 35, 32, 45, 50, 43, 66, 78, 48, 52];

export const SELLER_ORDERS: SellerOrderCard[] = [
  { id: "sord-24821", number: "IMB-24821", client: { name: "Mialy R.", initials: "MR", color: "#2F6DA8" }, total: 12000, itemsLabel: "Brèdes ×3 · Tomates 2 kg", whenLabel: "Avant 14h · domicile demain", whenIcon: "clock", status: "PENDING_CONFIRMATION", urgent: true, createdLabel: "Aujourd’hui 9h12", receptionLabel: "Domicile · demain" },
  { id: "sord-24819", number: "IMB-24819", client: { name: "Toky A.", initials: "TA", color: "#7A5A2E" }, total: 25000, itemsLabel: "Panier de saison ×1", whenLabel: "Retrait samedi 8h–12h", whenIcon: "store", status: "ACCEPTED", createdLabel: "Hier 18h40", receptionLabel: "Retrait · sam." },
  { id: "sord-24810", number: "IMB-24810", client: { name: "Fara N.", initials: "FN", color: "#D86F12" }, total: 6000, itemsLabel: "Carottes nouvelles 3 kg", whenLabel: "Domicile demain 8h–12h", whenIcon: "truck", status: "ACCEPTED", createdLabel: "Hier 11h05", receptionLabel: "Domicile · demain" },
  { id: "sord-24788", number: "IMB-24788", client: { name: "Andry M.", initials: "AM", color: "#365A10" }, total: 14400, itemsLabel: "Tomates cerises ×2 · Salade ×3", whenLabel: "Naina · arrivée 11h", whenIcon: "truck", status: "IN_DELIVERY", createdLabel: "24 sept.", receptionLabel: "Domicile" },
  { id: "sord-24761", number: "IMB-24761", client: { name: "Lova R.", initials: "LR", color: "#9A2F45" }, total: 9000, itemsLabel: "Carottes 2 kg · Brèdes ×5", whenLabel: "Retirée le 22 sept.", whenIcon: "checkCircle", status: "DELIVERED", createdLabel: "22 sept.", receptionLabel: "Retrait" },
  { id: "sord-24744", number: "IMB-24744", client: { name: "Nomena S.", initials: "NS", color: "#1F2318" }, total: 25000, itemsLabel: "Panier de saison", whenLabel: "Livrée le 21 sept.", whenIcon: "checkCircle", status: "DELIVERED", createdLabel: "21 sept.", receptionLabel: "Domicile" },
];

export const SELLER_REVIEWS: Review[] = [
  { id: "sr-1", productId: "prod-016", productName: "Panier de saison", orderId: "sord-24744", author: { name: "Toky A.", initials: "TA", color: "#7A5A2E" }, rating: 5, comment: "Panier très frais, brèdes impeccables. Merci !", sellerReply: null, repliedAt: null, createdAt: "2026-09-26T10:00:00+03:00", dateLabel: "il y a 2 j" },
  { id: "sr-2", productId: "prod-018", productName: "Carottes nouvelles", orderId: "sord-24761", author: { name: "Lova R.", initials: "LR", color: "#9A2F45" }, rating: 4, comment: "Bonnes carottes, un peu terreuses mais c’est normal pour du bio.", sellerReply: null, repliedAt: null, createdAt: "2026-09-24T10:00:00+03:00", dateLabel: "il y a 4 j" },
  { id: "sr-3", productId: "prod-009", productName: "Fraises de Behenjy", orderId: "sord-24702", author: { name: "Rivo H.", initials: "RH", color: "#2F6DA8" }, rating: 3, comment: "Bon goût mais quelques fraises abîmées à la livraison.", sellerReply: "Désolé Rivo, nous avons changé nos barquettes. Un geste sur votre prochaine commande !", repliedAt: "2026-09-22T10:00:00+03:00", createdAt: "2026-09-21T10:00:00+03:00", dateLabel: "il y a 1 sem." },
  { id: "sr-4", productId: "prod-001", productName: "Tomates cœur de bœuf", orderId: "sord-24671", author: { name: "Mialy R.", initials: "MR", color: "#4A7A12" }, rating: 5, comment: "Les meilleures tomates de Tana, sans hésiter.", sellerReply: "Merci Mialy, à bientôt !", repliedAt: "2026-09-15T10:00:00+03:00", createdAt: "2026-09-14T10:00:00+03:00", dateLabel: "il y a 2 sem." },
];

export const SELLER_DASHBOARD: SellerDashboard = {
  shopName: "Le Jardin de Hery",
  kpis: {
    salesTotal: 1240000,
    salesTrend: 12,
    ordersReceived: 38,
    ordersToPrepare: 3,
    activeProducts: 12,
    drafts: 2,
    lowStock: 3,
    ratingAvg: 4.8,
    ratingCount: 57,
    positiveShare: 96,
  },
  dailySales: DAILY.map((k, i) => {
    const d = new Date(Date.UTC(2026, 7, 30 + i));
    return { date: d.toISOString(), label: "", amount: k * 1000 };
  }),
  lowStockProducts: [
    { id: "sp-b", name: "Carottes nouvelles", left: "Plus que 3 kg", visual: v("#FCE3CF", "#B4500A") },
    { id: "sp-d", name: "Panier de saison", left: "Plus que 2 paniers", visual: v("#E6F3CC", "#365A10") },
    { id: "sp-e", name: "Fraises de Behenjy", left: "Rupture · masqué", visual: v("#F8DADF", "#9A2F45") },
  ],
  recentOrders: SELLER_ORDERS.slice(0, 5),
  recentReviews: SELLER_REVIEWS.slice(0, 2),
};

export const SELLER_PRODUCTS: SellerProductRow[] = [
  { id: "sp-a", name: "Brèdes mafana", category: "Herbes & brèdes", price: 1000, unitLabel: "botte", stock: 42, lowStockThreshold: 5, sales30d: "64 bottes", status: "PUBLISHED", visible: true, visual: v("#DDEBC9", "#365A10") },
  { id: "sp-b", name: "Carottes nouvelles", category: "Légumes", price: 2000, unitLabel: "kg", stock: 3, lowStockThreshold: 5, sales30d: "31 kg", status: "PUBLISHED", visible: true, visual: v("#FCE3CF", "#B4500A") },
  { id: "sp-c", name: "Tomates cerises", category: "Légumes", price: 6000, unitLabel: "barquette", stock: 18, lowStockThreshold: 5, sales30d: "22 barq.", status: "PUBLISHED", visible: true, visual: v("#F6E3D6", "#B4500A") },
  { id: "sp-d", name: "Panier de saison", category: "Paniers composés", price: 25000, unitLabel: "panier", stock: 2, lowStockThreshold: 3, sales30d: "14 paniers", status: "PUBLISHED", visible: true, visual: v("#E6F3CC", "#365A10") },
  { id: "sp-e", name: "Fraises de Behenjy", category: "Fruits", price: 8000, unitLabel: "barquette", stock: 0, lowStockThreshold: 3, sales30d: "9 barq.", status: "PUBLISHED", visible: false, visual: v("#F8DADF", "#9A2F45") },
  { id: "sp-f", name: "Gingembre frais", category: "Légumes", price: 3000, unitLabel: "kg", stock: 12, lowStockThreshold: 4, sales30d: "—", status: "PENDING_REVIEW", visible: false, visual: v("#EFE3D3", "#7A5A2E") },
  { id: "sp-g", name: "Salade batavia", category: "Légumes", price: 800, unitLabel: "pièce", stock: 26, lowStockThreshold: 6, sales30d: "48 pièces", status: "PUBLISHED", visible: true, visual: v("#DDEBC9", "#365A10") },
];

export const EDIT_PRODUCT = {
  id: "sp-a",
  name: "Brèdes mafana",
  since: "En ligne depuis le 2 juin",
  visual: v("#DDEBC9", "#365A10"),
  price: "1 000",
  unit: "BUNCH",
  stock: "42",
  threshold: "5",
  description:
    "Brèdes fraîches cueillies le matin même, cultivées sans intrant chimique à Antsirabe. Idéales pour le romazava.",
  photos: ["#DDEBC9", "#E6F3CC", "#F0F6E6"],
  stats: [
    { value: "1 240", label: "vues" },
    { value: "64", label: "ventes" },
    { value: "38", label: "favoris" },
    { value: "4,8 ★", label: "19 avis" },
  ],
  pendingOrders: 2,
  origin: "Antsirabe, Vakinankaratra",
};

export const SELLER_ORDER_DETAIL: SellerOrderDetail = {
  id: "sord-24821",
  number: "IMB-24821",
  status: "PENDING_CONFIRMATION",
  receivedLabel: "Reçue aujourd’hui à 9h12 · Mialy R. · 2 articles",
  acceptBefore: "14h",
  client: {
    name: "Mialy R.",
    initials: "MR",
    color: "#2F6DA8",
    since: "Cliente depuis 2025 · 6 commandes",
    lastMessage: "« Est-ce possible de livrer avant 10h ? »",
    lastMessageAt: "il y a 12 min",
  },
  items: [
    { id: "soi-1", productId: "sp-a", productName: "Brèdes mafana", unitPrice: 1000, unitLabel: "botte", quantity: 3, quantityLabel: "3 bottes", lineTotal: 3000, visual: v("#DDEBC9", "#365A10") },
    { id: "soi-2", productId: "prod-001", productName: "Tomates cœur de bœuf", unitPrice: 4500, unitLabel: "kg", quantity: 2, quantityLabel: "2 kg", lineTotal: 9000, visual: v("#F6E3D6", "#B4500A") },
  ],
  delivery: {
    mode: "HOME",
    slot: "Demain · 8h–12h",
    address: "[ADRESSE], Ambohijatovo, Antananarivo",
    landmark: "Repère : portail bleu, en face de l’école",
  },
  payment: { label: "Payée · Mobile Money", notes: ["Montant conservé par In my bush", "Versé après la livraison, jeudi suivant"] },
  revenue: { items: 12000, delivery: 3000, commission: 0, net: 0 },
};

export const MONTHLY_SALES = [
  { month: "oct.", amount: 310000 },
  { month: "nov.", amount: 380000 },
  { month: "déc.", amount: 450000 },
  { month: "janv.", amount: 420000 },
  { month: "févr.", amount: 510000 },
  { month: "mars", amount: 580000 },
  { month: "avr.", amount: 620000 },
  { month: "mai", amount: 780000 },
  { month: "juin", amount: 840000 },
  { month: "juil.", amount: 1020000 },
  { month: "août", amount: 1100000 },
  { month: "sept.", amount: 1240000 },
];

export const SALES: SaleRow[] = [
  { id: "s1", date: "26 sept.", orderNumber: "IMB-24788", client: "Andry M.", items: "Tomates cerises ×2 · Salade ×3", amount: 14400, payout: "PENDING" },
  { id: "s2", date: "22 sept.", orderNumber: "IMB-24761", client: "Lova R.", items: "Carottes 2 kg · Brèdes ×5", amount: 9000, payout: "PAID" },
  { id: "s3", date: "21 sept.", orderNumber: "IMB-24744", client: "Nomena S.", items: "Panier de saison", amount: 25000, payout: "PAID" },
  { id: "s4", date: "18 sept.", orderNumber: "IMB-24702", client: "Rivo H.", items: "Fraises ×2", amount: 16000, payout: "PAID" },
  { id: "s5", date: "17 sept.", orderNumber: "IMB-24688", client: "Tahina R.", items: "Brèdes ×4", amount: 4000, payout: "REFUNDED" },
  { id: "s6", date: "15 sept.", orderNumber: "IMB-24671", client: "Mialy R.", items: "Tomates 3 kg", amount: 13500, payout: "PAID" },
  { id: "s7", date: "14 sept.", orderNumber: "IMB-24659", client: "Toky A.", items: "Panier de saison ×2", amount: 50000, payout: "PAID" },
];

export const REVIEW_BREAKDOWN = [
  { stars: 5, count: 47 },
  { stars: 4, count: 7 },
  { stars: 3, count: 2 },
  { stars: 2, count: 1 },
  { stars: 1, count: 0 },
];

export const REVIEWS_BY_PRODUCT = [
  { name: "Panier de saison", rating: 4.9, count: 14, tint: "#E6F3CC" },
  { name: "Brèdes mafana", rating: 4.8, count: 19, tint: "#DDEBC9" },
  { name: "Carottes nouvelles", rating: 4.5, count: 12, tint: "#FCE3CF" },
  { name: "Fraises de Behenjy", rating: 4.2, count: 8, tint: "#F8DADF" },
];
