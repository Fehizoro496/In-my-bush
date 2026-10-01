/**
 * Catalogue mock data, taken from the mockups (W-Home, W-Catalog, W-Product,
 * W-Seller, W-Search, W-Categories). Prices are integer Ariary.
 */
import type { IconName } from "@/components/ui/Icon";
import type { Category, ProductSummary, Review, ShopSummary, StockLevel } from "@/lib/types";

/* ------------------------------------------------------------------ */
/* Shops                                                               */
/* ------------------------------------------------------------------ */

type ShopSeed = [
  slug: string,
  name: string,
  city: string,
  region: string,
  rating: number,
  reviews: number,
  products: number,
  since: string,
  cover: [string, string],
  avatar: string,
  tags: string[],
  extra?: Partial<ShopSummary>,
];

const SHOP_SEEDS: ShopSeed[] = [
  ["ferme-tsara", "Ferme Tsara", "Antsirabe", "Vakinankaratra", 4.9, 312, 28, "2021", ["#E6F3CC", "#365A10"], "#4A7A12", ["Producteur local", "Maraîchage"]],
  ["rucher-ambohimanga", "Rucher d’Ambohimanga", "Ambohimanga", "Analamanga", 4.9, 146, 9, "2022", ["#FDE6CC", "#8A3D06"], "#D86F12", ["Apiculture", "Local"], { distanceKm: 22, specialty: "Miels crus, pollen" }],
  ["cooperative-lac-alaotra", "Coopérative Lac Alaotra", "Ambatondrazaka", "Alaotra-Mangoro", 4.7, 98, 14, "2020", ["#EFE3D3", "#5B4526"], "#7A5A2E", ["Producteur local", "Céréales"]],
  ["atelier-hazo", "Atelier Hazo", "Antananarivo", "Analamanga", 4.8, 57, 22, "2023", ["#DCE8D2", "#365A10"], "#2F6DA8", ["Cosmétiques", "Fait main"], { distanceKm: 2, specialty: "Savons, baumes · Antananarivo" }],
  ["sava-vanille", "Sava Vanille", "Sambava", "Sava", 5.0, 63, 6, "2022", ["#E9E0D0", "#5B4526"], "#5B4526", ["Épices", "Vanille"]],
  ["laiterie-des-hautes-terres", "Laiterie des Hautes Terres", "Antsirabe", "Vakinankaratra", 4.6, 52, 11, "2021", ["#EEF0EA", "#4A5A3A"], "#4A5A3A", ["Laitiers", "Élevage"]],
  ["le-jardin-de-hery", "Le Jardin de Hery", "Antsirabe", "Vakinankaratra", 4.8, 57, 12, "2024", ["#E6F3CC", "#365A10"], "#4A7A12", ["Maraîchage", "Retrait mer. & sam."]],
  ["cueilleurs-de-ranomafana", "Cueilleurs de Ranomafana", "Ranomafana", "Vatovavy", 4.9, 37, 5, "2023", ["#E8DDD5", "#5B3A2E"], "#5B3A2E", ["Cueillette sauvage"]],
  ["verger-mahitsy", "Verger Mahitsy", "Mahitsy", "Analamanga", 4.6, 41, 8, "2022", ["#DCEBC6", "#365A10"], "#365A10", ["Arboriculture"], { distanceKm: 28, specialty: "Avocats, agrumes" }],
  ["vergers-d-imerina", "Vergers d’Imerina", "Ambohidratrimo", "Analamanga", 4.7, 33, 10, "2022", ["#FBDCD3", "#A43C24"], "#A43C24", ["Transformation"], { distanceKm: 14, specialty: "Confitures, jus" }],
  ["cooperative-ivoloina", "Coopérative Ivoloina", "Toamasina", "Atsinanana", 4.7, 205, 7, "2021", ["#F8DADF", "#9A2F45"], "#9A2F45", ["Fruits tropicaux"]],
  ["cafe-des-hautes-terres", "Café des Hautes Terres", "Manjakandriana", "Analamanga", 4.8, 74, 6, "2021", ["#E6DACB", "#5B3A1E"], "#5B3A1E", ["Café", "Torréfaction"]],
  ["vergers-de-manjakandriana", "Vergers de Manjakandriana", "Manjakandriana", "Analamanga", 4.5, 29, 5, "2023", ["#FBDCD3", "#A43C24"], "#A43C24", ["Jus"]],
  ["coco-nosy-be", "Coco Nosy Be", "Nosy Be", "Diana", 4.7, 18, 4, "2024", ["#F1EEE6", "#5B4526"], "#5B4526", ["Huiles"]],
  ["jardins-de-behenjy", "Jardins de Behenjy", "Behenjy", "Vakinankaratra", 4.5, 22, 15, "2022", ["#FCE3CF", "#B4500A"], "#B4500A", ["Maraîchage"]],
  ["ferme-soa", "Ferme Soa", "Ambatolampy", "Vakinankaratra", 4.6, 15, 9, "2023", ["#E7DDEB", "#5B3A6E"], "#5B3A6E", ["Tubercules"]],
  ["api-sud", "Api Sud", "Fianarantsoa", "Haute Matsiatra", 4.6, 47, 5, "2022", ["#F4E3C3", "#8A5A12"], "#8A5A12", ["Apiculture"]],
];

export const SHOPS: ShopSummary[] = SHOP_SEEDS.map(
  ([slug, name, city, region, rating, reviews, products, since, cover, avatar, tags, extra], i) => ({
    id: `shop-${String(i + 1).padStart(3, "0")}`,
    slug,
    name,
    city,
    region,
    logoUrl: null,
    coverUrl: null,
    ratingAvg: rating,
    ratingCount: reviews,
    productCount: products,
    createdAt: `${since}-03-01T08:00:00+03:00`,
    verified: true,
    tags,
    avatarColor: avatar,
    cover: { tint: cover[0], ink: cover[1] },
    ...extra,
  }),
);

export function shopBySlug(slug: string): ShopSummary {
  const s = SHOPS.find((x) => x.slug === slug);
  if (!s) throw new Error(`Unknown shop ${slug}`);
  return s;
}

/* ------------------------------------------------------------------ */
/* Categories                                                          */
/* ------------------------------------------------------------------ */

type CatSeed = [slug: string, name: string, icon: IconName, count: number, tile: [string, string], visual: [string, string, string?], subs: string[]];

const CAT_SEEDS: CatSeed[] = [
  ["fruits-legumes", "Fruits & légumes", "leaf", 248, ["#8CC63F", "#1F3608"], ["#8CC63F", "#1F3608"], ["Légumes", "Fruits", "Herbes & brèdes", "Tubercules", "Paniers composés"]],
  ["produits-laitiers", "Produits laitiers", "package", 64, ["#F0F6E6", "#4A7A12"], ["#EEF0EA", "#4A5A3A"], ["Yaourts", "Fromages", "Lait frais", "Beurre"]],
  ["epicerie", "Épicerie", "basket", 182, ["#F4F0E6", "#5B4526"], ["#F4F0E6", "#5B4526"], ["Épices", "Vanille", "Huiles", "Farines"]],
  ["boissons", "Boissons", "package", 58, ["#F0F6E6", "#365A10"], ["#F0F6E6", "#365A10"], ["Jus", "Thés", "Café", "Infusions"]],
  ["miel-confitures", "Miel & confitures", "sprout", 71, ["#FFF4E8", "#B4500A"], ["#FDE6CC", "#B4500A"], ["Miels crus", "Confitures", "Pollen", "Sirops"]],
  ["cereales", "Céréales", "basket", 43, ["#F4F0E6", "#7A5A2E"], ["#EFE3D3", "#7A5A2E"], ["Riz rouge", "Riz blanc", "Maïs", "Légumineuses"]],
  ["artisanat", "Artisanat", "store", 96, ["#FFF4E8", "#8A3D06"], ["#FFF4E8", "#8A3D06"], ["Bougies", "Vannerie", "Coffrets", "Textile"]],
  ["cosmetiques-bio", "Cosmétiques bio", "sprout", 87, ["#F0F6E6", "#365A10"], ["#DCE8D2", "#365A10"], ["Savons", "Baumes", "Huiles essentielles", "Soins"]],
  ["produits-locaux", "Produits locaux", "pin", 312, ["#F4F0E6", "#4A7A12"], ["#1F3608", "#8CC63F", "#F4FAE8"], ["Moins de 15 km", "Analamanga", "Retrait à la ferme"]],
];

const slugify = (s: string) =>
  s
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/&/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");

export const CATEGORIES: Category[] = CAT_SEEDS.map(([slug, name, icon, count, tile, visual, subs], i) => ({
  id: `cat-${i + 1}`,
  parentId: null,
  name,
  slug,
  icon,
  position: i,
  productCount: count,
  tile: { bg: tile[0], ink: tile[1] },
  visual: { bg: visual[0], ink: visual[1], fg: visual[2] },
  children: subs.map((sub, j) => ({
    id: `cat-${i + 1}-${j + 1}`,
    parentId: `cat-${i + 1}`,
    name: sub,
    slug: slugify(sub),
    icon,
    position: j,
  })),
}));

export const REGIONS = [
  { name: "Analamanga", count: 412 },
  { name: "Vakinankaratra", count: 286 },
  { name: "Alaotra-Mangoro", count: 94 },
  { name: "Sava", count: 71 },
  { name: "Atsinanana", count: 88 },
  { name: "Haute Matsiatra", count: 63 },
  { name: "Diana", count: 52 },
  { name: "Itasy", count: 47 },
];

/* ------------------------------------------------------------------ */
/* Products                                                            */
/* ------------------------------------------------------------------ */

type ProductSeed = {
  slug: string;
  name: string;
  label: string;
  price: number;
  compareAt?: number;
  unit: string;
  shop: string;
  city: string;
  rating: number;
  reviews: number;
  tint: string;
  ink: string;
  icon?: IconName;
  cat: string;
  stock?: StockLevel;
  stockLabel?: string;
  fav?: boolean;
};

const PRODUCT_SEEDS: ProductSeed[] = [
  { slug: "tomates-coeur-de-boeuf", name: "Tomates cœur de bœuf", label: "Tomates", price: 4500, unit: "kg", shop: "ferme-tsara", city: "Antsirabe", rating: 4.8, reviews: 126, tint: "#F6E3D6", ink: "#B4500A", cat: "fruits-legumes" },
  { slug: "miel-de-litchi-cru", name: "Miel de litchi cru", label: "Miel", price: 18000, unit: "pot 500 g", shop: "rucher-ambohimanga", city: "Analamanga", rating: 4.9, reviews: 88, tint: "#FDE6CC", ink: "#B4500A", icon: "sprout", cat: "miel-confitures", fav: true },
  { slug: "riz-rouge-bio", name: "Riz rouge bio", label: "Riz", price: 6000, unit: "kg", shop: "cooperative-lac-alaotra", city: "Ambatondrazaka", rating: 4.7, reviews: 64, tint: "#EFE3D3", ink: "#7A5A2E", icon: "basket", cat: "cereales" },
  { slug: "vanille-bourbon-gousses", name: "Vanille Bourbon, gousses", label: "Vanille", price: 12000, unit: "lot de 5", shop: "sava-vanille", city: "Sambava", rating: 5.0, reviews: 63, tint: "#E9E0D0", ink: "#5B4526", cat: "epicerie", stock: "LOW", stockLabel: "Plus que 3" },
  { slug: "yaourt-fermier-nature", name: "Yaourt fermier nature", label: "Yaourt", price: 2500, unit: "pot 400 g", shop: "laiterie-des-hautes-terres", city: "Antsirabe", rating: 4.6, reviews: 52, tint: "#EEF0EA", ink: "#4A5A3A", icon: "package", cat: "produits-laitiers" },
  { slug: "bredes-mafana", name: "Brèdes mafana", label: "Brèdes", price: 1000, unit: "botte", shop: "le-jardin-de-hery", city: "Antsirabe", rating: 4.7, reviews: 19, tint: "#DDEBC9", ink: "#365A10", cat: "fruits-legumes" },
  { slug: "poivre-sauvage-voatsiperifery", name: "Poivre sauvage voatsiperifery", label: "Poivre", price: 15000, unit: "100 g", shop: "cueilleurs-de-ranomafana", city: "Ranomafana", rating: 4.9, reviews: 37, tint: "#E8DDD5", ink: "#5B3A2E", icon: "sprout", cat: "epicerie" },
  { slug: "savon-au-ravintsara", name: "Savon au ravintsara", label: "Savon", price: 7000, unit: "pièce", shop: "atelier-hazo", city: "Antananarivo", rating: 4.8, reviews: 57, tint: "#DCE8D2", ink: "#365A10", icon: "sprout", cat: "cosmetiques-bio" },
  { slug: "fraises-de-behenjy", name: "Fraises de Behenjy", label: "Fraises", price: 8000, unit: "barquette", shop: "le-jardin-de-hery", city: "Behenjy", rating: 4.5, reviews: 8, tint: "#F8DADF", ink: "#9A2F45", cat: "fruits-legumes" },
  { slug: "pollen-frais", name: "Pollen frais", label: "Pollen", price: 9000, unit: "200 g", shop: "rucher-ambohimanga", city: "Analamanga", rating: 4.7, reviews: 12, tint: "#F7E7B8", ink: "#8A5A12", icon: "sprout", cat: "miel-confitures", stock: "LOW", stockLabel: "Plus que 2" },
  { slug: "jus-de-goyave-presse", name: "Jus de goyave pressé", label: "Jus", price: 5000, unit: "litre", shop: "vergers-de-manjakandriana", city: "Manjakandriana", rating: 4.5, reviews: 29, tint: "#FBDCD3", ink: "#A43C24", icon: "package", cat: "boissons" },
  { slug: "litchis-frais", name: "Litchis frais", label: "Litchis", price: 5000, unit: "kg", shop: "cooperative-ivoloina", city: "Toamasina", rating: 4.7, reviews: 205, tint: "#F8DADF", ink: "#9A2F45", cat: "fruits-legumes", stock: "OUT" },
  { slug: "cafe-arabica-torrefie", name: "Café arabica torréfié", label: "Café", price: 8100, compareAt: 9000, unit: "250 g", shop: "cafe-des-hautes-terres", city: "Manjakandriana", rating: 4.8, reviews: 74, tint: "#E6DACB", ink: "#5B3A1E", icon: "package", cat: "boissons" },
  { slug: "avocats-hass", name: "Avocats Hass", label: "Avocats", price: 2400, compareAt: 3000, unit: "kg", shop: "verger-mahitsy", city: "Mahitsy", rating: 4.6, reviews: 41, tint: "#DCEBC6", ink: "#365A10", cat: "fruits-legumes" },
  { slug: "confiture-de-goyave-de-chine", name: "Confiture de goyave de Chine", label: "Confiture", price: 7000, compareAt: 10000, unit: "pot 350 g", shop: "vergers-d-imerina", city: "Ambohidratrimo", rating: 4.7, reviews: 33, tint: "#FBDCD3", ink: "#A43C24", icon: "sprout", cat: "miel-confitures" },
  { slug: "panier-de-saison", name: "Panier de saison", label: "Panier", price: 20000, compareAt: 25000, unit: "panier 5 kg", shop: "le-jardin-de-hery", city: "Antsirabe", rating: 4.9, reviews: 22, tint: "#E6F3CC", ink: "#365A10", icon: "basket", cat: "fruits-legumes" },
  { slug: "huile-de-coco-vierge", name: "Huile de coco vierge", label: "Huile", price: 10800, compareAt: 12000, unit: "50 cl", shop: "coco-nosy-be", city: "Nosy Be", rating: 4.7, reviews: 18, tint: "#F1EEE6", ink: "#5B4526", icon: "package", cat: "epicerie" },
  { slug: "carottes-nouvelles", name: "Carottes nouvelles", label: "Carottes", price: 2000, unit: "kg", shop: "jardins-de-behenjy", city: "Behenjy", rating: 4.5, reviews: 22, tint: "#FCE3CF", ink: "#B4500A", cat: "fruits-legumes" },
  { slug: "patates-douces-violettes", name: "Patates douces violettes", label: "Patates douces", price: 1800, unit: "kg", shop: "ferme-soa", city: "Ambatolampy", rating: 4.6, reviews: 15, tint: "#E7DDEB", ink: "#5B3A6E", cat: "fruits-legumes", stock: "LOW", stockLabel: "Plus que 4 kg" },
  { slug: "oranges-de-mahitsy", name: "Oranges de Mahitsy", label: "Oranges", price: 2500, unit: "kg", shop: "verger-mahitsy", city: "Mahitsy", rating: 4.4, reviews: 31, tint: "#FDE6CC", ink: "#B4500A", cat: "fruits-legumes" },
  { slug: "salade-batavia", name: "Salade batavia", label: "Salade", price: 800, unit: "pièce", shop: "ferme-tsara", city: "Antsirabe", rating: 4.7, reviews: 44, tint: "#DDEBC9", ink: "#365A10", cat: "fruits-legumes" },
  { slug: "gingembre-frais", name: "Gingembre frais", label: "Gingembre", price: 3000, unit: "kg", shop: "ferme-soa", city: "Ambatolampy", rating: 4.8, reviews: 27, tint: "#EFE3D3", ink: "#7A5A2E", cat: "fruits-legumes" },
  { slug: "haricots-verts", name: "Haricots verts", label: "Haricots", price: 3500, unit: "kg", shop: "jardins-de-behenjy", city: "Behenjy", rating: 4.6, reviews: 18, tint: "#DCEBC6", ink: "#365A10", cat: "fruits-legumes" },
  { slug: "miel-d-eucalyptus", name: "Miel d’eucalyptus", label: "Miel", price: 15000, unit: "pot 500 g", shop: "rucher-ambohimanga", city: "Analamanga", rating: 4.8, reviews: 51, tint: "#FCEBD2", ink: "#B4500A", icon: "sprout", cat: "miel-confitures" },
  { slug: "miel-de-niaouli", name: "Miel de niaouli", label: "Miel", price: 16000, unit: "pot 500 g", shop: "api-sud", city: "Fianarantsoa", rating: 4.6, reviews: 24, tint: "#F4E3C3", ink: "#8A5A12", icon: "sprout", cat: "miel-confitures" },
  { slug: "confiture-de-mangue", name: "Confiture de mangue", label: "Confiture", price: 8000, unit: "pot 350 g", shop: "vergers-d-imerina", city: "Ambohidratrimo", rating: 4.5, reviews: 14, tint: "#FDE6CC", ink: "#B4500A", icon: "sprout", cat: "miel-confitures" },
  { slug: "coffret-decouverte-3-miels", name: "Coffret découverte 3 miels", label: "Coffret", price: 40500, compareAt: 45000, unit: "coffret", shop: "rucher-ambohimanga", city: "Analamanga", rating: 5.0, reviews: 9, tint: "#FDE6CC", ink: "#8A3D06", icon: "package", cat: "miel-confitures" },
  { slug: "miel-de-litchi-250-g", name: "Miel de litchi 250 g", label: "Miel", price: 10000, unit: "pot 250 g", shop: "rucher-ambohimanga", city: "Analamanga", rating: 4.9, reviews: 31, tint: "#FDE6CC", ink: "#B4500A", icon: "sprout", cat: "miel-confitures" },
  { slug: "miel-toutes-fleurs", name: "Miel toutes fleurs", label: "Miel", price: 12000, unit: "pot 500 g", shop: "api-sud", city: "Fianarantsoa", rating: 4.5, reviews: 17, tint: "#F7E7B8", ink: "#8A5A12", icon: "sprout", cat: "miel-confitures" },
  { slug: "pain-d-epices-au-miel", name: "Pain d’épices au miel", label: "Pain d’épices", price: 8000, unit: "pièce", shop: "atelier-hazo", city: "Antananarivo", rating: 4.7, reviews: 12, tint: "#EFE3D3", ink: "#7A5A2E", icon: "store", cat: "epicerie" },
  { slug: "baume-levres-miel-ravintsara", name: "Baume lèvres miel & ravintsara", label: "Baume", price: 5000, unit: "pièce", shop: "atelier-hazo", city: "Antananarivo", rating: 4.8, reviews: 22, tint: "#DCE8D2", ink: "#365A10", icon: "sprout", cat: "cosmetiques-bio" },
  { slug: "miel-de-baies-roses", name: "Miel de baies roses", label: "Miel", price: 20000, unit: "pot 500 g", shop: "api-sud", city: "Fianarantsoa", rating: 4.8, reviews: 6, tint: "#F8DADF", ink: "#9A2F45", icon: "sprout", cat: "miel-confitures", stock: "OUT" },
  { slug: "bougie-a-la-cire-d-abeille", name: "Bougie à la cire d’abeille", label: "Bougie", price: 6000, unit: "pièce", shop: "rucher-ambohimanga", city: "Analamanga", rating: 4.9, reviews: 20, tint: "#F4F0E6", ink: "#5B4526", icon: "store", cat: "artisanat" },
];

const unitEnum = (u: string): ProductSummary["unit"] =>
  u === "kg" ? "KG" : u.startsWith("pot") ? "JAR" : u === "litre" || u.endsWith("cl") ? "L" : u === "botte" ? "BUNCH" : u.endsWith(" g") ? "G" : u === "pièce" ? "PIECE" : "PACK";

export const PRODUCTS: ProductSummary[] = PRODUCT_SEEDS.map((p, i) => {
  const shop = shopBySlug(p.shop);
  const stockLevel = p.stock ?? "OK";
  return {
    id: `prod-${String(i + 1).padStart(3, "0")}`,
    slug: p.slug,
    name: p.name,
    price: p.price,
    compareAtPrice: p.compareAt ?? null,
    unit: unitEnum(p.unit),
    unitLabel: p.unit,
    stock: stockLevel === "OUT" ? 0 : stockLevel === "LOW" ? 3 : 24,
    stockLevel,
    stockLabel: p.stockLabel,
    ratingAvg: p.rating,
    ratingCount: p.reviews,
    imageUrl: null,
    visual: { tint: p.tint, ink: p.ink, icon: p.icon ?? "leaf", label: p.label },
    shop: { id: shop.id, name: shop.name, slug: shop.slug, city: p.city },
    categorySlug: p.cat,
    isFavorite: p.fav ?? false,
  };
});

export function productBySlug(slug: string): ProductSummary | undefined {
  return PRODUCTS.find((p) => p.slug === slug);
}

export function pick(...slugs: string[]): ProductSummary[] {
  return slugs.map((s) => {
    const p = productBySlug(s);
    if (!p) throw new Error(`Unknown product ${s}`);
    return p;
  });
}

/* ------------------------------------------------------------------ */
/* Reviews                                                             */
/* ------------------------------------------------------------------ */

export const PRODUCT_REVIEWS: Review[] = [
  { id: "rev-1", productId: "prod-002", productName: "Miel de litchi cru", orderId: "ord-1", author: { name: "Mialy R.", initials: "MR", color: "#4A7A12" }, rating: 5, comment: "Très parfumé, on sent vraiment le litchi. Pot bien emballé, livré le lendemain matin comme prévu.", sellerReply: null, repliedAt: null, createdAt: "2026-09-25T10:00:00+03:00", dateLabel: "il y a 3 jours" },
  { id: "rev-2", productId: "prod-002", productName: "Miel de litchi cru", orderId: "ord-2", author: { name: "Toky A.", initials: "TA", color: "#2F6DA8" }, rating: 5, comment: "Je le prends chaque mois. Le retrait au rucher est une belle occasion de rencontrer l’apiculteur.", sellerReply: null, repliedAt: null, createdAt: "2026-09-14T10:00:00+03:00", dateLabel: "il y a 2 semaines" },
  { id: "rev-3", productId: "prod-002", productName: "Miel de litchi cru", orderId: "ord-3", author: { name: "Fara N.", initials: "FN", color: "#D86F12" }, rating: 5, comment: "Cristallisé à la réception, ce qui est normal pour un miel cru. Goût excellent.", sellerReply: null, repliedAt: null, createdAt: "2026-08-28T10:00:00+03:00", dateLabel: "il y a 1 mois" },
];

export const SHOP_REVIEWS = [
  { text: "Accueil chaleureux au rucher, miel exceptionnel. Commande prête à l’heure.", author: "Fara N.", product: "Miel de litchi" },
  { text: "Le coffret est parfait à offrir, très bien présenté.", author: "Tahina R.", product: "Coffret découverte" },
];
