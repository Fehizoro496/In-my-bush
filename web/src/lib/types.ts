/**
 * Domain types — mirror the data model in docs/architecture.md §3 and the
 * JSON returned by the REST API (§5). Amounts are integer Ariary, ids are
 * UUID strings, dates ISO-8601 strings (TIMESTAMPTZ).
 *
 * "View" types (suffix Summary / Detail / Row / …) are the shapes the API
 * returns for a given screen; mocks in src/lib/mock return exactly these.
 */

import type { IconName } from "@/components/ui/Icon";

export type UUID = string;
export type ISODate = string;
export type Ariary = number;

/* ------------------------------------------------------------------ */
/* Enums                                                               */
/* ------------------------------------------------------------------ */

export type Role = "BUYER" | "SELLER" | "ADMIN";
export type UserStatus = "ACTIVE" | "SUSPENDED" | "BANNED";
export type ShopStatus = "ACTIVE" | "PAUSED" | "SUSPENDED";
export type ProductUnit = "KG" | "G" | "L" | "PIECE" | "BUNCH" | "JAR" | "PACK";
export type ProductStatus = "DRAFT" | "PENDING_REVIEW" | "PUBLISHED" | "REJECTED" | "ARCHIVED";
export type DeliveryMode = "HOME" | "PICKUP";
export type OrderStatus =
  | "PENDING_CONFIRMATION"
  | "ACCEPTED"
  | "PREPARED"
  | "IN_DELIVERY"
  | "DELIVERED"
  | "REFUSED"
  | "CANCELLED";
export type PaymentMethod = "MVOLA" | "ORANGE_MONEY" | "AIRTEL_MONEY" | "CASH_ON_DELIVERY";
export type PaymentStatus = "PENDING" | "HELD" | "RELEASED" | "REFUNDED" | "FAILED";
export type PayoutStatus = "SCHEDULED" | "PAID" | "FAILED";
export type MessageContext = "PURCHASE" | "SALE";
export type NotificationContext = "PURCHASE" | "SALE" | "SYSTEM";
export type ReportTargetType = "PRODUCT" | "SHOP" | "USER" | "REVIEW" | "MESSAGE";
export type ReportStatus = "OPEN" | "IN_REVIEW" | "RESOLVED" | "DISMISSED";

/* ------------------------------------------------------------------ */
/* Generic API shapes                                                  */
/* ------------------------------------------------------------------ */

export interface Page<T> {
  items: T[];
  page: number;
  size: number;
  totalItems: number;
  totalPages: number;
}

/** RFC 7807 problem+json */
export interface ProblemDetails {
  type?: string;
  title: string;
  status: number;
  detail?: string;
  instance?: string;
  errors?: Record<string, string>;
}

/**
 * Placeholder visual used while products/shops have no photo: a tinted
 * block with an icon (as in the mockups). Ignored when an image url exists.
 */
export interface Visual {
  tint: string;
  ink: string;
  icon: IconName;
  /** Short label displayed on the placeholder, e.g. "Tomates". */
  label?: string;
}

/* ------------------------------------------------------------------ */
/* Users & auth                                                        */
/* ------------------------------------------------------------------ */

export interface User {
  id: UUID;
  firstName: string;
  lastName: string;
  email: string | null;
  phone: string;
  avatarUrl: string | null;
  status: UserStatus;
  roles: Role[];
  createdAt: ISODate;
  /** Present when the user owns a shop. */
  shop?: { id: UUID; name: string; slug: string; status: ShopStatus } | null;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface Address {
  id: UUID;
  label: string;
  recipient: string;
  phone: string;
  line1: string;
  district: string;
  city: string;
  landmark: string | null;
  isDefault: boolean;
}

export interface PayoutMethod {
  id: UUID;
  method: PaymentMethod;
  phoneMasked: string;
  isDefault: boolean;
}

/* ------------------------------------------------------------------ */
/* Catalogue                                                           */
/* ------------------------------------------------------------------ */

export interface Category {
  id: UUID;
  parentId: UUID | null;
  name: string;
  slug: string;
  icon: IconName;
  position: number;
  productCount?: number;
  children?: Category[];
  /** Header colors on the categories page. */
  visual?: { bg: string; ink: string; fg?: string };
  /** Icon tile colors (home, category rail). */
  tile?: { bg: string; ink: string };
}

export interface ShopSummary {
  id: UUID;
  name: string;
  slug: string;
  region: string;
  city: string;
  logoUrl: string | null;
  coverUrl: string | null;
  ratingAvg: number;
  ratingCount: number;
  productCount: number;
  createdAt: ISODate;
  verified: boolean;
  tags: string[];
  /** Avatar background (initials) and cover tint while there is no photo. */
  avatarColor: string;
  cover: { tint: string; ink: string };
  distanceKm?: number;
  specialty?: string;
}

export interface ShopDetail extends ShopSummary {
  description: string;
  status: ShopStatus;
  responseTime: string;
  deliveryInfo: string[];
  pickupInfo: string | null;
  badges: { icon: IconName; title: string; detail: string; bg: string; ink: string }[];
}

export type StockLevel = "OK" | "LOW" | "OUT";

export interface ProductSummary {
  id: UUID;
  slug: string;
  name: string;
  price: Ariary;
  compareAtPrice: Ariary | null;
  unit: ProductUnit;
  unitLabel: string;
  stock: number;
  stockLevel: StockLevel;
  stockLabel?: string;
  ratingAvg: number;
  ratingCount: number;
  imageUrl: string | null;
  visual: Visual;
  shop: { id: UUID; name: string; slug: string; city: string };
  categorySlug: string;
  isFavorite?: boolean;
}

export interface ProductDetail extends ProductSummary {
  description: string;
  originRegion: string;
  distanceKm: number | null;
  images: { id: UUID; url: string | null; visual: Visual }[];
  specs: { label: string; value: string }[];
  traceability: { label: string; value: string }[];
  soldCount: number;
  pricePerKgLabel?: string;
  delivery: { icon: IconName; title: string; detail: string; price: string; free?: boolean }[];
  category: { name: string; slug: string };
  shopDetail: ShopSummary;
  ratingBreakdown: { stars: number; count: number }[];
}

export interface Review {
  id: UUID;
  productId: UUID;
  productName: string;
  orderId: UUID;
  author: { name: string; initials: string; color: string };
  rating: number;
  comment: string;
  sellerReply: string | null;
  repliedAt: ISODate | null;
  createdAt: ISODate;
  /** Display date (e.g. "il y a 3 jours") computed server-side in mocks. */
  dateLabel: string;
  shopName?: string;
}

export interface CatalogFilters {
  q?: string;
  categorie?: string;
  tri?: "pertinence" | "prix-asc" | "prix-desc" | "note" | "nouveautes";
  region?: string;
  minPrice?: number;
  maxPrice?: number;
  page?: number;
}

export interface CatalogFacet {
  label: string;
  slug: string;
  count: number;
  active?: boolean;
}

export interface CatalogResult {
  title: string;
  category: Category | null;
  products: Page<ProductSummary>;
  producerCount: number;
  subcategories: CatalogFacet[];
  activeFilters: string[];
}

export interface SearchResult {
  query: string;
  products: Page<ProductSummary>;
  shops: { name: string; slug: string; meta: string; initials: string; color: string }[];
  suggestions: { icon: IconName; hit: string; rest: string; meta: string }[];
  recent: string[];
  refinements: string[];
}

/* ------------------------------------------------------------------ */
/* Cart & checkout                                                     */
/* ------------------------------------------------------------------ */

export interface CartItem {
  id: UUID;
  product: ProductSummary;
  quantity: number;
}

export interface CartGroup {
  shop: ShopSummary;
  deliveryLabel: string;
  deliveryFee: Ariary;
  items: CartItem[];
}

export interface Cart {
  id: UUID;
  groups: CartGroup[];
  unavailable: { name: string; quantityLabel: string }[];
}

export interface CheckoutDraft {
  addresses: Address[];
  groups: {
    shop: ShopSummary;
    itemCount: number;
    homeSlot: string;
    homeFee: Ariary;
    pickupInfo: string;
  }[];
  lines: { name: string; shopName: string; quantity: number; total: Ariary; visual: Visual }[];
  subtotal: Ariary;
  deliveryTotal: Ariary;
  promo: { code: string; label: string; amount: Ariary } | null;
  total: Ariary;
}

/* ------------------------------------------------------------------ */
/* Orders                                                              */
/* ------------------------------------------------------------------ */

export interface OrderItem {
  id: UUID;
  productId: UUID;
  productName: string;
  unitPrice: Ariary;
  unitLabel: string;
  quantity: number;
  quantityLabel: string;
  lineTotal: Ariary;
  visual: Visual;
}

export interface OrderEvent {
  id: UUID;
  status: OrderStatus;
  note: string | null;
  createdAt: ISODate;
}

export interface TimelineStep {
  label: string;
  detail: string;
  done: boolean;
  current?: boolean;
}

/** One buyer-side purchase (a checkout, possibly split across shops). */
export interface BuyerOrderSummary {
  id: UUID;
  number: string;
  createdAt: ISODate;
  total: Ariary;
  paymentLabel: string;
  status: OrderStatus;
  itemCount: number;
  summary: string;
  thumbnails: Visual[];
  progress: number | null;
}

export interface Parcel {
  shop: { name: string; slug: string; initials: string; color: string };
  statusLabel: string;
  statusTone: "info" | "warning" | "success";
  items: OrderItem[];
}

export interface BuyerOrderDetail extends BuyerOrderSummary {
  parcels: Parcel[];
  timeline: TimelineStep[];
  tracking: { label: string; slot: string; courier: string } | null;
  subtotal: Ariary;
  deliveryFee: Ariary;
  discount: Ariary;
  paymentDetail: string;
  address: { title: string; lines: string[] };
  cancellationNote: string;
}

export interface SellerOrderCard {
  id: UUID;
  number: string;
  client: { name: string; initials: string; color: string };
  total: Ariary;
  itemsLabel: string;
  whenLabel: string;
  whenIcon: IconName;
  status: OrderStatus;
  urgent?: boolean;
  createdLabel: string;
  receptionLabel: string;
}

export interface SellerOrderDetail {
  id: UUID;
  number: string;
  status: OrderStatus;
  receivedLabel: string;
  acceptBefore: string;
  client: { name: string; initials: string; color: string; since: string; lastMessage: string; lastMessageAt: string };
  items: OrderItem[];
  delivery: { mode: DeliveryMode; slot: string; address: string; landmark: string };
  payment: { label: string; notes: string[] };
  revenue: { items: Ariary; delivery: Ariary; commission: Ariary; net: Ariary };
}

export interface Checkout {
  id: UUID;
  orders: { number: string; shopName: string }[];
  total: Ariary;
}

/* ------------------------------------------------------------------ */
/* Seller                                                              */
/* ------------------------------------------------------------------ */

export interface SellerDashboard {
  shopName: string;
  kpis: {
    salesTotal: Ariary;
    salesTrend: number;
    ordersReceived: number;
    ordersToPrepare: number;
    activeProducts: number;
    drafts: number;
    lowStock: number;
    ratingAvg: number;
    ratingCount: number;
    positiveShare: number;
  };
  dailySales: { date: ISODate; label: string; amount: Ariary }[];
  lowStockProducts: { id: UUID; name: string; left: string; visual: Visual }[];
  recentOrders: SellerOrderCard[];
  recentReviews: Review[];
}

export interface SellerProductRow {
  id: UUID;
  name: string;
  category: string;
  price: Ariary;
  unitLabel: string;
  stock: number;
  lowStockThreshold: number;
  sales30d: string;
  status: ProductStatus;
  visible: boolean;
  visual: Visual;
}

export interface SaleRow {
  id: UUID;
  date: string;
  orderNumber: string;
  client: string;
  items: string;
  amount: Ariary;
  payout: "PAID" | "PENDING" | "REFUNDED";
}

export interface Payout {
  id: UUID;
  amount: Ariary | null;
  status: PayoutStatus;
  label: string;
  orderCount: number;
}

/* ------------------------------------------------------------------ */
/* Messages & notifications                                            */
/* ------------------------------------------------------------------ */

export interface Conversation {
  id: UUID;
  context: MessageContext;
  counterpart: { name: string; initials: string; color: string };
  topic: string;
  lastMessage: string;
  lastMessageAt: string;
  unread: boolean;
  order?: { number: string; label: string } | null;
  shopSlug?: string;
}

export interface Message {
  id: UUID;
  conversationId: UUID;
  mine: boolean;
  body: string;
  time: string;
}

export type NotificationKind = "order" | "sale" | "promo" | "msg" | "stock" | "review";

export interface AppNotification {
  id: UUID;
  context: NotificationContext;
  kind: NotificationKind;
  title: string;
  body: string;
  link: string;
  readAt: ISODate | null;
  timeLabel: string;
  group: string;
  cta?: string;
}

/* ------------------------------------------------------------------ */
/* Admin                                                               */
/* ------------------------------------------------------------------ */

export interface AdminDashboard {
  asOf: string;
  kpis: {
    label: string;
    value: string;
    delta: string;
    tone: "up" | "down" | "warning" | "danger";
    icon: IconName;
    href: string;
    highlight?: boolean;
  }[];
  gmv: { month: string; current: number; previous: number }[];
  topCategories: { name: string; share: number }[];
  signups: { buyers: number; sellers: number }[];
  signupTotals: { buyers: number; sellers: number };
  ordersByStatus: { label: string; count: number; share: number; color: string }[];
  ordersTotal: number;
  queue: { icon: IconName; title: string; detail: string; count: number; href: string; tone: "warning" | "danger" | "info" }[];
}

export type ReviewCheck = "COMPLETE" | "TO_CHECK" | "MISSING_INFO" | "PHOTOS";

export interface AdminProductRow {
  id: UUID;
  name: string;
  photoCount: number;
  origin: string;
  seller: string;
  sellerNote: string;
  newSeller: boolean;
  category: string;
  priceLabel: string;
  check: ReviewCheck;
  submittedLabel: string;
  tint: string;
  status: ProductStatus;
}

export interface AdminUserRow {
  id: UUID;
  name: string;
  initials: string;
  color: string;
  emailMasked: string;
  isSeller: boolean;
  since: string;
  orders: number;
  status: "ACTIVE" | "VERIFYING" | "SUSPENDED";
  sales30d: string;
}

export interface AdminOrderRow {
  id: UUID;
  number: string;
  dateLabel: string;
  client: string;
  sellers: string;
  total: Ariary;
  paymentMethod: string;
  paymentStatus: "HELD" | "RELEASED" | "COD" | "REFUNDED";
  status: "DELIVERED" | "IN_DELIVERY" | "PREPARING" | "PENDING" | "DISPUTE" | "CANCELLED";
}

export interface AdminReport {
  id: UUID;
  number: number;
  targetType: ReportTargetType;
  reason: string;
  target: string;
  whenLabel: string;
  count: number;
  priority: boolean;
  meta: string;
  excerpt: string;
  reportedBy: string;
  history: string;
  tint: string;
  status: ReportStatus;
}
