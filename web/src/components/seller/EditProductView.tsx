"use client";

import { useState } from "react";
import type { Visual } from "@/lib/types";
import { Button, ButtonLink } from "@/components/ui/Button";
import { Input, Select, Textarea } from "@/components/ui/Form";
import { Icon } from "@/components/ui/Icon";
import { PhotoPlaceholder } from "@/components/ui/Media";
import { Modal } from "@/components/ui/Modal";
import { Breadcrumb } from "@/components/ui/Navigation";
import { Switch } from "@/components/ui/Switch";
import { TabList } from "@/components/ui/Tabs";
import { useToast } from "@/components/ui/Toast";
import { UNITS } from "./ProductForm";
import { routeService } from "@/lib/routing/route.service";
import { ROUTES } from "@/lib/routing/routes";

export interface EditableProduct {
  id: string;
  name: string;
  since: string;
  visual: Visual;
  price: string;
  unit: string;
  stock: string;
  threshold: string;
  description: string;
  photos: string[];
  stats: { value: string; label: string }[];
  pendingOrders: number;
  origin: string;
}

type Tab = "info" | "price" | "origin" | "delivery";

/** Edit product: tabs, promotion, visibility, delete confirmation (W-Edit-Product). */
export function EditProductView({ product }: { product: EditableProduct }) {
  const toast = useToast();
  const [tab, setTab] = useState<Tab>("price");
  const [promo, setPromo] = useState(true);
  const [confirm, setConfirm] = useState(false);

  const priceBlock = (
    <section className="flex flex-col gap-3.5 rounded-xl border border-line bg-white p-5 md:p-[22px]">
      <h2 className="m-0 text-[17px] font-bold">Prix &amp; stock</h2>
      <div className="grid grid-cols-2 gap-3.5 md:grid-cols-4">
        <Input label="Prix (Ar)" defaultValue={product.price} inputMode="numeric" size="sm" controlClassName="h-[46px]" />
        <Select label="Unité" defaultValue={product.unit} options={UNITS} className="h-[46px]" />
        <Input label="Stock" defaultValue={product.stock} inputMode="numeric" size="sm" controlClassName="h-[46px]" />
        <Input label="Alerte à" defaultValue={product.threshold} inputMode="numeric" size="sm" controlClassName="h-[46px]" />
      </div>
      <div className="flex items-center gap-3 rounded-md bg-sand px-3.5 py-1 text-[14px] text-body">
        <Icon name="percent" size={17} />
        <span className="flex-1">Lancer une promotion sur ce produit</span>
        <Switch label="Activer la promotion" tone="orange" checked={promo} onChange={setPromo} />
      </div>
      {promo && (
        <div className="grid gap-3.5 sm:grid-cols-3">
          <Input label="Réduction" defaultValue="−20 %" size="sm" controlClassName="h-[46px] border-[#F7AA5A]" />
          <Input label="Du" type="date" defaultValue="2026-09-30" size="sm" controlClassName="h-[46px]" />
          <Input label="Au" type="date" defaultValue="2026-10-06" size="sm" controlClassName="h-[46px]" />
        </div>
      )}
    </section>
  );

  const infoBlock = (
    <section className="flex flex-col gap-3.5 rounded-xl border border-line bg-white p-5 md:p-[22px]">
      <h2 className="m-0 text-[17px] font-bold">Description</h2>
      <Textarea aria-label="Description" rows={4} defaultValue={product.description} />
      <div className="flex flex-wrap gap-2.5">
        {product.photos.map((c, i) => (
          <span key={c + i} role="img" aria-label={`Photo ${i + 1}`} className="size-[84px] rounded-md" style={{ background: c }} />
        ))}
        <button
          type="button"
          aria-label="Ajouter une photo"
          className="flex size-[84px] items-center justify-center rounded-md border-[1.5px] border-dashed border-lime bg-pomme-50 text-pomme-800"
        >
          <Icon name="plus" size={22} />
        </button>
      </div>
    </section>
  );

  return (
    <div className="flex flex-col gap-[18px]">
      <Breadcrumb items={[{ label: "Mes produits", href: ROUTES.sellerProducts }, { label: product.name }]} />
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3.5">
          <PhotoPlaceholder visual={product.visual} iconSize={28} className="size-16" />
          <div className="flex flex-col gap-1">
            <h1 className="m-0 font-display text-[26px] font-extrabold tracking-[-0.02em] md:text-[32px]">{product.name}</h1>
            <span className="self-start rounded-full bg-success-bg px-2.5 py-[3px] text-[12px] font-bold text-success-fg">{product.since}</span>
          </div>
        </div>
        <div className="flex gap-2.5">
          <ButtonLink href={ROUTES.product("bredes-mafana")} variant="neutral" icon="eye" className="px-3.5 text-[14px]">
            Voir la fiche
          </ButtonLink>
          <Button
            className="text-[14px]"
            onClick={() => {
              toast.show({ title: "Modifications enregistrées", description: product.name });
              routeService.toSellerProducts();
            }}
          >
            Enregistrer
          </Button>
        </div>
      </div>
      <TabList
        label="Sections du produit"
        value={tab}
        onChange={setTab}
        items={[
          { value: "info", label: "Informations" },
          { value: "price", label: "Prix & stock" },
          { value: "origin", label: "Origine" },
          { value: "delivery", label: "Livraison" },
        ]}
      />
      <div className="grid items-start gap-5 xl:grid-cols-[minmax(0,1fr)_300px]">
        <div role="tabpanel" className="flex flex-col gap-4">
          {tab === "price" && (
            <>
              {priceBlock}
              {infoBlock}
            </>
          )}
          {tab === "info" && (
            <>
              <section className="flex flex-col gap-3.5 rounded-xl border border-line bg-white p-5 md:p-[22px]">
                <h2 className="m-0 text-[17px] font-bold">Informations</h2>
                <Input label="Nom du produit" defaultValue={product.name} controlClassName="h-[46px]" />
              </section>
              {infoBlock}
            </>
          )}
          {tab === "origin" && (
            <section className="flex flex-col gap-3.5 rounded-xl border border-line bg-white p-5 md:p-[22px]">
              <h2 className="m-0 text-[17px] font-bold">Origine</h2>
              <Input label="Lieu de production" leadingIcon="pin" defaultValue={product.origin} controlClassName="h-[46px]" />
            </section>
          )}
          {tab === "delivery" && (
            <section className="flex flex-col gap-1 rounded-xl border border-line bg-white p-5 md:p-[22px]">
              <h2 className="m-0 mb-2 text-[17px] font-bold">Livraison</h2>
              <Switch showLabel defaultChecked label="Livraison à domicile" description="Antananarivo + 30 km · 3 000 Ar" />
              <Switch showLabel defaultChecked label="Retrait sur place" description="Antsirabe · mer. et sam." />
              <Switch showLabel label="Expédition nationale" description="Transporteur partenaire" />
            </section>
          )}
        </div>
        <aside className="grid gap-4 md:grid-cols-2 xl:grid-cols-1">
          <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-[18px]">
            <h2 className="m-0 text-[15px] font-bold">Performance · 30 j</h2>
            <dl className="m-0 grid grid-cols-2 gap-2.5">
              {product.stats.map((s) => (
                <div key={s.label} className="flex flex-col-reverse rounded-md bg-bg px-3 py-2.5">
                  <dt className="text-[12px] text-muted">{s.label}</dt>
                  <dd className="m-0 font-display text-[20px] font-bold">{s.value}</dd>
                </div>
              ))}
            </dl>
          </section>
          <section className="flex flex-col gap-2.5 self-start rounded-xl border border-line bg-white p-[18px]">
            <Switch showLabel defaultChecked label="Visible sur la marketplace" />
            <Button variant="danger-outline" icon="trash" className="h-[42px] text-[14px]" onClick={() => setConfirm(true)}>
              Supprimer le produit
            </Button>
          </section>
        </aside>
      </div>
      <Modal
        open={confirm}
        onClose={() => setConfirm(false)}
        icon="trash"
        width={480}
        title={`Supprimer « ${product.name} » ?`}
        description={`Le produit disparaît de la marketplace. Les ${product.pendingOrders} commandes en cours restent à honorer. Vous pouvez plutôt le masquer.`}
        footer={
          <>
            <Button variant="neutral" className="text-[14px]" onClick={() => setConfirm(false)}>
              Masquer plutôt
            </Button>
            <Button
              variant="danger"
              className="text-[14px]"
              onClick={() => {
                setConfirm(false);
                toast.show({ tone: "info", title: "Produit supprimé", description: product.name });
                routeService.toSellerProducts();
              }}
            >
              Supprimer
            </Button>
          </>
        }
      />
    </div>
  );
}
