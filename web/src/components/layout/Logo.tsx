import { cn } from "@/lib/cn";
import { Icon } from "@/components/ui/Icon";

/** "In my bush." — pomme-green rounded square with a sprout + wordmark + orange dot. */
export function Logo({
  tone = "light",
  size = "md",
  className,
  markOnly = false,
}: {
  tone?: "light" | "dark";
  size?: "sm" | "md";
  className?: string;
  markOnly?: boolean;
}) {
  const box = size === "md" ? "size-[38px] rounded-md" : "size-8 rounded-[10px]";
  const text = size === "md" ? "text-[27px]" : "text-[22px]";
  return (
    <span className={cn("inline-flex items-center gap-2.5 font-display", className)}>
      <span className={cn("flex shrink-0 items-center justify-center bg-pomme-500 text-on-primary", box)} aria-hidden>
        <Icon name="sprout" size={size === "md" ? 24 : 20} />
      </span>
      {!markOnly && (
        <span
          className={cn(
            "flex items-baseline leading-none font-extrabold tracking-[-0.03em] whitespace-nowrap",
            text,
            tone === "dark" ? "text-[#F3F7EA]" : "text-ink",
          )}
        >
          In my bush<span className="text-orange-500">.</span>
        </span>
      )}
    </span>
  );
}
