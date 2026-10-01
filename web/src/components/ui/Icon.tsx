import {
  ArrowLeft,
  ArrowRight,
  Award,
  Ban,
  Bell,
  Calendar,
  Camera,
  ChartColumn,
  Check,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  ChevronUp,
  CircleCheck,
  Clock,
  Compass,
  CreditCard,
  Dot,
  Download,
  Ellipsis,
  Eye,
  Filter,
  Flag,
  Heart,
  House,
  Image,
  Info,
  Layers,
  LayoutGrid,
  Leaf,
  List,
  Lock,
  LogOut,
  Mail,
  MapPin,
  Menu,
  MessageSquare,
  Minus,
  Package,
  Pencil,
  Percent,
  Plus,
  Receipt,
  RefreshCw,
  Search,
  Settings,
  Share2,
  ShieldCheck,
  ShoppingBasket,
  ShoppingCart,
  SlidersHorizontal,
  Sprout,
  Star,
  Store,
  Tag,
  Trash2,
  TrendingUp,
  TriangleAlert,
  Truck,
  Upload,
  User,
  Users,
  Wallet,
  WifiOff,
  X,
  type LucideIcon,
} from "lucide-react";

/**
 * Maps the design-system icon names (Icon.dc.html) to Lucide icons.
 * Stroke 1.8 px on a 24 grid, like the mockups.
 */
const ICONS = {
  home: House,
  search: Search,
  compass: Compass,
  plus: Plus,
  minus: Minus,
  cart: ShoppingCart,
  user: User,
  heart: Heart,
  heartF: Heart,
  star: Star,
  starO: Star,
  pin: MapPin,
  sliders: SlidersHorizontal,
  chevR: ChevronRight,
  chevL: ChevronLeft,
  chevD: ChevronDown,
  chevU: ChevronUp,
  arrowL: ArrowLeft,
  arrowR: ArrowRight,
  check: Check,
  x: X,
  bell: Bell,
  msg: MessageSquare,
  truck: Truck,
  leaf: Leaf,
  sprout: Sprout,
  shield: ShieldCheck,
  package: Package,
  chart: ChartColumn,
  trend: TrendingUp,
  settings: Settings,
  users: Users,
  store: Store,
  tag: Tag,
  flag: Flag,
  award: Award,
  card: CreditCard,
  wallet: Wallet,
  trash: Trash2,
  edit: Pencil,
  eye: Eye,
  camera: Camera,
  image: Image,
  more: Ellipsis,
  grid: LayoutGrid,
  list: List,
  clock: Clock,
  alert: TriangleAlert,
  wifiOff: WifiOff,
  logout: LogOut,
  receipt: Receipt,
  layers: Layers,
  upload: Upload,
  download: Download,
  refresh: RefreshCw,
  filter: Filter,
  calendar: Calendar,
  percent: Percent,
  basket: ShoppingBasket,
  mail: Mail,
  lock: Lock,
  ban: Ban,
  info: Info,
  checkCircle: CircleCheck,
  menu: Menu,
  share: Share2,
  dot: Dot,
} satisfies Record<string, LucideIcon>;

export type IconName = keyof typeof ICONS;

/** Icons drawn filled (solid) rather than stroked. */
const FILLED: ReadonlySet<IconName> = new Set<IconName>(["heartF", "star"]);

export interface IconProps {
  name: IconName;
  /** Size in px (default 20). */
  size?: number;
  className?: string;
  strokeWidth?: number;
  /** Accessible label. Without it the icon is decorative (aria-hidden). */
  label?: string;
}

export function Icon({ name, size = 20, className, strokeWidth, label }: IconProps) {
  const Cmp = ICONS[name];
  const filled = FILLED.has(name);
  const stroke = strokeWidth ?? (name === "check" ? 2.2 : name === "plus" || name === "minus" ? 2 : 1.8);
  return (
    <Cmp
      width={size}
      height={size}
      strokeWidth={filled ? 0 : stroke}
      fill={filled ? "currentColor" : "none"}
      className={className}
      aria-hidden={label ? undefined : true}
      aria-label={label}
      role={label ? "img" : undefined}
      focusable="false"
      style={{ flexShrink: 0 }}
    />
  );
}
