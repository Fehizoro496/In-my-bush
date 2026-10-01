"use client";

import { useState } from "react";
import { cn } from "@/lib/cn";
import type { Address } from "@/lib/types";
import { Button } from "@/components/ui/Button";
import { ChipGroup } from "@/components/ui/Chip";
import { Input } from "@/components/ui/Form";
import { Icon } from "@/components/ui/Icon";

/** Address cards + "Nouvelle adresse" form with map (W-Addresses). */
export function AddressesView({ addresses }: { addresses: Address[] }) {
  const [list, setList] = useState(addresses);
  const [def, setDef] = useState(addresses.find((a) => a.isDefault)?.id);
  return (
    <div className="flex flex-col gap-5">
      <h1 className="m-0 font-display text-[28px] font-extrabold tracking-[-0.025em] md:text-[36px]">Mes adresses</h1>
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        {list.map((a) => {
          const isDef = a.id === def;
          return (
            <article key={a.id} className={cn("flex flex-col gap-2.5 rounded-[18px] bg-white p-[18px]", isDef ? "border-[1.5px] border-pomme-500" : "border border-line")}>
              <div className="flex items-center gap-2.5">
                <span className="flex size-[38px] items-center justify-center rounded-[11px] bg-pomme-100 text-pomme-700">
                  <Icon name={a.label === "Bureau" ? "store" : "home"} size={19} />
                </span>
                <b className="flex-1 text-[16px]">{a.label}</b>
                {isDef && <span className="inline-flex h-6 items-center rounded-[6px] bg-mint px-2 text-[12px] font-bold text-pomme-800">Par défaut</span>}
              </div>
              <address className="flex-1 text-[14px] leading-[21px] text-text-soft not-italic">
                {a.recipient} · {a.phone}
                <br />
                {a.line1}, {a.district}, {a.city}
                <br />
                <span className="text-muted">Repère : {a.landmark}</span>
              </address>
              <div className="flex items-center gap-2 border-t border-divider pt-2.5">
                <Button variant="neutral" size="sm" className="rounded-[9px] px-3 text-[13px]">
                  Modifier
                </Button>
                {!isDef && (
                  <Button variant="soft" size="sm" className="rounded-[9px] px-3 text-[13px]" onClick={() => setDef(a.id)}>
                    Définir par défaut
                  </Button>
                )}
                <span className="flex-1" />
                <button
                  type="button"
                  aria-label={`Supprimer l’adresse ${a.label}`}
                  onClick={() => setList(list.filter((x) => x.id !== a.id))}
                  className="flex size-9 items-center justify-center rounded-[9px] text-danger-fg hover:bg-danger-bg"
                >
                  <Icon name="trash" size={16} />
                </button>
              </div>
            </article>
          );
        })}
        <a
          href="#nouvelle-adresse"
          className="flex min-h-[200px] flex-col items-center justify-center gap-2 rounded-[18px] border-[1.5px] border-dashed border-lime bg-pomme-50 text-[15px] font-bold text-pomme-800 no-underline hover:text-pomme-800"
        >
          <span className="flex size-11 items-center justify-center rounded-full bg-pomme-500 text-on-primary">
            <Icon name="plus" size={22} />
          </span>
          Ajouter une adresse
        </a>
      </div>
      <section id="nouvelle-adresse" className="grid scroll-mt-6 overflow-hidden rounded-xl border border-line bg-white lg:grid-cols-[minmax(0,1fr)_340px]">
        <form className="flex flex-col gap-3.5 p-5 md:p-[22px]" onSubmit={(e) => e.preventDefault()}>
          <h2 className="m-0 text-[18px] font-bold">Nouvelle adresse</h2>
          <ChipGroup
            label="Type d’adresse"
            variant="mint"
            defaultValue="Autre"
            options={["Domicile", "Bureau", "Autre"].map((t) => ({ value: t, label: t }))}
          />
          <div className="grid gap-3 sm:grid-cols-2">
            <Input label="Destinataire" placeholder="Nom complet" autoComplete="name" size="sm" controlClassName="h-11" />
            <Input label="Téléphone" type="tel" placeholder="+261 34 00 000 00" autoComplete="tel" size="sm" controlClassName="h-11" />
            <Input label="Adresse" placeholder="Lot, rue" wrapperClassName="sm:col-span-2" autoComplete="address-line1" size="sm" controlClassName="h-11" />
            <Input label="Quartier" placeholder="Ex. : Ambohijatovo" size="sm" controlClassName="h-11" />
            <Input label="Ville" placeholder="Antananarivo" autoComplete="address-level2" size="sm" controlClassName="h-11" />
            <Input label="Repère pour le livreur" placeholder="Ex. : maison jaune après la pharmacie" wrapperClassName="sm:col-span-2" size="sm" controlClassName="h-11" />
          </div>
          <div className="flex justify-end gap-2.5">
            <Button variant="neutral" className="text-[14px]">
              Annuler
            </Button>
            <Button type="submit" className="text-[14px]">
              Enregistrer
            </Button>
          </div>
        </form>
        <div className="relative min-h-[240px] overflow-hidden bg-[#EEF3E4] lg:min-h-[320px]">
          <span className="absolute top-[150px] -left-5 h-3 w-[420px] -rotate-10 bg-white" />
          <span className="absolute -top-5 left-[140px] h-[400px] w-3 rotate-[14deg] bg-white" />
          <span className="absolute top-[120px] left-[150px] size-9 -rotate-45 rounded-[999px_999px_999px_4px] bg-pomme-700 shadow-[0_4px_10px_rgba(31,35,24,0.2)]" />
          <button
            type="button"
            className="absolute inset-x-4 bottom-4 flex h-[42px] items-center justify-center gap-1.5 rounded-[10px] bg-white text-[14px] font-bold text-info-fg shadow-[0_2px_8px_rgba(31,35,24,0.12)]"
          >
            <Icon name="pin" size={16} />
            Utiliser ma position
          </button>
        </div>
      </section>
    </div>
  );
}
