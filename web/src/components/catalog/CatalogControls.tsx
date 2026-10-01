"use client";

import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";
import { cn } from "@/lib/cn";
import { formatAriary } from "@/lib/format";
import type { CatalogFacet } from "@/lib/types";
import { Icon } from "@/components/ui/Icon";
import { Checkbox, Select } from "@/components/ui/Form";
import { Switch } from "@/components/ui/Switch";
import { FilterChip, RemovableChip } from "@/components/ui/Chip";
import { Drawer } from "@/components/ui/Modal";
import { Button } from "@/components/ui/Button";

const SORTS = [
  { value: "pertinence", label: "Pertinence" },
  { value: "prix-asc", label: "Prix croissant" },
  { value: "prix-desc", label: "Prix décroissant" },
  { value: "note", label: "Mieux notés" },
  { value: "nouveautes", label: "Nouveautés" },
];

function useQueryUpdater() {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  return (key: string, value: string | null) => {
    const next = new URLSearchParams(params.toString());
    if (value) next.set(key, value);
    else next.delete(key);
    next.delete("page");
    router.push(`${pathname}?${next.toString()}`, { scroll: false });
  };
}

/** "Trier par" select bound to `?tri=`. */
export function SortSelect({ value, label = true }: { value: string; label?: boolean }) {
  const update = useQueryUpdater();
  return (
    <div className="flex items-center gap-2.5">
      {label && (
        <label htmlFor="sort" className="hidden text-[14px] text-muted sm:block">
          Trier par
        </label>
      )}
      <Select
        id="sort"
        aria-label="Trier par"
        size="sm"
        value={value}
        onChange={(e) => update("tri", e.target.value === "pertinence" ? null : e.target.value)}
        options={SORTS}
        className="h-11 w-[170px] font-semibold"
      />
    </div>
  );
}

/** Grid / list toggle. */
export function ViewToggle() {
  const [view, setView] = useState<"grid" | "list">("grid");
  return (
    <div role="group" aria-label="Affichage" className="hidden rounded-[10px] bg-sand p-[3px] sm:flex">
      {(["grid", "list"] as const).map((v) => (
        <button
          key={v}
          type="button"
          aria-label={v === "grid" ? "Grille" : "Liste"}
          aria-pressed={view === v}
          onClick={() => setView(v)}
          className={cn(
            "flex h-[38px] w-10 items-center justify-center rounded-lg",
            view === v ? "bg-white text-ink shadow-[0_1px_2px_rgba(31,35,24,0.1)]" : "text-muted",
          )}
        >
          <Icon name={v} size={18} />
        </button>
      ))}
    </div>
  );
}

/** Price range: two native range inputs over a styled track. */
function PriceRange() {
  const MAX = 15000;
  const [min, setMin] = useState(1000);
  const [max, setMax] = useState(10000);
  return (
    <div className="flex flex-col gap-3">
      <div className="flex justify-between">
        <b className="text-[14px]">Prix</b>
        <span className="text-[13px] font-semibold text-pomme-700 font-tabular">
          {formatAriary(min).replace(/ Ar$/, "")} – {formatAriary(max)}
        </span>
      </div>
      <div className="relative mx-2.5 h-[22px]">
        <div className="absolute inset-x-0 top-[9px] h-1 rounded bg-line-strong" />
        <div
          className="absolute top-[9px] h-1 bg-pomme-500"
          style={{ left: `${(min / MAX) * 100}%`, right: `${100 - (max / MAX) * 100}%` }}
        />
        <input
          type="range"
          aria-label="Prix minimum"
          min={0}
          max={MAX}
          step={500}
          value={min}
          onChange={(e) => setMin(Math.min(Number(e.target.value), max - 500))}
          className="imb-range absolute inset-0 w-full"
        />
        <input
          type="range"
          aria-label="Prix maximum"
          min={0}
          max={MAX}
          step={500}
          value={max}
          onChange={(e) => setMax(Math.max(Number(e.target.value), min + 500))}
          className="imb-range absolute inset-0 w-full"
        />
      </div>
    </div>
  );
}

const CHECK_GROUPS = [
  { title: "Note", options: [["4,5 ★ et plus", 86, true], ["4 ★ et plus", 173, false], ["3 ★ et plus", 231, false]] },
  { title: "Type de produit", options: [["Frais", 201, false], ["Transformé", 31, false], ["Panier composé", 13, false]] },
  { title: "Vendeur", options: [["Vendeur vérifié", 230, false], ["Retrait sur place", 96, false]] },
] as const;

/** Filter panel (desktop sidebar, and content of the tablet/phone drawer). */
export function FilterPanel({
  subcategories,
  categorySlug,
  bordered = true,
}: {
  subcategories: CatalogFacet[];
  categorySlug: string;
  bordered?: boolean;
}) {
  const [distance, setDistance] = useState("< 15 km");
  const [sub, setSub] = useState("");
  return (
    <div className={cn("flex flex-col gap-[22px]", bordered && "rounded-xl border border-line bg-white p-5")}>
      {bordered && (
        <div className="flex items-center justify-between">
          <b className="flex items-center gap-2 text-[17px]">
            <Icon name="sliders" size={18} />
            Filtres
          </b>
          <Link href={`/catalogue?categorie=${categorySlug}`} className="text-[13px] font-bold no-underline">
            Réinitialiser
          </Link>
        </div>
      )}
      <div className="flex flex-col gap-1">
        <b className="mb-1.5 text-[14px]">Catégorie</b>
        {subcategories.map((s) => {
          const on = s.slug === sub;
          return (
            <button
              key={s.label}
              type="button"
              aria-pressed={on}
              onClick={() => setSub(s.slug)}
              className={cn(
                "flex h-9 items-center justify-between rounded-lg px-2.5 text-left text-[14px]",
                on ? "bg-pomme-100 font-bold text-pomme-800" : "font-medium text-ink hover:bg-bg",
              )}
            >
              {s.label}
              <span className="text-[12px] font-medium text-muted">{s.count}</span>
            </button>
          );
        })}
      </div>
      <hr className="m-0 h-px border-0 bg-divider" />
      <PriceRange />
      <hr className="m-0 h-px border-0 bg-divider" />
      <div className="flex flex-col gap-2.5">
        <b className="text-[14px]">Localisation</b>
        <Select
          aria-label="Région"
          size="sm"
          defaultValue="Analamanga"
          options={["Analamanga", "Vakinankaratra", "Alaotra-Mangoro", "Sava", "Atsinanana", "Haute Matsiatra"].map((r) => ({ value: r, label: r }))}
          className="h-[42px]"
        />
        <div className="flex flex-wrap gap-1.5">
          {["< 5 km", "< 15 km", "< 50 km", "Toute l’île"].map((d) => (
            <FilterChip key={d} size="sm" selected={distance === d} onToggle={() => setDistance(d)} className="h-8 text-[13px] font-semibold">
              {d}
            </FilterChip>
          ))}
        </div>
      </div>
      <hr className="m-0 h-px border-0 bg-divider" />
      {CHECK_GROUPS.map((g) => (
        <fieldset key={g.title} className="m-0 flex flex-col gap-1 border-0 p-0">
          <legend className="mb-1.5 p-0 text-[14px] font-bold">{g.title}</legend>
          {g.options.map(([label, count, on]) => (
            <Checkbox key={label} label={label} hint={count} defaultChecked={on} />
          ))}
        </fieldset>
      ))}
      <Switch label="En stock uniquement" showLabel defaultChecked size="sm" />
    </div>
  );
}

/** Active filter chips + "Tout effacer". */
export function ActiveFilters({ filters, prefix }: { filters: string[]; prefix?: boolean }) {
  const [list, setList] = useState(filters);
  if (list.length === 0) return null;
  return (
    <div className="flex flex-wrap items-center gap-2">
      {prefix && <span className="text-[13px] text-muted">Filtres actifs :</span>}
      {list.map((f) => (
        <RemovableChip key={f} onRemove={() => setList(list.filter((x) => x !== f))}>
          {f}
        </RemovableChip>
      ))}
      <button type="button" onClick={() => setList([])} className="h-[34px] px-1 text-[13px] font-bold text-muted underline">
        Tout effacer
      </button>
    </div>
  );
}

/** Tablet/phone: "Filtres (3)" button opening the filter drawer + subcategory chips. */
export function MobileFilters({
  subcategories,
  categorySlug,
  activeCount,
}: {
  subcategories: CatalogFacet[];
  categorySlug: string;
  activeCount: number;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="flex h-11 items-center gap-2 rounded-md bg-ink px-3.5 text-[14px] font-bold text-white lg:hidden"
      >
        <Icon name="sliders" size={18} />
        Filtres
        <span className="flex size-5 items-center justify-center rounded-full bg-pomme-500 text-[12px] font-extrabold text-on-primary">
          {activeCount}
        </span>
      </button>
      <Drawer
        open={open}
        onClose={() => setOpen(false)}
        title="Filtres"
        footer={
          <div className="flex gap-2.5">
            <Button variant="neutral" onClick={() => setOpen(false)}>
              Réinitialiser
            </Button>
            <Button block onClick={() => setOpen(false)}>
              Afficher les résultats
            </Button>
          </div>
        }
      >
        <div className="p-5">
          <FilterPanel subcategories={subcategories} categorySlug={categorySlug} bordered={false} />
        </div>
      </Drawer>
    </>
  );
}

/** Subcategory pills (tablet, T-Catalog). */
export function SubcategoryChips({ subcategories }: { subcategories: CatalogFacet[] }) {
  const [sel, setSel] = useState(subcategories[0]?.label ?? "");
  return (
    <div className="-mx-4 flex gap-2 overflow-x-auto px-4 scrollbar-none md:mx-0 md:flex-wrap md:px-0 lg:hidden">
      {subcategories.map((s) => (
        <FilterChip key={s.label} variant="darkgreen" selected={sel === s.label} onToggle={() => setSel(s.label)}>
          {s.label}
        </FilterChip>
      ))}
    </div>
  );
}
