"use client";

import { useState } from "react";
import { cn } from "@/lib/cn";
import type { ShopSummary } from "@/lib/types";
import { Button, ButtonLink } from "@/components/ui/Button";
import { FilterChip } from "@/components/ui/Chip";
import { Input, Textarea } from "@/components/ui/Form";
import { Icon } from "@/components/ui/Icon";
import { SellerCard } from "./SellerCard";

const STEPS = [
  { title: "Votre boutique", detail: "Nom, activité, présentation" },
  { title: "Vérification", detail: "Identité et exploitation" },
  { title: "C’est prêt", detail: "Premier produit" },
];
const KINDS = ["Maraîchage", "Fruits", "Apiculture", "Élevage & laitiers", "Transformation", "Artisanat", "Cosmétiques"];

/** 3-step "Ouvrir ma boutique" onboarding (W-Become-Seller). */
export function BecomeSellerWizard() {
  const [step, setStep] = useState(1);
  const [name, setName] = useState("Le Jardin de Hery");
  const [kinds, setKinds] = useState<string[]>(["Maraîchage", "Fruits"]);
  const [place, setPlace] = useState("Antsirabe, Vakinankaratra");
  const slug = name
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
  const preview: ShopSummary = {
    id: "preview",
    slug,
    name: name || "Ma boutique",
    city: place.split(",")[0] ?? place,
    region: place.split(",")[1]?.trim() ?? "",
    logoUrl: null,
    coverUrl: null,
    ratingAvg: 0,
    ratingCount: 0,
    productCount: 0,
    createdAt: "2026-09-30T00:00:00+03:00",
    verified: false,
    tags: kinds.slice(0, 3),
    avatarColor: "#4A7A12",
    cover: { tint: "#E6F3CC", ink: "#365A10" },
  };

  return (
    <div className="grid items-start gap-6 lg:grid-cols-[240px_minmax(0,1fr)] lg:gap-8 xl:grid-cols-[260px_minmax(0,1fr)_320px]">
      <aside className="flex flex-col gap-5">
        <div className="flex flex-col gap-1.5">
          <span className="overline text-[13px] text-pomme-700">Espace vendeur</span>
          <h1 className="m-0 font-display text-[30px] leading-[1.05] font-extrabold tracking-[-0.025em] lg:text-[32px]">Ouvrir ma boutique</h1>
        </div>
        <ol className="m-0 flex list-none gap-2 p-0 lg:flex-col lg:gap-0">
          {STEPS.map((s, i) => {
            const n = i + 1;
            const done = n < step;
            const cur = n === step;
            return (
              <li key={s.title} className="flex flex-1 gap-3" aria-current={cur ? "step" : undefined}>
                <div className="flex flex-col items-center">
                  <span
                    className={cn(
                      "flex size-8 shrink-0 items-center justify-center rounded-full text-[13px] font-extrabold",
                      done ? "bg-pomme-500 text-on-primary" : cur ? "bg-ink text-white" : "bg-fog text-muted",
                    )}
                  >
                    {done ? <Icon name="check" size={14} /> : n}
                  </span>
                  {i < STEPS.length - 1 && <span className={cn("hidden min-h-7 w-0.5 flex-1 lg:block", done ? "bg-pomme-500" : "bg-line-strong")} />}
                </div>
                <div className="flex flex-col gap-0.5 pt-1 lg:pb-[18px]">
                  <b className={cn("text-[14px] lg:text-[15px]", n <= step ? "text-ink" : "text-muted")}>{s.title}</b>
                  <span className="hidden text-[13px] text-muted sm:block">{s.detail}</span>
                </div>
              </li>
            );
          })}
        </ol>
        <div className="hidden gap-2.5 rounded-[14px] bg-pomme-100 p-3.5 text-[13px] leading-[19px] text-[#22380A] lg:flex">
          <Icon name="user" size={18} className="text-pomme-700" />
          <span>Même compte : vos achats, favoris et messages restent là.</span>
        </div>
      </aside>

      <section className="flex flex-col gap-[18px] rounded-[24px] border border-line bg-white p-5 md:p-7">
        {step === 1 && (
          <div className="flex flex-col gap-[18px]">
            <h2 className="m-0 text-[22px] font-bold">Votre boutique</h2>
            <div className="grid items-center gap-5 sm:grid-cols-[120px_minmax(0,1fr)]">
              <button
                type="button"
                className="flex size-[120px] flex-col items-center justify-center gap-1.5 rounded-[28px] border-[1.5px] border-dashed border-lime bg-pomme-50 text-[12px] font-bold text-pomme-800"
              >
                <Icon name="camera" size={26} />
                Logo ou photo
              </button>
              <Input
                label="Nom de la boutique"
                value={name}
                onChange={(e) => setName(e.target.value)}
                success={name ? `Disponible · inmybush.mg/${slug}` : undefined}
                required
              />
            </div>
            <fieldset className="m-0 flex flex-col gap-2 border-0 p-0">
              <legend className="mb-2 p-0 text-[14px] font-semibold">Ce que vous produisez</legend>
              <div className="flex flex-wrap gap-2">
                {KINDS.map((k) => (
                  <FilterChip key={k} selected={kinds.includes(k)} onToggle={(on) => setKinds(on ? [...kinds, k] : kinds.filter((x) => x !== k))}>
                    {k}
                  </FilterChip>
                ))}
              </div>
            </fieldset>
            <div className="grid gap-3.5 md:grid-cols-2">
              <Input label="Lieu de production" value={place} onChange={(e) => setPlace(e.target.value)} leadingIcon="pin" />
              <Input label="Téléphone boutique" type="tel" defaultValue="+261 34 •• ••• 12" />
            </div>
            <Textarea label="Présentation" rows={4} placeholder="Votre histoire, vos méthodes de culture, ce qui rend vos produits uniques…" />
          </div>
        )}
        {step === 2 && (
          <div className="flex flex-col gap-3.5">
            <h2 className="m-0 text-[22px] font-bold">Vérification</h2>
            {[
              { t: "Pièce d’identité", d: "CIN ou passeport · recto verso", icon: "user" as const },
              { t: "Photos de l’exploitation", d: "2 à 5 photos de vos cultures ou de votre atelier", icon: "camera" as const },
            ].map((d) => (
              <div key={d.t} className="flex flex-wrap items-center gap-3.5 rounded-[14px] border border-line px-4 py-3.5">
                <span className="flex size-11 items-center justify-center rounded-md bg-pomme-100 text-pomme-700">
                  <Icon name={d.icon} size={20} />
                </span>
                <span className="flex min-w-0 flex-1 flex-col">
                  <b className="text-[15px]">{d.t}</b>
                  <span className="text-[13px] text-muted">{d.d}</span>
                </span>
                <Button variant="neutral" size="sm" icon="upload" className="h-10 rounded-[10px] text-[13px]">
                  Importer
                </Button>
              </div>
            ))}
          </div>
        )}
        {step === 3 && (
          <div className="flex flex-col items-start gap-3.5">
            <span className="flex size-[72px] items-center justify-center rounded-full bg-pomme-500 text-on-primary">
              <Icon name="store" size={34} />
            </span>
            <h2 className="m-0 font-display text-[30px] font-extrabold">Votre boutique est prête !</h2>
            <p className="m-0 text-[16px] leading-6 text-body">
              Ajoutez votre premier produit. Il sera relu par l’équipe In my bush sous 24 h avant sa mise en ligne.
            </p>
            <div className="flex flex-wrap gap-2.5">
              <ButtonLink href="/vendre/produits/nouveau" icon="plus" size="lg" className="px-[22px]">
                Ajouter un produit
              </ButtonLink>
              <ButtonLink href="/vendre" variant="neutral" size="lg" className="px-[22px]">
                Mon tableau de bord
              </ButtonLink>
            </div>
          </div>
        )}
        {step < 3 && (
          <div className="flex justify-between border-t border-divider pt-4">
            <Button variant="neutral" size="md" className="h-12 rounded-md px-[18px]" onClick={() => setStep(Math.max(1, step - 1))} disabled={step === 1}>
              Retour
            </Button>
            <Button size="md" iconRight="arrowR" className="h-12 rounded-md px-6" onClick={() => setStep(step + 1)}>
              Continuer
            </Button>
          </div>
        )}
      </section>

      <aside className="flex flex-col gap-3 lg:col-span-2 xl:col-span-1">
        <span className="overline text-muted">Aperçu public</span>
        <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-1">
          <SellerCard shop={preview} href="#" />
          <div id="tarifs" className="flex flex-col gap-2.5 rounded-lg border border-line bg-white p-4 text-[13px] text-body">
            <b className="text-[14px] text-ink">Vendre sur In my bush</b>
            {["Inscription gratuite, commission de [TAUX] par vente", "Versement chaque semaine sur Mobile Money", "Vous choisissez livraison et/ou retrait"].map((t) => (
              <span key={t} className="flex gap-2">
                <Icon name="check" size={15} className="text-pomme-700" />
                {t}
              </span>
            ))}
          </div>
        </div>
      </aside>
    </div>
  );
}
