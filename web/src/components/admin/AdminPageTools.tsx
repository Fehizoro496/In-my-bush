import type { ReactNode } from "react";
import Link from "next/link";
import { cookies } from "next/headers";
import { AdminFitRows } from "./AdminFitRows";
import { Pagination } from "@/components/ui/Navigation";
import { PAGE_SIZES, pageRange, pagerQuery, parsePage, parsePageSize, parseRows, rowsCookie } from "@/lib/admin/pagination";
import { cn } from "@/lib/cn";
import { formatNumber } from "@/lib/format";
import { withQuery } from "@/lib/routing/routes";
import type { Page } from "@/lib/types";

export type Search = Record<string, string | string[] | undefined>;
export const textParam = (q: Search, key: string) => typeof q[key] === "string" ? q[key] : "";
export const pageParam = (q: Search) => parsePage(textParam(q, "page"));
export const sizeParam = (q: Search) => parsePageSize(textParam(q, "size"));
/** Rows per page of a backoffice table: those that fit on the admin's screen, remembered by AdminFitRows. */
export const tableRows = async (table: string) => parseRows((await cookies()).get(rowsCookie(table))?.value);
export const dateLabel = (value: string) => new Date(value).toLocaleDateString("fr-FR", { timeZone: "Indian/Antananarivo" });

/** Keeps the chosen page size when a filter form is submitted. */
export function AdminKeepSize({ q }: { q: Search }) {
  return textParam(q, "size") ? <input type="hidden" name="size" value={sizeParam(q)} /> : null;
}

/**
 * Card holding a paginated table. From 1024 px it fills the height left under the filters and neither
 * the page nor the table scrolls: AdminFitRows sizes the pages to the rows that fit in the card.
 */
export function AdminTableCard({ children, empty, table, rows }: { children: ReactNode; empty?: ReactNode; table: string; rows: number }) {
  return (
    <section className="flex flex-col overflow-hidden rounded-xl border border-line bg-white lg:min-h-60 lg:flex-1">
      {children}
      {empty && <p className="p-5">{empty}</p>}
      <AdminFitRows table={table} rows={rows} />
    </section>
  );
}

/** Rows shown, rows per page and numbered pages of a list the API serves one page at a time. */
export function AdminPager({ data, path, query = {}, sizes = true }: {
  data: Page<unknown>; path: string; query?: Record<string, string>;
  /** false for tables, whose rows per page follow the screen. */
  sizes?: boolean;
}) {
  const range = pageRange(data.page, data.size, data.items.length);
  const totalPages = Math.max(1, data.totalPages);
  return (
    <div className="flex flex-wrap items-center justify-between gap-x-6 gap-y-3 py-4 text-[14px] text-muted">
      <span>
        {range
          ? `${formatNumber(range.from)}–${formatNumber(range.to)} sur ${formatNumber(data.totalItems)}`
          : "Aucun résultat"}
      </span>
      <div className="flex flex-wrap items-center gap-x-6 gap-y-3">
        {sizes && <span className="flex items-center gap-1.5">
          <span className="pr-1">Par page</span>
          {PAGE_SIZES.map((size) => (
            <Link
              key={size}
              href={withQuery(path, pagerQuery(query, size, 1))}
              aria-current={size === data.size ? "true" : undefined}
              className={cn(
                "flex h-[34px] min-w-[34px] items-center justify-center rounded-lg px-2 text-[14px] font-bold no-underline",
                size === data.size
                  ? "bg-ink text-white hover:text-white"
                  : "border-[1.5px] border-line-strong bg-white text-ink hover:bg-bg hover:text-ink",
              )}
            >
              {size}
            </Link>
          ))}
        </span>}
        {totalPages > 1 && (
          <Pagination
            size="sm"
            page={data.page + 1}
            totalPages={totalPages}
            hrefFor={(page) => withQuery(path, pagerQuery(query, data.size, page))}
          />
        )}
      </div>
    </div>
  );
}

export function AdminFilter({ name, label, value, options }: { name: string; label: string; value: string; options: [string, string][] }) {
  return <label className="flex flex-col gap-1 text-sm">{label}<select name={name} defaultValue={value} className="rounded-lg border border-line bg-white p-2">
    {options.map(([id, text]) => <option key={id} value={id}>{text}</option>)}
  </select></label>;
}
