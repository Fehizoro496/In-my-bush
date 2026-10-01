import type { ComponentProps, ReactNode } from "react";
import { cn } from "@/lib/cn";

/** White surface with the standard border (#EAE6DB) and 20 px radius. */
export function Card({
  className,
  padding = "md",
  as: Tag = "section",
  children,
  ...rest
}: {
  padding?: "none" | "sm" | "md" | "lg";
  as?: "section" | "div" | "article" | "aside";
  children?: ReactNode;
} & Omit<ComponentProps<"section">, "ref">) {
  const pad = { none: "", sm: "p-[18px]", md: "p-5 md:p-[22px]", lg: "p-6 md:p-7" }[padding];
  return (
    <Tag className={cn("rounded-xl border border-line bg-white", pad, className)} {...rest}>
      {children}
    </Tag>
  );
}

/** Card section title (Figtree 17–18 px bold). */
export function CardTitle({
  children,
  className,
  as: Tag = "h2",
}: {
  children: ReactNode;
  className?: string;
  as?: "h2" | "h3";
}) {
  return <Tag className={cn("m-0 text-[17px] font-bold md:text-[18px]", className)}>{children}</Tag>;
}

/** Header row inside a card: title on the left, action on the right. */
export function CardHeader({ title, action, className }: { title: ReactNode; action?: ReactNode; className?: string }) {
  return (
    <div className={cn("flex items-center justify-between gap-3", className)}>
      {typeof title === "string" ? <CardTitle>{title}</CardTitle> : title}
      {action}
    </div>
  );
}
