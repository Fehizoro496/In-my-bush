/** Screen-level mock builders (home, catalogue, product, shop, search). */
import type { CatalogFilters, CatalogResult, ProductDetail, SearchResult, ShopDetail } from "@/lib/types";
import { CATEGORIES, PRODUCTS, PRODUCT_REVIEWS, SHOPS, pick, productBySlug, shopBySlug } from "./catalog";

export const HOME = {
  trust: [
    { icon: "shield" as const, title: "Producteurs vérifiés", detail: "Identité et exploitation contrôlées" },
    { icon: "pin" as const, title: "Origine affichée", detail: "Lieu de production sur chaque fiche" },
    { icon: "wallet" as const, title: "Paiement protégé", detail: "Le vendeur est payé à la réception" },
  ],
  rails: {
    reco: pick("tomates-coeur-de-boeuf", "miel-de-litchi-cru", "riz-rouge-bio", "vanille-bourbon-gousses", "yaourt-fermier-nature"),
    news: pick("bredes-mafana", "poivre-sauvage-voatsiperifery", "savon-au-ravintsara", "fraises-de-behenjy", "pollen-frais"),
    popular: pick("jus-de-goyave-presse", "litchis-frais", "tomates-coeur-de-boeuf", "cafe-arabica-torrefie", "miel-de-litchi-cru"),
  },
  /** Tablet "Recommandé pour vous" (3 columns × 2). */
  tabletReco: pick("tomates-coeur-de-boeuf", "miel-de-litchi-cru", "riz-rouge-bio", "avocats-hass", "vanille-bourbon-gousses", "savon-au-ravintsara"),
  promos: pick("avocats-hass", "confiture-de-goyave-de-chine", "cafe-arabica-torrefie", "panier-de-saison", "huile-de-coco-vierge"),
  promoEndsIn: "Se termine dans 2 j 14 h",
  mapPins: [
    { x: 90, y: 110, name: "Ferme Tsara", initials: "FT", color: "#4A7A12" },
    { x: 480, y: 90, name: "Rucher d’Ambohimanga", initials: "RA", color: "#D86F12" },
    { x: 560, y: 300, name: "Atelier Hazo", initials: "AH", color: "#2F6DA8" },
    { x: 180, y: 250, name: "Le Jardin de Hery", initials: "JH", color: "#4A7A12" },
    { x: 330, y: 370, name: "Verger Mahitsy", initials: "VM", color: "#365A10" },
  ],
  nearby: ["atelier-hazo", "rucher-ambohimanga", "verger-mahitsy", "vergers-d-imerina"].map(shopBySlug),
  popularShops: ["ferme-tsara", "rucher-ambohimanga", "cooperative-lac-alaotra", "atelier-hazo"].map(shopBySlug),
  sellSteps: ["Nommez votre boutique", "Vérifiez votre identité", "Publiez votre premier produit"],
};

const SORT_LABELS: Record<NonNullable<CatalogFilters["tri"]>, string> = {
  pertinence: "Pertinence",
  "prix-asc": "Prix croissant",
  "prix-desc": "Prix décroissant",
  note: "Mieux notés",
  nouveautes: "Nouveautés",
};
export { SORT_LABELS };

export function buildCatalog(filters: CatalogFilters): CatalogResult {
  const category = CATEGORIES.find((c) => c.slug === (filters.categorie ?? "fruits-legumes")) ?? CATEGORIES[0]!;
  let items = PRODUCTS.filter((p) => p.categorySlug === category.slug);
  if (filters.q) {
    const q = filters.q.toLowerCase();
    items = PRODUCTS.filter((p) => p.name.toLowerCase().includes(q) || p.shop.name.toLowerCase().includes(q));
  }
  // Keep the order of the W-Catalog mockup for "fruits & légumes".
  if (category.slug === "fruits-legumes" && !filters.q) {
    items = pick(
      "tomates-coeur-de-boeuf",
      "avocats-hass",
      "bredes-mafana",
      "carottes-nouvelles",
      "litchis-frais",
      "patates-douces-violettes",
      "fraises-de-behenjy",
      "panier-de-saison",
      "oranges-de-mahitsy",
      "salade-batavia",
      "gingembre-frais",
      "haricots-verts",
    ).map((p) => (p.slug === "bredes-mafana" ? { ...p, isFavorite: true } : p));
  }
  switch (filters.tri) {
    case "prix-asc":
      items = [...items].sort((a, b) => a.price - b.price);
      break;
    case "prix-desc":
      items = [...items].sort((a, b) => b.price - a.price);
      break;
    case "note":
      items = [...items].sort((a, b) => b.ratingAvg - a.ratingAvg);
      break;
  }
  const total = category.slug === "fruits-legumes" ? 248 : items.length;
  return {
    title: category.name,
    category,
    products: { items, page: 0, size: 12, totalItems: total, totalPages: Math.max(1, Math.ceil(total / 12)) },
    producerCount: category.slug === "fruits-legumes" ? 36 : new Set(items.map((i) => i.shop.id)).size,
    subcategories: [
      { label: "Tout", slug: "", count: category.productCount ?? items.length, active: true },
      ...(category.slug === "fruits-legumes"
        ? [
            { label: "Légumes", slug: "legumes", count: 112 },
            { label: "Fruits", slug: "fruits", count: 74 },
            { label: "Herbes & brèdes", slug: "herbes-bredes", count: 28 },
            { label: "Tubercules", slug: "tubercules", count: 21 },
            { label: "Paniers composés", slug: "paniers-composes", count: 13 },
          ]
        : (category.children ?? []).map((c, i) => ({ label: c.name, slug: c.slug, count: Math.max(3, 24 - i * 5) }))),
    ],
    activeFilters: ["Moins de 15 km", "4,5 ★ et plus"],
  };
}

export function buildSearch(q: string): SearchResult {
  const query = q || "miel";
  const items =
    query.toLowerCase() === "miel"
      ? pick(
          "miel-de-litchi-cru",
          "miel-d-eucalyptus",
          "miel-de-niaouli",
          "coffret-decouverte-3-miels",
          "miel-de-litchi-250-g",
          "miel-toutes-fleurs",
          "pain-d-epices-au-miel",
          "pollen-frais",
          "baume-levres-miel-ravintsara",
          "miel-de-baies-roses",
        ).map((p) => ({ ...p, isFavorite: false }))
      : PRODUCTS.filter((p) => `${p.name} ${p.shop.name} ${p.shop.city}`.toLowerCase().includes(query.toLowerCase()));
  return {
    query,
    products: { items, page: 0, size: 10, totalItems: query === "miel" ? 18 : items.length, totalPages: 2 },
    shops:
      query.toLowerCase() === "miel"
        ? [
            { name: "Rucher d’Ambohimanga", slug: "rucher-ambohimanga", meta: "4,9 ★ · 9 produits · 22 km", initials: "RA", color: "#D86F12" },
            { name: "Api Sud", slug: "api-sud", meta: "4,6 ★ · 5 produits · Fianarantsoa", initials: "AS", color: "#8A5A12" },
          ]
        : SHOPS.filter((s) => s.name.toLowerCase().includes(query.toLowerCase()))
            .slice(0, 2)
            .map((s) => ({ name: s.name, slug: s.slug, meta: `${s.ratingAvg.toString().replace(".", ",")} ★ · ${s.productCount} produits · ${s.city}`, initials: s.name.slice(0, 2).toUpperCase(), color: s.avatarColor })),
    suggestions: [
      { icon: "search", hit: query, rest: " de litchi", meta: "6 produits" },
      { icon: "search", hit: query, rest: " cru", meta: "9 produits" },
      { icon: "layers", hit: "Miel", rest: " & confitures", meta: "Catégorie" },
      { icon: "store", hit: "Miel", rest: " · Rucher d’Ambohimanga", meta: "Producteur" },
      { icon: "pin", hit: query, rest: " près de chez vous", meta: "< 15 km" },
    ],
    recent: ["vanille", "riz rouge", "brèdes"],
    refinements: ["Miel cru", "Pot 250 g", "Pot 500 g", "Moins de 15 km", "En promotion"],
  };
}

export function buildProductDetail(slug: string): ProductDetail | null {
  const p = productBySlug(slug);
  if (!p) return null;
  const shop = shopBySlug(p.shop.slug);
  const category = CATEGORIES.find((c) => c.slug === p.categorySlug)!;
  const isMiel = slug === "miel-de-litchi-cru";
  const tints = isMiel ? ["#FDE6CC", "#FCEBD2", "#F6E3D6", "#F4F0E6", "#E6F3CC"] : [p.visual.tint, "#F4F0E6", "#F0F6E6", "#FBFAF6", "#E6F3CC"];
  const icons = ["sprout", "package", "leaf", "store", "pin"] as const;
  return {
    ...p,
    isFavorite: false,
    description: isMiel
      ? "Miel cru, non chauffé et non filtré, issu de ruches installées au cœur des vergers de litchis. Texture crémeuse, notes florales et fruitées. Il cristallise naturellement avec le temps : c’est un gage de qualité."
      : `${p.name} de ${shop.name}, produit à ${p.shop.city}. Récolté à maturité et préparé la veille de la livraison.`,
    originRegion: `${shop.city}, ${shop.region}`,
    distanceKm: shop.distanceKm ?? 22,
    images: tints.map((t, i) => ({ id: `img-${i}`, url: null, visual: { tint: t, ink: p.visual.ink, icon: i === 0 ? p.visual.icon : icons[i]! } })),
    specs: isMiel
      ? [
          { label: "Poids net", value: "500 g" },
          { label: "Conservation", value: "Au sec, 2 ans" },
          { label: "Contenant", value: "Pot en verre" },
          { label: "Allergènes", value: "Aucun connu" },
        ]
      : [
          { label: "Unité", value: p.unitLabel },
          { label: "Conservation", value: "Au frais" },
          { label: "Origine", value: p.shop.city },
          { label: "Allergènes", value: "Aucun connu" },
        ],
    traceability: isMiel
      ? [
          { label: "Récolte", value: "[MOIS ANNÉE]" },
          { label: "Floraison", value: "Litchi" },
          { label: "Traitement", value: "Cru, non chauffé, non filtré" },
        ]
      : [
          { label: "Récolte", value: "[MOIS ANNÉE]" },
          { label: "Culture", value: "Sans intrant chimique" },
          { label: "Producteur", value: shop.name },
        ],
    soldCount: isMiel ? 320 : 84,
    pricePerKgLabel: isMiel ? "36 000 Ar/kg" : undefined,
    delivery: [
      { icon: "truck", title: "Livraison demain", detail: "à Analakely, 8h–12h", price: "3 000 Ar" },
      { icon: "store", title: isMiel ? "Retrait au rucher" : "Retrait sur place", detail: "mercredi et samedi", price: "Gratuit", free: true },
      { icon: "shield", title: "", detail: "Paiement protégé : le vendeur est payé à la réception", price: "" },
    ],
    category: { name: category.name, slug: category.slug },
    shopDetail: { ...shop, tags: isMiel ? ["Producteur local", "Retrait sur place"] : shop.tags },
    ratingBreakdown: [
      { stars: 5, count: 77 },
      { stars: 4, count: 8 },
      { stars: 3, count: 2 },
      { stars: 2, count: 1 },
      { stars: 1, count: 0 },
    ],
  };
}

export function productReviews() {
  return PRODUCT_REVIEWS;
}

export function similarProducts(slug: string) {
  const p = productBySlug(slug);
  if (slug === "miel-de-litchi-cru" || !p) {
    return pick("miel-d-eucalyptus", "confiture-de-goyave-de-chine", "miel-de-niaouli", "pollen-frais", "confiture-de-mangue");
  }
  return PRODUCTS.filter((x) => x.categorySlug === p.categorySlug && x.slug !== slug).slice(0, 5);
}

export function buildShop(slug: string): (ShopDetail & { products: ReturnType<typeof pick> }) | null {
  const s = SHOPS.find((x) => x.slug === slug);
  if (!s) return null;
  const isRucher = slug === "rucher-ambohimanga";
  const products = isRucher
    ? pick(
        "miel-de-litchi-cru",
        "miel-d-eucalyptus",
        "pollen-frais",
        "bougie-a-la-cire-d-abeille",
        "coffret-decouverte-3-miels",
        "miel-de-niaouli",
      ).map((p) => (p.slug === "miel-de-niaouli" ? { ...p, stockLevel: "OUT" as const, isFavorite: false } : { ...p, isFavorite: false }))
    : PRODUCTS.filter((p) => p.shop.slug === slug);
  return {
    ...s,
    description: isRucher
      ? "Apiculteurs depuis trois générations. Nos ruches suivent les floraisons des Hautes Terres : litchi, eucalyptus, niaouli. Miels crus, jamais chauffés."
      : `${s.name} produit à ${s.city} (${s.region}). Produits de saison, cultivés sans intrant chimique et récoltés la veille de la livraison.`,
    status: "ACTIVE",
    responseTime: "Répond en ~1 h",
    deliveryInfo: ["Livre Antananarivo et 30 km autour, sous 24 h"],
    pickupInfo: isRucher ? "Retrait au rucher : mer. et sam., 8h–12h" : "Retrait sur place : mer. et sam., 8h–12h",
    badges: [
      { icon: "shield", title: "Identité & exploitation vérifiées", detail: "Contrôle In my bush effectué", bg: "#E8F1FA", ink: "#22527E" },
      { icon: "star", title: "Top producteur", detail: "Note ≥ 4,8 sur 100+ avis", bg: "#FFF4E8", ink: "#D86F12" },
    ],
    distanceKm: s.distanceKm ?? 22,
    products,
  };
}
