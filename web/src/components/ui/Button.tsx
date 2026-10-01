import Link from "next/link";
import type { ComponentProps, ReactNode } from "react";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "./Icon";

export type ButtonVariant =
  | "primary"
  | "secondary"
  | "outline"
  | "ghost"
  | "danger"
  | "danger-outline"
  | "neutral"
  | "dark"
  | "soft";
export type ButtonSize = "sm" | "md" | "lg" | "xl";

const VARIANTS: Record<ButtonVariant, string> = {
  // Primaire — action principale
  primary:
    "bg-pomme-500 text-on-primary hover:bg-[#7DB834] hover:shadow-[0_4px_12px_rgba(92,145,32,0.25)] active:bg-[#6BA329] active:translate-y-px",
  // Secondaire — promo, attention
  secondary:
    "bg-orange-500 text-on-secondary hover:bg-[#E57E1B] hover:shadow-[0_4px_12px_rgba(216,111,18,0.25)] active:bg-orange-600 active:translate-y-px",
  // Contour — action alternative (green outline)
  outline:
    "border-[1.5px] border-pomme-500 bg-white text-pomme-800 hover:border-pomme-600 hover:bg-pomme-50 active:bg-mint",
  // Fantôme — tertiaire
  ghost: "bg-transparent text-pomme-700 hover:bg-pomme-100 hover:text-pomme-800 active:bg-mint",
  danger: "bg-danger-fg text-white hover:bg-[#A92C23] active:bg-[#92251D]",
  "danger-outline": "border-[1.5px] border-danger-border bg-white text-danger-fg hover:bg-danger-bg",
  // Neutral outline (grey border) used for secondary actions everywhere in the mockups
  neutral: "border-[1.5px] border-line-strong bg-white text-ink hover:border-stone hover:bg-bg",
  dark: "bg-ink text-white hover:bg-[#33382a]",
  soft: "bg-pomme-100 text-pomme-800 hover:bg-mint",
};

const SIZES: Record<ButtonSize, string> = {
  sm: "h-9 gap-1.5 rounded-lg px-3.5 text-[14px]",
  md: "h-11 gap-2 rounded-[10px] px-[18px] text-[15px]",
  lg: "h-13 gap-2 rounded-md px-6 text-[16px]",
  xl: "h-14 gap-2 rounded-[14px] px-6 text-[17px]",
};

export function buttonClasses({
  variant = "primary",
  size = "md",
  block,
  className,
}: {
  variant?: ButtonVariant;
  size?: ButtonSize;
  block?: boolean;
  className?: string;
}) {
  return cn(
    "inline-flex shrink-0 items-center justify-center font-bold whitespace-nowrap no-underline transition-[background-color,box-shadow,border-color,color] duration-[120ms]",
    "disabled:cursor-not-allowed disabled:border-0 disabled:bg-fog disabled:text-disabled disabled:shadow-none",
    "aria-disabled:pointer-events-none aria-disabled:bg-fog aria-disabled:text-disabled",
    VARIANTS[variant],
    SIZES[size],
    block && "w-full",
    // keep link colors from global `a` styles
    "hover:no-underline",
    className,
  );
}

interface CommonProps {
  variant?: ButtonVariant;
  size?: ButtonSize;
  block?: boolean;
  icon?: IconName;
  iconRight?: IconName;
  iconSize?: number;
  loading?: boolean;
  children?: ReactNode;
}

export type ButtonProps = CommonProps & Omit<ComponentProps<"button">, "children">;

export function Button({
  variant,
  size,
  block,
  icon,
  iconRight,
  iconSize,
  loading,
  className,
  children,
  type = "button",
  disabled,
  ...rest
}: ButtonProps) {
  const is = iconSize ?? (size === "sm" ? 16 : size === "lg" || size === "xl" ? 20 : 18);
  return (
    <button
      type={type}
      className={buttonClasses({ variant, size, block, className })}
      disabled={disabled || loading}
      aria-busy={loading || undefined}
      {...rest}
    >
      {loading ? (
        <span className="animate-spin-slow inline-block size-4 rounded-full border-2 border-current border-r-transparent" />
      ) : (
        icon && <Icon name={icon} size={is} />
      )}
      {children}
      {iconRight && <Icon name={iconRight} size={is} />}
    </button>
  );
}

export type ButtonLinkProps = CommonProps & Omit<ComponentProps<typeof Link>, "children">;

export function ButtonLink({
  variant,
  size,
  block,
  icon,
  iconRight,
  iconSize,
  className,
  children,
  ...rest
}: ButtonLinkProps) {
  const is = iconSize ?? (size === "sm" ? 16 : size === "lg" || size === "xl" ? 20 : 18);
  const color =
    variant === "primary" || variant === undefined
      ? "text-on-primary hover:text-on-primary"
      : variant === "secondary"
        ? "text-on-secondary hover:text-on-secondary"
        : variant === "danger" || variant === "dark"
          ? "text-white hover:text-white"
          : variant === "neutral"
            ? "text-ink hover:text-ink"
            : variant === "danger-outline"
              ? "text-danger-fg hover:text-danger-fg"
              : "text-pomme-800 hover:text-pomme-800";
  return (
    <Link className={buttonClasses({ variant, size, block, className: cn(color, className) })} {...rest}>
      {icon && <Icon name={icon} size={is} />}
      {children}
      {iconRight && <Icon name={iconRight} size={is} />}
    </Link>
  );
}

/** Square/round icon-only button (≥ 44 px target by default). */
export function IconButton({
  icon,
  label,
  size = 44,
  iconSize = 20,
  variant = "outline-round",
  className,
  type = "button",
  ...rest
}: {
  icon: IconName;
  label: string;
  size?: number;
  iconSize?: number;
  variant?: "outline-round" | "outline" | "ghost" | "primary" | "sand" | "fav";
} & Omit<ComponentProps<"button">, "children">) {
  const v = {
    "outline-round": "rounded-full border-[1.5px] border-line-strong bg-white text-ink hover:bg-bg",
    outline: "rounded-[10px] border-[1.5px] border-line-strong bg-white text-ink hover:bg-bg",
    ghost: "rounded-[10px] bg-transparent text-body hover:bg-sand",
    primary: "rounded-md bg-pomme-500 text-on-primary hover:bg-[#7DB834]",
    sand: "rounded-md bg-sand text-ink hover:bg-divider",
    fav: "rounded-full bg-orange-50 text-orange-600",
  }[variant];
  return (
    <button
      type={type}
      aria-label={label}
      title={label}
      className={cn("inline-flex shrink-0 items-center justify-center transition-colors", v, className)}
      style={{ width: size, height: size }}
      {...rest}
    >
      <Icon name={icon} size={iconSize} />
    </button>
  );
}
