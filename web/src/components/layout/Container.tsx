import type { ReactNode } from "react";
import { cn } from "@/lib/cn";

/** Page gutter: 16 px phone · 32 px tablet · 80 px desktop (content max 1280 at 1440). */
export function Container({ children, className }: { children: ReactNode; className?: string }) {
  return <div className={cn("mx-auto w-full max-w-[1440px] px-4 md:px-8 xl:px-20", className)}>{children}</div>;
}

/** Page title block: optional eyebrow/breadcrumb, H1, subtitle, actions on the right. */
export function PageHeader({
  title,
  subtitle,
  eyebrow,
  actions,
  className,
  size = "md",
  titleAside,
}: {
  title: ReactNode;
  subtitle?: ReactNode;
  eyebrow?: ReactNode;
  actions?: ReactNode;
  className?: string;
  size?: "sm" | "md" | "lg";
  titleAside?: ReactNode;
}) {
  const h = {
    sm: "text-[26px] md:text-[30px]",
    md: "text-[28px] md:text-[36px]",
    lg: "text-[30px] md:text-[40px]",
  }[size];
  return (
    <div className={cn("flex flex-wrap items-end justify-between gap-x-6 gap-y-4", className)}>
      <div className="flex min-w-0 flex-col gap-1">
        {eyebrow}
        <div className="flex flex-wrap items-center gap-3">
          <h1 className={cn("m-0 font-display leading-[1.08] font-extrabold tracking-[-0.025em]", h)}>{title}</h1>
          {titleAside}
        </div>
        {subtitle && <p className="m-0 text-[14px] text-muted md:text-[15px]">{subtitle}</p>}
      </div>
      {actions && <div className="flex flex-wrap items-center gap-2.5">{actions}</div>}
    </div>
  );
}

/** Section title row: H2 + link/action. */
export function SectionHeader({
  title,
  action,
  className,
  size = "md",
  aside,
}: {
  title: ReactNode;
  action?: ReactNode;
  className?: string;
  size?: "sm" | "md";
  aside?: ReactNode;
}) {
  return (
    <div className={cn("flex flex-wrap items-baseline justify-between gap-x-4 gap-y-2", className)}>
      <div className="flex flex-wrap items-baseline gap-x-3.5 gap-y-1">
        <h2
          className={cn(
            "m-0 font-display font-bold tracking-[-0.02em]",
            size === "md" ? "text-[24px] md:text-[30px]" : "text-[22px] md:text-[26px]",
          )}
        >
          {title}
        </h2>
        {aside}
      </div>
      {action}
    </div>
  );
}
