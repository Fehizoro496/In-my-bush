import type { Metadata } from "next";
import { PageHeader } from "@/components/layout/Container";
import { SellerCard } from "@/components/seller/SellerCard";
import { ShopProfileForm } from "@/components/seller/ShopProfileForm";
import { Button, ButtonLink } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import { getMyShop } from "@/lib/data/seller";
import { initials } from "@/lib/format";

export const metadata: Metadata = { title: "Profil de la boutique" };

export default async function ShopProfilePage() {
  const shop = await getMyShop();
  return (
    <>
      <PageHeader
        title="Profil de la boutique"
        actions={
          <>
            <ButtonLink href={`/vendeurs/${shop.slug}`} variant="neutral" icon="eye" className="px-3.5 text-[14px]">
              Voir la page publique
            </ButtonLink>
            <Button type="submit" form="shop-form" className="text-[14px]">
              Enregistrer
            </Button>
          </>
        }
      />
      <div className="grid items-start gap-5 xl:grid-cols-[minmax(0,1fr)_320px]">
        <ShopProfileForm
          name={shop.name}
          place={`${shop.city}, ${shop.region}`}
          description="Maraîcher à Antsirabe depuis 2019. Légumes de saison cultivés sans intrant chimique, récoltés la veille de la livraison."
          initials={initials(shop.name)}
        />
        <aside className="grid gap-4 md:grid-cols-2 xl:grid-cols-1">
          <div className="flex flex-col gap-2.5">
            <span className="overline text-muted">Aperçu acheteur</span>
            <SellerCard shop={shop} />
          </div>
          <section className="flex flex-col gap-2.5 self-start rounded-[18px] border border-line bg-white p-[18px]">
            <h2 className="m-0 text-[15px] font-bold">Vérifications</h2>
            {[
              { t: "Identité vérifiée", icon: "shield" as const },
              { t: "Téléphone vérifié", icon: "checkCircle" as const },
            ].map((b) => (
              <div key={b.t} className="flex items-center gap-2.5 text-[14px]">
                <Icon name={b.icon} size={18} className="text-pomme-800" />
                <span className="flex-1">{b.t}</span>
                <span className="text-[12px] font-bold text-pomme-800">Validé</span>
              </div>
            ))}
          </section>
        </aside>
      </div>
    </>
  );
}
