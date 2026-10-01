"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { cn } from "@/lib/cn";
import type { ProductSummary } from "@/lib/types";
import { Button } from "@/components/ui/Button";
import { CheckIndicator, Input, Select, Textarea } from "@/components/ui/Form";
import { Icon, type IconName } from "@/components/ui/Icon";
import { Breadcrumb } from "@/components/ui/Navigation";
import { ProductCard } from "@/components/product/ProductCard";
import { useToast } from "@/components/ui/Toast";

export const UNITS = [
  { value: "KG", label: "kg" },
  { value: "PIECE", label: "Pièce" },
  { value: "L", label: "Litre" },
  { value: "BUNCH", label: "Botte" },
  { value: "JAR", label: "Pot" },
  { value: "PACK", label: "Lot / panier" },
  { value: "G", label: "Grammes" },
];

const CATEGORIES = [
  { value: "herbes", label: "Fruits & légumes › Herbes & brèdes" },
  { value: "legumes", label: "Fruits & légumes › Légumes" },
  { value: "fruits", label: "Fruits & légumes › Fruits" },
  { value: "miel", label: "Miel & confitures › Miels crus" },
  { value: "epices", label: "Épicerie › Épices" },
];

const SHIPPING: { key: string; icon: IconName; title: string; detail: string }[] = [
  { key: "home", icon: "truck", title: "Livraison à domicile", detail: "Antananarivo + 30 km · 3 000 Ar" },
  { key: "pick", icon: "store", title: "Retrait sur place", detail: "Antsirabe · mer. et sam." },
  { key: "nat", icon: "package", title: "Expédition nationale", detail: "Transporteur partenaire" },
];

/** "Ajouter un produit" form with live buyer preview and publish checklist (W-Add-Product). */
export function ProductForm() {
  const router = useRouter();
  const toast = useToast();
  const [name, setName] = useState("Brèdes mafana");
  const [price, setPrice] = useState("1000");
  const [unit, setUnit] = useState("BUNCH");
  const [qty, setQty] = useState("40");
  const [threshold, setThreshold] = useState("");
  const [description, setDescription] = useState("");
  const [ship, setShip] = useState<Record<string, boolean>>({ home: true, pick: true, nat: false });

  const unitLabel = UNITS.find((u) => u.value === unit)?.label.toLowerCase() ?? "";
  const preview: ProductSummary = {
    id: "preview",
    slug: "preview",
    name: name || "Nom du produit",
    price: Number(price.replace(/\D/g, "")) || 0,
    compareAtPrice: null,
    unit: "BUNCH",
    unitLabel,
    stock: Number(qty) || 0,
    stockLevel: "OK",
    ratingAvg: 0,
    ratingCount: 0,
    imageUrl: null,
    visual: { tint: "#DDEBC9", ink: "#365A10", icon: "leaf", label: name.split(" ")[0] },
    shop: { id: "me", name: "Le Jardin de Hery", slug: "le-jardin-de-hery", city: "Antsirabe" },
    categorySlug: "fruits-legumes",
  };
  const checks = [
    { ok: true, text: "3 photos ajoutées" },
    { ok: !!name, text: "Nom et catégorie" },
    { ok: description.length > 20 ? true : null, text: description.length > 20 ? "Description complète" : "Description à compléter" },
    { ok: threshold ? true : false, text: threshold ? "Seuil d’alerte" : "Seuil d’alerte manquant" },
    { ok: Object.values(ship).some(Boolean), text: "Mode de livraison" },
  ];
  const submit = (draft: boolean) => {
    // TODO(api): sellerApi.createProduct(...) then sellerApi.submitProduct(id) when publishing.
    toast.show({
      title: draft ? "Brouillon enregistré" : "Produit envoyé en validation",
      description: draft ? name : "L’équipe In my bush le relit sous 24 h.",
    });
    if (!draft) router.push("/vendre/produits");
  };

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div className="flex flex-col gap-1.5">
          <Breadcrumb items={[{ label: "Mes produits", href: "/vendre/produits" }, { label: "Nouveau produit" }]} />
          <h1 className="m-0 font-display text-[28px] font-extrabold tracking-[-0.025em] md:text-[36px]">Ajouter un produit</h1>
        </div>
        <div className="flex gap-2.5">
          <Button variant="neutral" className="px-4 text-[14px]" onClick={() => submit(true)}>
            Enregistrer le brouillon
          </Button>
          <Button className="text-[14px]" type="submit" form="product-form">
            Publier
          </Button>
        </div>
      </div>

      <div className="grid items-start gap-6 xl:grid-cols-[minmax(0,1fr)_320px]">
        <form
          id="product-form"
          className="flex flex-col gap-[18px]"
          onSubmit={(e) => {
            e.preventDefault();
            submit(false);
          }}
        >
          <section className="flex flex-col gap-3.5 rounded-xl border border-line bg-white p-5 md:p-[22px]">
            <div className="flex flex-wrap items-baseline justify-between gap-2">
              <h2 className="m-0 text-[18px] font-bold">Photos</h2>
              <span className="text-[13px] text-muted">3 / 8 · JPG ou PNG, 5 Mo max</span>
            </div>
            <div className="grid grid-cols-3 gap-2.5 md:grid-cols-5">
              <div className="relative col-span-3 row-span-2 flex min-h-[200px] items-center justify-center rounded-[14px] bg-pomme-200 text-pomme-800 md:col-span-2 md:min-h-[220px]">
                <span className="flex opacity-55">
                  <Icon name="leaf" size={56} />
                </span>
                <span className="absolute top-2.5 left-2.5 rounded-[6px] bg-ink px-2 py-[3px] text-[11px] font-extrabold text-white">Principale</span>
              </div>
              <div className="flex aspect-square items-center justify-center rounded-[14px] bg-mint text-pomme-800">
                <Icon name="leaf" size={26} />
              </div>
              <div className="flex aspect-square items-center justify-center rounded-[14px] bg-pomme-100 text-pomme-800">
                <Icon name="sprout" size={26} />
              </div>
              <div className="flex aspect-square flex-col items-center justify-center gap-2 rounded-[14px] bg-sand p-3" role="progressbar" aria-valuenow={64} aria-valuemin={0} aria-valuemax={100} aria-label="Envoi de la photo">
                <span className="text-[11px] font-bold text-body">Envoi… 64 %</span>
                <span className="h-1 w-full overflow-hidden rounded bg-line-strong">
                  <span className="block h-full w-[64%] bg-pomme-500" />
                </span>
              </div>
              <label className="col-span-3 flex min-h-[100px] cursor-pointer items-center justify-center gap-2.5 rounded-[14px] border-[1.5px] border-dashed border-lime bg-pomme-50 px-3 text-center text-[14px] font-bold text-pomme-800">
                <Icon name="upload" size={22} />
                <span>
                  Glissez vos photos ici ou <u>parcourez</u>
                </span>
                <input type="file" accept="image/jpeg,image/png" multiple className="sr-only" />
              </label>
            </div>
          </section>

          <section className="flex flex-col gap-3.5 rounded-xl border border-line bg-white p-5 md:p-[22px]">
            <h2 className="m-0 text-[18px] font-bold">Informations</h2>
            <div className="grid gap-3.5 md:grid-cols-2">
              <Input label="Nom du produit" value={name} onChange={(e) => setName(e.target.value)} required maxLength={60} controlClassName="h-[46px]" />
              <Select label="Catégorie" options={CATEGORIES} defaultValue="herbes" className="h-[46px]" />
            </div>
            <Textarea
              label="Description"
              rows={4}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              maxLength={600}
              counter={`${description.length} / 600`}
              placeholder="Variété, mode de culture, goût, conseils de préparation…"
            />
          </section>

          <section className="flex flex-col gap-3.5 rounded-xl border border-line bg-white p-5 md:p-[22px]">
            <h2 className="m-0 text-[18px] font-bold">Prix &amp; stock</h2>
            <div className="grid grid-cols-2 gap-3.5 md:grid-cols-4">
              <Input label="Prix (Ar)" inputMode="numeric" value={price} onChange={(e) => setPrice(e.target.value)} required controlClassName="h-[46px]" help="Commission : [TAUX]" />
              <Select label="Unité" options={UNITS} value={unit} onChange={(e) => setUnit(e.target.value)} className="h-[46px]" />
              <Input label="Quantité dispo." inputMode="numeric" value={qty} onChange={(e) => setQty(e.target.value)} controlClassName="h-[46px]" />
              <Input
                label="Alerte à"
                inputMode="numeric"
                placeholder="0"
                value={threshold}
                onChange={(e) => setThreshold(e.target.value)}
                error={threshold ? undefined : "Indiquez un seuil"}
                controlClassName="h-[46px]"
              />
            </div>
          </section>

          <section className="flex flex-col gap-3.5 rounded-xl border border-line bg-white p-5 md:p-[22px]">
            <h2 className="m-0 text-[18px] font-bold">Origine</h2>
            <Input label="Lieu de production" leadingIcon="pin" defaultValue="Antsirabe, Vakinankaratra" controlClassName="h-[46px]" />
          </section>

          <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-5 md:p-[22px]">
            <h2 className="m-0 text-[18px] font-bold">Livraison &amp; localisation</h2>
            <div className="grid gap-3 md:grid-cols-3">
              {SHIPPING.map((s) => {
                const on = !!ship[s.key];
                return (
                  <button
                    key={s.key}
                    type="button"
                    role="checkbox"
                    aria-checked={on}
                    onClick={() => setShip({ ...ship, [s.key]: !on })}
                    className={cn(
                      "flex flex-col gap-2 rounded-[14px] border-[1.5px] p-3.5 text-left text-ink",
                      on ? "border-pomme-500 bg-pomme-50" : "border-line-strong bg-white",
                    )}
                  >
                    <span className="flex w-full justify-between">
                      <Icon name={s.icon} size={20} className="text-pomme-700" />
                      <CheckIndicator checked={on} />
                    </span>
                    <b className="text-[14px]">{s.title}</b>
                    <span className="text-[12px] leading-[17px] text-muted">{s.detail}</span>
                  </button>
                );
              })}
            </div>
          </section>
        </form>

        <aside className="flex flex-col gap-4 xl:sticky xl:top-6">
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-1">
            <div className="flex flex-col gap-2.5">
              <span className="overline text-muted">Aperçu acheteur</span>
              <ProductCard product={preview} href="#" className="max-w-[320px]" />
            </div>
            <div className="flex flex-col gap-3 self-start rounded-[18px] border border-line bg-white p-[18px]">
              <b className="text-[15px]">Prêt à publier ?</b>
              <ul className="m-0 flex list-none flex-col gap-3 p-0">
                {checks.map((c) => (
                  <li key={c.text} className="flex items-center gap-2.5 text-[14px]">
                    <span
                      className={cn(
                        "flex size-[22px] items-center justify-center rounded-full",
                        c.ok === true ? "bg-pomme-500 text-on-primary" : c.ok === null ? "bg-fog text-muted" : "bg-[#FCEBE9] text-danger-fg",
                      )}
                    >
                      <Icon name={c.ok === true ? "check" : c.ok === null ? "minus" : "x"} size={13} />
                    </span>
                    <span className={c.ok === true ? "text-ink" : c.ok === null ? "text-muted" : "text-danger-ink"}>{c.text}</span>
                  </li>
                ))}
              </ul>
              <span className="border-t border-divider pt-1.5 text-[12px] leading-[17px] text-muted">
                Chaque nouveau produit est relu par l’équipe In my bush avant sa mise en ligne (sous 24 h).
              </span>
            </div>
          </div>
        </aside>
      </div>
    </div>
  );
}
