/**
 * Formatting helpers — all amounts are integer Ariary (no cents).
 * Display: "12 000 Ar" with a narrow no-break space (U+202F) as thousands
 * separator and a no-break space (U+00A0) before the currency.
 */

const NNBSP = " ";
const NBSP = " ";

const integerFormat = new Intl.NumberFormat("fr-FR", { maximumFractionDigits: 0 });

/** Group digits with a narrow no-break space: 12500 → "12 500". */
export function formatNumber(value: number): string {
  // fr-FR already uses U+202F, but normalise in case the runtime ICU differs.
  return integerFormat.format(Math.round(value)).replace(/[\s  ]/g, NNBSP);
}

/** 12000 → "12 000 Ar" ; -4250 → "−4 250 Ar". */
export function formatAriary(amount: number): string {
  const sign = amount < 0 ? "−" : "";
  return `${sign}${formatNumber(Math.abs(amount))}${NBSP}Ar`;
}

/** 1240000 → "1,24 M Ar" ; 182400000 → "182,4 M Ar". */
export function formatCompactAriary(amount: number): string {
  if (Math.abs(amount) >= 1_000_000) {
    const m = amount / 1_000_000;
    const str = new Intl.NumberFormat("fr-FR", { maximumFractionDigits: m >= 100 ? 1 : 2 }).format(m);
    return `${str}${NBSP}M${NBSP}Ar`;
  }
  return formatAriary(amount);
}

/** 4.8 → "4,8" ; 5 → "5,0". */
export function formatRating(value: number | null | undefined): string {
  if (value == null || Number.isNaN(value) || value === 0) return "—";
  return new Intl.NumberFormat("fr-FR", { minimumFractionDigits: 1, maximumFractionDigits: 1 }).format(value);
}

/** 0.2 → "−20 %" */
export function formatDiscount(price: number, compareAt: number): string {
  const pct = Math.round((1 - price / compareAt) * 100);
  return `−${pct}${NBSP}%`;
}

export function formatPercent(value: number, digits = 0): string {
  return `${new Intl.NumberFormat("fr-FR", { maximumFractionDigits: digits }).format(value)}${NBSP}%`;
}

const TZ = "Indian/Antananarivo";

/** "26 sept. 2026" */
export function formatDate(iso: string): string {
  return new Intl.DateTimeFormat("fr-FR", { day: "numeric", month: "short", year: "numeric", timeZone: TZ }).format(
    new Date(iso),
  );
}

/** "26 sept." */
export function formatShortDate(iso: string): string {
  return new Intl.DateTimeFormat("fr-FR", { day: "numeric", month: "short", timeZone: TZ }).format(new Date(iso));
}

/** "26 sept. 2026 à 18h02" */
export function formatDateTime(iso: string): string {
  const d = new Date(iso);
  const date = formatDate(iso);
  return `${date} à ${formatTime(d.toISOString())}`;
}

/** "18h02" */
export function formatTime(iso: string): string {
  const parts = new Intl.DateTimeFormat("fr-FR", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
    timeZone: TZ,
  }).formatToParts(new Date(iso));
  const h = parts.find((p) => p.type === "hour")?.value ?? "00";
  const m = parts.find((p) => p.type === "minute")?.value ?? "00";
  return `${Number(h)}h${m}`;
}

/** "il y a 3 jours", relative to `now` (defaults to the current date). */
export function formatRelative(iso: string, now: Date = new Date()): string {
  const rtf = new Intl.RelativeTimeFormat("fr-FR", { numeric: "auto" });
  const diffSec = Math.round((new Date(iso).getTime() - now.getTime()) / 1000);
  const abs = Math.abs(diffSec);
  if (abs < 60) return rtf.format(diffSec, "second");
  if (abs < 3600) return rtf.format(Math.round(diffSec / 60), "minute");
  if (abs < 86400) return rtf.format(Math.round(diffSec / 3600), "hour");
  if (abs < 86400 * 7) return rtf.format(Math.round(diffSec / 86400), "day");
  if (abs < 86400 * 30) return rtf.format(Math.round(diffSec / (86400 * 7)), "week");
  if (abs < 86400 * 365) return rtf.format(Math.round(diffSec / (86400 * 30)), "month");
  return rtf.format(Math.round(diffSec / (86400 * 365)), "year");
}

/** "Hery Rakoto" → "HR" */
export function initials(name: string): string {
  return name
    .replace(/[’'«»]/g, " ")
    .split(/\s+/)
    .filter((w) => w.length > 1 && !["le", "la", "les", "de", "du", "des", "et"].includes(w.toLowerCase()))
    .slice(0, 2)
    .map((w) => w[0]!.toUpperCase())
    .join("");
}

/** French plural helper: plural(3, "produit") → "3 produits". */
export function plural(n: number, singular: string, pluralForm = `${singular}s`): string {
  return `${formatNumber(n)} ${n > 1 ? pluralForm : singular}`;
}
