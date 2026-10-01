/** Backoffice mock data (A-Dashboard, A-Products, A-Users, A-Orders, A-Reports). */
import type { AdminDashboard, AdminOrderRow, AdminProductRow, AdminReport, AdminUserRow } from "@/lib/types";

const CUR = [92, 101, 110, 104, 121, 128, 135, 142, 150, 168, 176, 182];
const PREV = [60, 64, 70, 72, 78, 82, 88, 90, 95, 101, 108, 115];
const MONTHS = ["oct.", "nov.", "déc.", "janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept."];

export const ADMIN_DASHBOARD: AdminDashboard = {
  asOf: "Données au 28 sept. 2026, 9h00 · comparées à la période précédente",
  kpis: [
    { label: "Utilisateurs", value: "12 480", delta: "▲ +4,2 % · 1 253 nouveaux", tone: "up", icon: "users", href: "/admin/utilisateurs" },
    { label: "Vendeurs actifs", value: "386", delta: "▲ +11 · 41 inscrits ce mois", tone: "up", icon: "store", href: "/admin/utilisateurs" },
    { label: "Produits publiés", value: "5 214", delta: "▲ +3,1 %", tone: "up", icon: "package", href: "/admin/produits" },
    { label: "Commandes (30 j)", value: "3 942", delta: "▲ +8,6 %", tone: "up", icon: "receipt", href: "/admin/commandes" },
    { label: "Chiffre d’affaires", value: "182,4 M Ar", delta: "▲ +12,4 % · commission [TAUX]", tone: "up", icon: "wallet", href: "/admin/commandes" },
    { label: "Volume de ventes", value: "11 860 art.", delta: "▼ −1,8 % panier moyen", tone: "down", icon: "basket", href: "/admin/commandes" },
    { label: "En attente de validation", value: "24", delta: "Plus ancien : il y a 19 h", tone: "warning", icon: "clock", href: "/admin/produits", highlight: true },
    { label: "Signalements ouverts", value: "7", delta: "2 prioritaires", tone: "danger", icon: "flag", href: "/admin/signalements", highlight: true },
  ],
  gmv: MONTHS.map((month, i) => ({ month, current: CUR[i]!, previous: PREV[i]! })),
  topCategories: [
    { name: "Fruits & légumes", share: 34 },
    { name: "Miel & confitures", share: 17 },
    { name: "Épicerie", share: 14 },
    { name: "Produits laitiers", share: 11 },
    { name: "Cosmétiques bio", share: 9 },
    { name: "Céréales", share: 7 },
  ],
  signups: [
    [240, 6],
    [260, 4],
    [230, 8],
    [300, 5],
    [280, 7],
    [330, 9],
    [310, 6],
    [360, 10],
  ].map(([buyers, sellers]) => ({ buyers: buyers!, sellers: sellers! })),
  signupTotals: { buyers: 1212, sellers: 41 },
  ordersByStatus: [
    { label: "Livrées", count: 3071, share: 78, color: "#4A7A12" },
    { label: "En cours", count: 552, share: 14, color: "#2F6DA8" },
    { label: "En attente", count: 197, share: 5, color: "#F28C28" },
    { label: "Annulées", count: 122, share: 3, color: "#A3A094" },
  ],
  ordersTotal: 3942,
  queue: [
    { icon: "package", title: "Produits à valider", detail: "Plus ancien il y a 19 h", count: 24, href: "/admin/produits", tone: "warning" },
    { icon: "flag", title: "Signalements", detail: "2 prioritaires", count: 7, href: "/admin/signalements", tone: "danger" },
    { icon: "store", title: "Demandes vendeur", detail: "Identité à contrôler", count: 9, href: "/admin/utilisateurs", tone: "info" },
  ],
};

const prod = (
  id: string,
  name: string,
  photoCount: number,
  origin: string,
  seller: string,
  sellerNote: string,
  newSeller: boolean,
  category: string,
  priceLabel: string,
  check: AdminProductRow["check"],
  submittedLabel: string,
  tint: string,
): AdminProductRow => ({ id, name, photoCount, origin, seller, sellerNote, newSeller, category, priceLabel, check, submittedLabel, tint, status: "PENDING_REVIEW" });

export const ADMIN_PENDING_PRODUCTS: AdminProductRow[] = [
  prod("ap-1", "Gingembre frais", 3, "Ambatolampy", "Le Jardin de Hery", "Vérifié · 4,8 ★", false, "Légumes", "3 000 Ar / kg", "COMPLETE", "il y a 19 h", "#EFE3D3"),
  prod("ap-2", "Huile de coco vierge", 4, "Nosy Be", "Coco Nosy Be", "Vérifié · 4,7 ★", false, "Épicerie", "12 000 Ar / 50 cl", "TO_CHECK", "il y a 16 h", "#F1EEE6"),
  prod("ap-3", "Fraises « bio » de Behenjy", 1, "Behenjy", "Jardins Ralay", "Nouveau vendeur", true, "Fruits", "6 000 Ar / barq.", "MISSING_INFO", "il y a 11 h", "#F8DADF"),
  prod("ap-4", "Baume au ravintsara", 5, "Antananarivo", "Atelier Hazo", "Vérifié · 4,8 ★", false, "Cosmétiques bio", "9 000 Ar / pot", "COMPLETE", "il y a 9 h", "#DCE8D2"),
  prod("ap-5", "Riz rouge 5 kg", 2, "Ambatondrazaka", "Coop. Lac Alaotra", "Vérifié · 4,7 ★", false, "Céréales", "28 000 Ar / sac", "COMPLETE", "il y a 6 h", "#EFE3D3"),
  prod("ap-6", "Fromage de chèvre frais", 3, "Antsirabe", "Chèvrerie Soa", "Nouveau vendeur", true, "Produits laitiers", "7 500 Ar / pièce", "PHOTOS", "il y a 4 h", "#EEF0EA"),
  prod("ap-7", "Thé vert d’Andrambovato", 4, "Fianarantsoa", "Thé du Sud", "Vérifié · 4,6 ★", false, "Boissons", "6 500 Ar / 100 g", "TO_CHECK", "il y a 2 h", "#DDEBC9"),
  prod("ap-8", "Panier de légumes 3 kg", 6, "Behenjy", "Jardins de Behenjy", "Vérifié · 4,5 ★", false, "Paniers composés", "15 000 Ar / panier", "COMPLETE", "il y a 40 min", "#E6F3CC"),
];

export const ADMIN_PRODUCT_TABS = [
  { value: "PENDING_REVIEW", label: "En attente", count: "24", warning: true },
  { value: "PUBLISHED", label: "Publiés", count: "5 214" },
  { value: "REJECTED", label: "Refusés", count: "312" },
  { value: "REPORTED", label: "Signalés", count: "6" },
  { value: "ARCHIVED", label: "Archivés", count: "1 040" },
] as const;

export const REJECTION_REASONS = [
  "Photos insuffisantes ou non conformes",
  "Description trompeuse ou incomplète",
  "Informations d’origine incomplètes",
  "Autre (préciser)",
];

const user = (
  id: string,
  initials: string,
  color: string,
  name: string,
  emailMasked: string,
  isSeller: boolean,
  since: string,
  orders: number,
  status: AdminUserRow["status"],
  sales30d: string,
): AdminUserRow => ({ id, initials, color, name, emailMasked, isSeller, since, orders, status, sales30d });

export const ADMIN_USERS: AdminUserRow[] = [
  user("u1", "HR", "#365A10", "Hery Rakoto", "h•••@gmail.com", true, "mars 2024", 14, "VERIFYING", "1,24 M Ar"),
  user("u2", "MR", "#2F6DA8", "Mialy Randria", "m•••@yahoo.fr", false, "janv. 2025", 22, "ACTIVE", "—"),
  user("u3", "FT", "#4A7A12", "Ferme Tsara", "c•••@fermetsara.mg", true, "févr. 2021", 3, "ACTIVE", "4,8 M Ar"),
  user("u4", "JR", "#B4500A", "Jardins Ralay", "j•••@gmail.com", true, "sept. 2026", 0, "VERIFYING", "—"),
  user("u5", "TA", "#7A5A2E", "Toky Andria", "t•••@gmail.com", false, "mai 2024", 9, "ACTIVE", "—"),
  user("u6", "AH", "#2F6DA8", "Atelier Hazo", "b•••@hazo.mg", true, "avr. 2023", 5, "ACTIVE", "2,1 M Ar"),
  user("u7", "VR", "#66655B", "Vente Rapide 22", "v•••@mail.com", true, "août 2026", 1, "SUSPENDED", "—"),
  user("u8", "LR", "#D86F12", "Lova Rasoa", "l•••@gmail.com", false, "juil. 2025", 17, "ACTIVE", "—"),
  user("u9", "CS", "#4A7A12", "Chèvrerie Soa", "s•••@gmail.com", true, "sept. 2026", 2, "VERIFYING", "—"),
];

export const ADMIN_USER_TABS = [
  { value: "all", label: "Tous", count: "12 480" },
  { value: "buyers", label: "Acheteurs", count: "12 094" },
  { value: "sellers", label: "Vendeurs", count: "386" },
  { value: "requests", label: "Demandes vendeur", count: "9" },
  { value: "suspended", label: "Suspendus", count: "14" },
];

const order = (
  id: string,
  dateLabel: string,
  client: string,
  sellers: string,
  total: number,
  paymentMethod: string,
  paymentStatus: AdminOrderRow["paymentStatus"],
  status: AdminOrderRow["status"],
): AdminOrderRow => ({ id: `ao-${id}`, number: `IMB-${id}`, dateLabel, client, sellers, total, paymentMethod, paymentStatus, status });

export const ADMIN_ORDERS: AdminOrderRow[] = [
  order("24821", "28 sept. 9h12", "Mialy R.", "Le Jardin de Hery", 15000, "Mobile Money", "HELD", "PENDING"),
  order("24817", "26 sept. 18h02", "Hery R.", "Rucher d’Ambohimanga +1", 44250, "Mobile Money", "HELD", "IN_DELIVERY"),
  order("24812", "26 sept. 14h40", "Andry M.", "Café des Hautes Terres", 27000, "À la réception", "COD", "PREPARING"),
  order("24808", "26 sept. 10h15", "Lova R.", "Atelier Hazo", 21000, "Orange Money", "HELD", "DISPUTE"),
  order("24790", "25 sept. 19h30", "Toky A.", "Coop. Lac Alaotra", 34000, "Mobile Money", "RELEASED", "DELIVERED"),
  order("24781", "25 sept. 11h02", "Fara N.", "Ferme Tsara", 9500, "Mobile Money", "RELEASED", "DELIVERED"),
  order("24776", "24 sept. 16h45", "Tahina R.", "Rucher d’Ambohimanga", 45000, "Airtel Money", "RELEASED", "DELIVERED"),
  order("24770", "24 sept. 09h20", "Nomena S.", "Verger Mahitsy", 7200, "Mobile Money", "REFUNDED", "CANCELLED"),
  order("24765", "23 sept. 17h55", "Rivo H.", "Vergers d’Imerina +2", 38600, "À la réception", "RELEASED", "DELIVERED"),
];

export const ADMIN_ORDER_STATS = [
  { label: "Commandes (période)", value: "3 942", delta: "▲ +8,6 %", tone: "up" as const },
  { label: "En séquestre", value: "14,2 M Ar", delta: "Versé après réception", tone: "neutral" as const },
  { label: "Litiges ouverts", value: "4", delta: "Délai moyen : 1,6 j", tone: "danger" as const },
  { label: "Taux d’annulation", value: "3,1 %", delta: "▼ −0,4 pt", tone: "up" as const },
];

const report = (
  i: number,
  targetType: AdminReport["targetType"],
  reason: string,
  target: string,
  whenLabel: string,
  count: number,
  priority: boolean,
  meta: string,
  excerpt: string,
  reportedBy: string,
  history: string,
  tint: string,
): AdminReport => ({ id: `rep-${i}`, number: 1040 + i, targetType, reason, target, whenLabel, count, priority, meta, excerpt, reportedBy, history, tint, status: "OPEN" });

export const ADMIN_REPORTS: AdminReport[] = [
  report(0, "PRODUCT", "Description trompeuse", "Fraises « bio » de Behenjy", "il y a 2 h", 3, true, "Jardins Ralay · nouveau vendeur · 6 000 Ar / barquette", "Les photos ne correspondent pas aux fraises livrées.", "Mialy R. + 2", "Aucun antécédent", "#F8DADF"),
  report(1, "SHOP", "Commande non livrée", "Vente Rapide 22", "il y a 5 h", 4, true, "Vendeur inscrit en août 2026 · 1 commande", "Paiement reçu, aucune livraison ni réponse depuis 6 jours.", "Tahina R.", "2 avertissements", "#EFECE3"),
  report(2, "REVIEW", "Propos injurieux", "Avis sur « Miel de litchi cru »", "hier", 1, false, "Avis 1 ★ publié par un compte créé le jour même", "« [CONTENU DE L’AVIS MASQUÉ DANS L’APERÇU] »", "Rucher d’Ambohimanga", "Aucun antécédent", "#FDE6CC"),
  report(3, "PRODUCT", "Photo trompeuse", "Avocats Hass", "hier", 1, false, "Verger Mahitsy · 4,6 ★", "La photo ne correspond pas au calibre livré.", "Lova R.", "Aucun antécédent", "#DCEBC6"),
  report(4, "MESSAGE", "Démarchage hors plateforme", "Conversation #8812", "il y a 2 j", 1, false, "Échange entre un acheteur et un vendeur", "Proposition de paiement en dehors de In my bush.", "Andry M.", "1 avertissement", "#F4F0E6"),
  report(5, "PRODUCT", "Prix abusif", "Vanille Bourbon, gousses", "il y a 3 j", 2, false, "Sava Vanille · 5,0 ★", "Prix jugé trop élevé par deux acheteurs.", "Rivo H. + 1", "Aucun antécédent", "#E9E0D0"),
  report(6, "REVIEW", "Avis hors sujet", "Avis sur « Riz rouge bio »", "il y a 4 j", 1, false, "Avis 3 ★", "L’avis concerne le livreur et non le produit.", "Coop. Lac Alaotra", "Aucun antécédent", "#EFE3D3"),
];
