import type { ComponentProps, ReactNode } from "react";
import { cn } from "@/lib/cn";

/** Data table wrapper: horizontal scroll on small screens. */
export function Table({ className, children, minWidth = 720, ...rest }: ComponentProps<"table"> & { minWidth?: number }) {
  return (
    <div className="w-full overflow-x-auto">
      <table className={cn("w-full border-collapse text-[14px]", className)} style={{ minWidth }} {...rest}>
        {children}
      </table>
    </div>
  );
}

export function THead({ children }: { children: ReactNode }) {
  return (
    <thead>
      <tr className="bg-sand text-left text-[11px] tracking-[0.06em] text-muted uppercase">{children}</tr>
    </thead>
  );
}

export function Th({ className, children, ...rest }: ComponentProps<"th">) {
  return (
    <th scope="col" className={cn("px-2 py-2.5 font-bold first:pl-5 last:pr-5", className)} {...rest}>
      {children}
    </th>
  );
}

export function Tr({ className, children, selected, ...rest }: ComponentProps<"tr"> & { selected?: boolean }) {
  return (
    <tr className={cn("border-t border-divider", selected ? "bg-pomme-50" : "bg-white", className)} {...rest}>
      {children}
    </tr>
  );
}

export function Td({ className, children, ...rest }: ComponentProps<"td">) {
  return (
    <td className={cn("px-2 py-3 align-middle first:pl-5 last:pr-5", className)} {...rest}>
      {children}
    </td>
  );
}
