"use client";

import { useState } from "react";
import { cn } from "@/lib/cn";
import { Input, Textarea } from "@/components/ui/Form";
import { Icon } from "@/components/ui/Icon";
import { RemovableChip } from "@/components/ui/Chip";

const DAYS = [
  ["Lu", "Lundi"],
  ["Ma", "Mardi"],
  ["Me", "Mercredi"],
  ["Je", "Jeudi"],
  ["Ve", "Vendredi"],
  ["Sa", "Samedi"],
  ["Di", "Dimanche"],
];

/** Shop profile form: cover, identity, pickup days, delivery zones (W-Shop-Profile). */
export function ShopProfileForm({ name, place, description, initials }: { name: string; place: string; description: string; initials: string }) {
  const [days, setDays] = useState<string[]>(["Me", "Sa"]);
  const [zones, setZones] = useState(["Antsirabe", "Antananarivo", "Ambatolampy"]);
  return (
    <form id="shop-form" className="flex flex-col gap-4" onSubmit={(e) => e.preventDefault()}>
      <section className="overflow-hidden rounded-xl border border-line bg-white">
        <div className="relative flex h-[140px] items-end justify-end bg-mint p-3">
          <button type="button" className="flex h-9 items-center gap-1.5 rounded-full bg-white/95 px-3 text-[13px] font-bold text-ink">
            <Icon name="camera" size={15} />
            Changer la couverture
          </button>
          <span className="absolute -bottom-[34px] left-[22px] flex size-20 items-center justify-center rounded-[22px] border-4 border-white bg-pomme-700 font-display text-[26px] font-extrabold text-white">
            {initials}
          </span>
        </div>
        <div className="flex flex-col gap-3.5 px-5 pt-12 pb-5 md:px-[22px]">
          <div className="grid gap-3.5 md:grid-cols-2">
            <Input label="Nom de la boutique" defaultValue={name} size="sm" controlClassName="h-[46px]" />
            <Input label="Localisation" defaultValue={place} leadingIcon="pin" size="sm" controlClassName="h-[46px]" />
          </div>
          <Textarea label="Présentation" rows={4} defaultValue={description} />
        </div>
      </section>
      <section className="grid gap-6 rounded-xl border border-line bg-white p-5 md:grid-cols-2 md:p-[22px]">
        <fieldset className="m-0 flex flex-col gap-3 border-0 p-0">
          <legend className="mb-3 p-0 text-[17px] font-bold">Retrait sur place</legend>
          <div className="flex flex-wrap gap-1.5">
            {DAYS.map(([short, full]) => {
              const on = days.includes(short!);
              return (
                <button
                  key={short}
                  type="button"
                  aria-pressed={on}
                  aria-label={full}
                  onClick={() => setDays(on ? days.filter((d) => d !== short) : [...days, short!])}
                  className={cn(
                    "size-11 rounded-[11px] border-[1.5px] text-[13px] font-bold",
                    on ? "border-pomme-500 bg-mint text-pomme-800" : "border-line-strong bg-white text-ink",
                  )}
                >
                  {short}
                </button>
              );
            })}
          </div>
          <div className="grid grid-cols-2 gap-2.5">
            <Input label="De" type="time" defaultValue="08:00" size="sm" />
            <Input label="À" type="time" defaultValue="12:00" size="sm" />
          </div>
        </fieldset>
        <fieldset className="m-0 flex flex-col gap-3 border-0 p-0">
          <legend className="mb-3 p-0 text-[17px] font-bold">Livraison</legend>
          <div className="flex flex-wrap gap-2">
            {zones.map((z) => (
              <RemovableChip key={z} onRemove={() => setZones(zones.filter((x) => x !== z))}>
                {z}
              </RemovableChip>
            ))}
            <button type="button" className="h-[34px] rounded-full border-[1.5px] border-dashed border-lime bg-white px-3 text-[13px] font-bold text-pomme-800">
              + Zone
            </button>
          </div>
          <div className="grid grid-cols-2 gap-2.5">
            <Input label="Frais (Ar)" defaultValue="3 000" inputMode="numeric" size="sm" />
            <Input label="Gratuit dès (Ar)" placeholder="[MONTANT]" inputMode="numeric" size="sm" />
          </div>
        </fieldset>
      </section>
    </form>
  );
}
