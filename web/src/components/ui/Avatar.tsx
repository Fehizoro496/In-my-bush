import { cn } from "@/lib/cn";

/** Initials avatar (round by default). */
export function Avatar({
  initials,
  color = "#365A10",
  size = 40,
  shape = "round",
  display = false,
  className,
  ring,
  textColor = "#FFFFFF",
}: {
  initials: string;
  color?: string;
  size?: number;
  shape?: "round" | "rounded";
  /** Use the display font (Bricolage) — for big avatars. */
  display?: boolean;
  className?: string;
  ring?: string;
  textColor?: string;
}) {
  const fontSize = Math.max(10, Math.round(size * (display ? 0.34 : 0.32)));
  return (
    <span
      aria-hidden
      className={cn(
        "inline-flex shrink-0 items-center justify-center font-extrabold",
        shape === "round" ? "rounded-full" : "rounded-[22%]",
        display && "font-display",
        className,
      )}
      style={{
        width: size,
        height: size,
        background: color,
        color: textColor,
        fontSize,
        boxShadow: ring ? `0 0 0 ${ring}` : undefined,
      }}
    >
      {initials}
    </span>
  );
}
