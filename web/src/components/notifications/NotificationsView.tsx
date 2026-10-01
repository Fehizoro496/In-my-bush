"use client";

import Link from "next/link";
import { useState } from "react";
import { cn } from "@/lib/cn";
import type { AppNotification, NotificationKind } from "@/lib/types";
import { Button } from "@/components/ui/Button";
import { ChipGroup } from "@/components/ui/Chip";
import { CheckIndicator } from "@/components/ui/Form";
import { Icon, type IconName } from "@/components/ui/Icon";
import { EmptyState } from "@/components/ui/Feedback";

const KIND: Record<NotificationKind, { icon: IconName; bg: string; ink: string }> = {
  order: { icon: "truck", bg: "#E8F1FA", ink: "#2F6DA8" },
  sale: { icon: "store", bg: "#F0F6E6", ink: "#4A7A12" },
  promo: { icon: "percent", bg: "#FFF4E8", ink: "#D86F12" },
  msg: { icon: "msg", bg: "#F4F0E6", ink: "#4A4A42" },
  stock: { icon: "alert", bg: "#FFF1E0", ink: "#B4500A" },
  review: { icon: "starO", bg: "#FFF4E8", ink: "#D86F12" },
};

type Filter = "all" | "buy" | "sell" | "promo" | "msg";
const PREF_ROWS = ["Mes commandes", "Commandes reçues", "Messages", "Promotions", "Stock faible"];
const CHANNELS = ["App", "SMS", "E-mail"];

/** Notification list grouped by day + channel preferences (W-Notifications). */
export function NotificationsView({ notifications }: { notifications: AppNotification[] }) {
  const [filter, setFilter] = useState<Filter>("all");
  const [allRead, setAllRead] = useState(false);
  const [prefs, setPrefs] = useState<Record<string, boolean>>({
    "0-0": true, "0-1": true, "1-0": true, "1-1": true, "1-2": true, "2-0": true, "3-0": true, "3-2": true, "4-0": true,
  });

  const match = (n: AppNotification) =>
    filter === "all" ||
    (filter === "buy" && n.context === "PURCHASE" && n.kind !== "msg") ||
    (filter === "sell" && n.context === "SALE") ||
    (filter === "promo" && n.kind === "promo") ||
    (filter === "msg" && n.kind === "msg");
  const list = notifications.filter(match);
  const groups = [...new Set(list.map((n) => n.group))];

  return (
    <div className="flex flex-col gap-[18px]">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <h1 className="m-0 font-display text-[28px] font-extrabold tracking-[-0.025em] md:text-[36px]">Notifications</h1>
        <Button variant="neutral" icon="check" size="md" className="h-10 text-[14px]" onClick={() => setAllRead(true)}>
          Tout marquer comme lu
        </Button>
      </div>
      <ChipGroup
        label="Filtrer"
        size="sm"
        value={filter}
        onChange={setFilter}
        className="flex-nowrap overflow-x-auto scrollbar-none"
        options={[
          { value: "all", label: "Tout" },
          { value: "buy", label: "Achats" },
          { value: "sell", label: "Ventes" },
          { value: "promo", label: "Promotions" },
          { value: "msg", label: "Messages" },
        ]}
      />
      <div className="grid items-start gap-5 xl:grid-cols-[minmax(0,1fr)_300px]">
        <section className="overflow-hidden rounded-xl border border-line bg-white">
          {list.length === 0 && <EmptyState bordered={false} icon="bell" tone="info" title="Rien de nouveau" description="Aucune notification dans cette catégorie." />}
          {groups.map((g) => (
            <div key={g}>
              <h2 className="m-0 bg-bg px-5 pt-3.5 pb-2 text-[12px] font-bold tracking-[0.06em] text-muted uppercase">{g}</h2>
              <ul className="m-0 list-none p-0">
                {list
                  .filter((n) => n.group === g)
                  .map((n) => {
                    const k = KIND[n.kind];
                    const unread = !n.readAt && !allRead;
                    return (
                      <li key={n.id} className="border-t border-divider">
                        <Link href={n.link} className="flex items-start gap-3.5 px-4 py-3.5 text-ink no-underline hover:bg-bg hover:text-ink md:px-5">
                          <span className="flex size-[42px] shrink-0 items-center justify-center rounded-md" style={{ background: k.bg, color: k.ink }}>
                            <Icon name={k.icon} size={20} />
                          </span>
                          <span className="flex min-w-0 flex-1 flex-col gap-0.5">
                            <b className="text-[15px]">{n.title}</b>
                            <span className="text-[14px] text-body">{n.body}</span>
                            {n.cta && (
                              <span className="mt-1.5 inline-flex h-9 items-center self-start rounded-sm bg-pomme-500 px-3 text-[13px] font-bold whitespace-nowrap text-on-primary sm:hidden">
                                {n.cta}
                              </span>
                            )}
                          </span>
                          {n.cta && (
                            <span className="hidden h-9 items-center rounded-sm bg-pomme-500 px-3 text-[13px] font-bold whitespace-nowrap text-on-primary sm:inline-flex">
                              {n.cta}
                            </span>
                          )}
                          <span className="min-w-12 text-right text-[12px] whitespace-nowrap text-muted">{n.timeLabel}</span>
                          <span
                            aria-label={unread ? "Non lue" : undefined}
                            className={cn("mt-1.5 size-[9px] shrink-0 rounded-full", unread ? "bg-orange-500" : "bg-transparent")}
                          />
                        </Link>
                      </li>
                    );
                  })}
              </ul>
            </div>
          ))}
        </section>
        <aside className="flex flex-col gap-3 rounded-xl border border-line bg-white p-[18px]">
          <h2 className="m-0 text-[16px] font-bold">Préférences</h2>
          <table className="w-full border-collapse text-[13px]">
            <thead>
              <tr>
                <th className="text-left font-normal">
                  <span className="sr-only">Type</span>
                </th>
                {CHANNELS.map((c) => (
                  <th key={c} scope="col" className="w-11 text-center text-[11px] font-bold text-muted">
                    {c}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {PREF_ROWS.map((row, i) => (
                <tr key={row}>
                  <th scope="row" className="text-left text-[14px] font-normal">
                    {row}
                  </th>
                  {CHANNELS.map((c, j) => {
                    const key = `${i}-${j}`;
                    const on = !!prefs[key];
                    return (
                      <td key={c} className="text-center">
                        <button
                          type="button"
                          role="checkbox"
                          aria-checked={on}
                          aria-label={`${row} · ${c}`}
                          onClick={() => setPrefs({ ...prefs, [key]: !on })}
                          className="flex h-10 w-11 items-center justify-center"
                        >
                          <CheckIndicator checked={on} />
                        </button>
                      </td>
                    );
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </aside>
      </div>
    </div>
  );
}
