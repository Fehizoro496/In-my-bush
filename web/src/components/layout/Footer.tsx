import Link from "next/link";
import { Logo } from "./Logo";
import { ROUTES, withQuery } from "@/lib/routing/routes";

const COLUMNS: { title: string; links: { label: string; href: string }[] }[] = [
  {
    title: "Acheter",
    links: [
      { label: "Catalogue", href: ROUTES.catalogue },
      { label: "Promotions", href: withQuery(ROUTES.catalogue, { tri: "pertinence", promo: "1" }) },
      { label: "Producteurs", href: ROUTES.categories },
      { label: "Près de chez vous", href: withQuery(ROUTES.catalogue, { categorie: "produits-locaux" }) },
    ],
  },
  {
    title: "Vendre",
    links: [
      { label: "Ouvrir ma boutique", href: ROUTES.sellerOnboarding },
      { label: "Tarifs & commission", href: `${ROUTES.sellerOnboarding}#tarifs` },
      { label: "Livraison & retrait", href: ROUTES.sellerShop },
      { label: "Guide vendeur", href: ROUTES.seller },
    ],
  },
  {
    title: "Aide",
    links: [
      { label: "Livraison", href: ROUTES.helpDelivery },
      { label: "Paiement", href: ROUTES.helpPayment },
      { label: "Retours", href: ROUTES.helpReturns },
      { label: "Contact", href: ROUTES.helpContact },
    ],
  },
  {
    title: "In my bush",
    links: [
      { label: "À propos", href: ROUTES.about },
      { label: "Charte bio", href: ROUTES.charter },
      { label: "Presse", href: ROUTES.press },
      { label: "Carrières", href: ROUTES.careers },
    ],
  },
];

export function Footer() {
  return (
    <footer className="mt-12 bg-ink px-4 pt-12 pb-28 text-[#D9DDD0] md:mt-[72px] md:px-8 md:pt-14 md:pb-10 xl:px-20">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10">
        <div className="grid grid-cols-2 gap-8 md:grid-cols-3 lg:grid-cols-[minmax(0,1.5fr)_repeat(4,minmax(0,1fr))] lg:gap-10">
          <div className="col-span-2 flex flex-col gap-3.5 md:col-span-3 lg:col-span-1">
            <Logo tone="dark" />
            <span className="max-w-[280px] text-[14px] leading-[21px] text-[#A9AE9E]">
              La marketplace des producteurs bio et locaux.
            </span>
          </div>
          {COLUMNS.map((col) => (
            <nav key={col.title} aria-label={col.title} className="flex flex-col gap-2.5">
              <b className="text-[14px] text-white">{col.title}</b>
              {col.links.map((l) => (
                <Link key={l.label} href={l.href} className="py-0.5 text-[14px] text-[#C5CABB] no-underline hover:text-white">
                  {l.label}
                </Link>
              ))}
            </nav>
          ))}
        </div>
        <div className="flex flex-wrap justify-between gap-2 border-t border-white/10 pt-5 text-[13px] text-[#A9AE9E]">
          <span>© 2026 In my bush</span>
          <span>Mentions légales · Confidentialité · CGV</span>
        </div>
      </div>
    </footer>
  );
}
