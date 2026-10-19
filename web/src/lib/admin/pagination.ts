/** Paging of the backoffice lists: the API returns one page at a time, never the whole list. */
export const PAGE_SIZES = [10, 25, 50] as const;
export const DEFAULT_PAGE_SIZE = 10;

/** Bounds of the rows per page of a backoffice table, which shows as many rows as its screen holds. */
export const MIN_ROWS = 3;
export const MAX_ROWS = 50;
/** Cookie holding the rows that fit on screen, one per table, so the server renders the right page. */
export const rowsCookie = (table: string) => `imb_rows_${table}`;

/** Rows per page remembered for a table; anything out of bounds falls back to the default. */
export function parseRows(value: string | undefined): number {
  const rows = Number(value);
  return Number.isInteger(rows) && rows >= MIN_ROWS && rows <= MAX_ROWS ? rows : DEFAULT_PAGE_SIZE;
}

/** Rows of `rowHeight` px that fit in `available` px, within the bounds. */
export function fittingRows(available: number, rowHeight: number): number {
  if (!(rowHeight > 0) || !(available > 0)) return MIN_ROWS;
  return Math.min(MAX_ROWS, Math.max(MIN_ROWS, Math.floor(available / rowHeight)));
}

/** Rows per page asked in the URL; anything else than a listed size falls back to the default. */
export function parsePageSize(value: string | undefined): number {
  const size = Number(value);
  return (PAGE_SIZES as readonly number[]).includes(size) ? size : DEFAULT_PAGE_SIZE;
}

/** 1-based page asked in the URL. */
export function parsePage(value: string | undefined): number {
  const page = Math.floor(Number(value));
  return Number.isFinite(page) && page >= 1 ? page : 1;
}

/** One page of a list the API returns whole, in the shape of the paginated endpoints. */
export function pageOf<T>(all: T[], page: number, size: number): { items: T[]; page: number; size: number; totalItems: number; totalPages: number } {
  const totalPages = Math.max(1, Math.ceil(all.length / size));
  const index = Math.min(Math.max(1, page), totalPages) - 1;
  return { items: all.slice(index * size, (index + 1) * size), page: index, size, totalItems: all.length, totalPages };
}

/** First and last row shown (1-based) for a 0-based page, or null when the page is empty. */
export function pageRange(page: number, size: number, shown: number): { from: number; to: number } | null {
  if (shown <= 0) return null;
  const from = page * size + 1;
  return { from, to: from + shown - 1 };
}

/** Query string values that keep the current filters and page size; defaults are left out. */
export function pagerQuery(
  query: Record<string, string>,
  size: number,
  page: number,
): Record<string, string | number | undefined> {
  return { ...query, size: size === DEFAULT_PAGE_SIZE ? undefined : size, page: page <= 1 ? undefined : page };
}
