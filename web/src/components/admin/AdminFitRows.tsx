"use client";
import { useEffect, useRef } from "react";
import { fittingRows, rowsCookie } from "@/lib/admin/pagination";
import { routeService } from "@/lib/routing/route.service";
import { ROUTES } from "@/lib/routing/routes";

/**
 * Measures the card of a backoffice table from 1024 px and, when its page does not hold exactly the
 * rows that fit, remembers that count in a cookie and renders the list again from its first page.
 */
export function AdminFitRows({ table, rows }: { table: string; rows: number }) {
  const ref = useRef<HTMLSpanElement>(null);
  useEffect(() => {
    const desktop = window.matchMedia("(min-width: 1024px)");
    let timer: ReturnType<typeof setTimeout> | undefined;
    const fit = () => {
      const card = ref.current?.parentElement;
      const element = card?.querySelector("table");
      const body = element?.tBodies[0];
      if (!desktop.matches || !card || !element || !body?.rows.length) return;
      const rowHeight = Math.max(...Array.from(body.rows, (row) => row.offsetHeight));
      const fitting = fittingRows(card.clientHeight - (element.tHead?.offsetHeight ?? 0), rowHeight);
      // A short last page that fits is left alone; a full page that is too long or too short is resized.
      if (fitting === rows || (body.rows.length < rows && body.rows.length <= fitting)) return;
      document.cookie = `${rowsCookie(table)}=${fitting}; path=${ROUTES.admin}; max-age=31536000; samesite=lax`;
      const url = new URL(window.location.href);
      if (url.searchParams.has("page")) {
        url.searchParams.delete("page");
        routeService.navigate(url.pathname + url.search, { replace: true, scroll: false });
      } else routeService.refresh();
    };
    const later = () => { clearTimeout(timer); timer = setTimeout(fit, 150); };
    fit();
    window.addEventListener("resize", later);
    return () => { clearTimeout(timer); window.removeEventListener("resize", later); };
  }, [table, rows]);
  return <span ref={ref} hidden />;
}
