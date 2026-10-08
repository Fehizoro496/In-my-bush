"use client";

import Link from "next/link";
import { usePathname, useSearchParams } from "next/navigation";
import { cn } from "@/lib/cn";
import { ROUTES, isRoute, withQuery } from "@/lib/routing/routes";

export interface HeaderCategory {
  name: string;
  slug: string;
}

/** Second header row: category links (active one in green, bold). */
export function HeaderCategoryLinks({ categories }: { categories: HeaderCategory[] }) {
  const pathname = usePathname();
  const params = useSearchParams();
  const active = isRoute(pathname, ROUTES.catalogue, { exact: true }) ? (params.get("categorie") ?? "fruits-legumes") : null;
  return <CategoryLinks categories={categories} active={active} />;
}

export function CategoryLinks({ categories, active }: { categories: HeaderCategory[]; active: string | null }) {
  return (
    <ul className="m-0 flex min-w-0 list-none items-center gap-6 overflow-x-auto p-0 text-[14px] scrollbar-none">
      {categories.map((c) => {
        const on = c.slug === active;
        return (
          <li key={c.slug} className="shrink-0">
            <Link
              href={withQuery(ROUTES.catalogue, { categorie: c.slug })}
              aria-current={on ? "page" : undefined}
              className={cn(
                "flex min-h-11 items-center whitespace-nowrap no-underline hover:text-pomme-700",
                on ? "font-bold text-pomme-700" : "font-medium text-ink",
              )}
            >
              {c.name}
            </Link>
          </li>
        );
      })}
    </ul>
  );
}
