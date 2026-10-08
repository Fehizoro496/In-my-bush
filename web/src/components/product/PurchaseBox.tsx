"use client";

import Link from "next/link";
import { useState } from "react";
import { cn } from "@/lib/cn";
import { formatAriary } from "@/lib/format";
import { Icon } from "@/components/ui/Icon";
import { QuantityStepper } from "@/components/ui/QuantityStepper";
import { Button } from "@/components/ui/Button";
import { useToast } from "@/components/ui/Toast";
import { routeService } from "@/lib/routing/route.service";
import { ROUTES } from "@/lib/routing/routes";

/** Quantity + "Ajouter au panier" + favourite + "Acheter maintenant" (W-Product). */
export function PurchaseBox({
  name,
  price,
  unitLabel,
  stock,
  out,
}: {
  name: string;
  price: number;
  unitLabel: string;
  stock: number;
  out: boolean;
}) {
  const [qty, setQty] = useState(1);
  const [added, setAdded] = useState(false);
  const [fav, setFav] = useState(false);
  const toast = useToast();

  if (out) {
    return (
      <div className="flex flex-col gap-3">
        <Button
          variant="dark"
          size="lg"
          icon="bell"
          className="h-[52px]"
          onClick={() => toast.show({ tone: "info", title: "Alerte activée", description: `Nous vous prévenons dès le retour de « ${name} ».` })}
        >
          M’alerter du retour
        </Button>
        <Button size="lg" disabled>
          Ajouter au panier
        </Button>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-stretch gap-3">
        <QuantityStepper size="lg" value={qty} onChange={setQty} max={stock} />
        <button
          type="button"
          onClick={() => {
            setAdded(!added);
            if (!added) toast.show({ title: "Ajouté au panier", description: `${name} · ${qty} ${unitLabel}`, action: { label: "Voir", onClick: () => routeService.toCart() } });
          }}
          className={cn(
            "flex h-14 flex-1 items-center justify-center gap-2 rounded-md text-[16px] font-bold transition-colors",
            added ? "bg-pomme-700 text-white" : "bg-pomme-500 text-on-primary hover:bg-[#7DB834]",
          )}
        >
          <Icon name={added ? "check" : "cart"} size={20} />
          <span className="hidden sm:inline">{added ? "Ajouté au panier" : "Ajouter au panier"}</span>
          <span className="sm:hidden">{added ? "Ajouté" : "Ajouter"}</span>
        </button>
        <button
          type="button"
          aria-label={fav ? "Retirer des favoris" : "Ajouter aux favoris"}
          aria-pressed={fav}
          onClick={() => setFav(!fav)}
          className={cn(
            "flex size-14 shrink-0 items-center justify-center rounded-md border-[1.5px] border-line-strong bg-white",
            fav ? "text-orange-600" : "text-ink",
          )}
        >
          <Icon name={fav ? "heartF" : "heart"} size={22} />
        </button>
      </div>
      <Link
        href={ROUTES.checkout}
        className="flex h-14 items-center justify-center rounded-md border-[1.5px] border-ink text-[16px] font-bold text-ink no-underline hover:bg-ink hover:text-white"
      >
        Acheter maintenant · {formatAriary(price * qty)}
      </Link>
    </div>
  );
}
