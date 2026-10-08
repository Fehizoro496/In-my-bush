"use client";

import Link from "next/link";
import { useState } from "react";
import type { SearchResult } from "@/lib/types";
import { FilterChip } from "@/components/ui/Chip";
import { Icon } from "@/components/ui/Icon";
import { ROUTES, withQuery } from "@/lib/routing/routes";

export function SearchRefine({ options }: { options: string[] }) {
  const [on, setOn] = useState<Record<string, boolean>>({ [options[0]!]: true });
  return (
    <div className="flex flex-wrap items-center gap-2.5">
      <span className="text-[14px] text-muted">Affiner :</span>
      {options.map((o) => (
        <FilterChip key={o} selected={!!on[o]} onToggle={(v) => setOn({ ...on, [o]: v })}>
          {o}
        </FilterChip>
      ))}
    </div>
  );
}

/** Search box with the suggestions dropdown (W-Search). */
export function SearchBox({ query, suggestions, recent }: { query: string; suggestions: SearchResult["suggestions"]; recent: string[] }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="relative" onBlur={(e) => !e.currentTarget.contains(e.relatedTarget) && setOpen(false)}>
      <form role="search" action={ROUTES.search} className="flex h-[52px] items-center gap-2.5 rounded-md border-[1.5px] border-pomme-600 bg-white px-3.5 shadow-[0_0_0_4px_rgba(140,198,63,0.22)]">
        <Icon name="search" size={20} className="text-muted" />
        <label htmlFor="search-q" className="sr-only">
          Rechercher
        </label>
        <input
          id="search-q"
          name="q"
          defaultValue={query}
          autoComplete="off"
          role="combobox"
          aria-expanded={open}
          aria-controls="search-suggestions"
          onFocus={() => setOpen(true)}
          className="h-full min-w-0 flex-1 border-0 bg-transparent text-[16px] outline-none focus-visible:outline-none"
        />
        <button type="submit" aria-label="Rechercher" className="flex size-[38px] items-center justify-center rounded-sm bg-pomme-500 text-on-primary">
          <Icon name="arrowR" size={18} />
        </button>
      </form>
      {open && (
        <div
          id="search-suggestions"
          role="listbox"
          aria-label="Suggestions de recherche"
          className="absolute inset-x-0 top-[60px] z-30 flex flex-col rounded-lg border border-line-strong bg-white p-2 shadow-[0_16px_40px_rgba(31,35,24,0.16)]"
        >
          {suggestions.map((s, i) => (
            <Link
              key={i}
              role="option"
              aria-selected={i === 0}
              href={withQuery(ROUTES.search, { q: `${s.hit}${s.rest}`.trim() })}
              className="flex min-h-11 items-center gap-3 rounded-[10px] px-3 text-ink no-underline hover:bg-pomme-100 hover:text-ink aria-selected:bg-pomme-100"
            >
              <Icon name={s.icon} size={17} className="text-disabled" />
              <span className="flex-1 text-[15px]">
                <b>{s.hit}</b>
                {s.rest}
              </span>
              <span className="text-[12px] text-muted">{s.meta}</span>
            </Link>
          ))}
          <div className="mt-1.5 flex flex-wrap items-center gap-2 border-t border-divider px-3 pt-2.5 pb-1">
            <span className="text-[12px] font-bold tracking-[0.06em] text-muted uppercase">Récentes</span>
            {recent.map((r) => (
              <Link
                key={r}
                href={withQuery(ROUTES.search, { q: r })}
                className="inline-flex h-[30px] items-center gap-1.5 rounded-full bg-sand px-2.5 text-[13px] text-ink no-underline hover:text-ink"
              >
                <Icon name="clock" size={13} />
                {r}
              </Link>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
