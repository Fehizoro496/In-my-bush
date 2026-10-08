import Link from "next/link";
import { Container, SectionHeader } from "@/components/layout/Container";
import { ProductRails } from "@/components/home/ProductRails";
import { ProductGrid } from "@/components/product/ProductGrid";
import { SellerCard } from "@/components/seller/SellerCard";
import { ButtonLink } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import { getCategories, getHome } from "@/lib/data/catalog";
import { formatRating, initials } from "@/lib/format";
import { ROUTES, withQuery } from "@/lib/routing/routes";

export default async function HomePage() {
  const [home, categories] = await Promise.all([getHome(), getCategories()]);

  return (
    <main className="flex flex-col gap-12 pt-5 md:gap-14 md:pt-6 lg:gap-16 lg:pt-8">
      <Container className="flex flex-col gap-4 md:gap-6">
        {/* Hero */}
        <section className="grid gap-4 md:grid-cols-[minmax(0,1.5fr)_minmax(0,1fr)] md:gap-4 lg:grid-cols-[minmax(0,2fr)_minmax(0,1fr)] lg:gap-6">
          <div className="relative flex min-h-[340px] flex-col justify-between gap-8 overflow-hidden rounded-[24px] bg-pomme-900 p-6 text-pomme-50 md:p-8 lg:min-h-[420px] lg:rounded-[28px] lg:p-14">
            <span className="absolute -top-[60px] -right-20 size-[420px] rounded-full bg-[#2A4A0C]" />
            <span className="absolute right-[60px] -bottom-[120px] size-[300px] rounded-full bg-pomme-800" />
            <span className="absolute top-[100px] right-[110px] hidden text-pomme-500 opacity-90 xl:flex" aria-hidden>
              <Icon name="sprout" size={160} />
            </span>
            <div className="relative flex max-w-[520px] flex-col gap-4 lg:gap-5">
              <span className="text-[13px] font-bold tracking-[0.06em] text-lime uppercase">Marketplace 100 % bio &amp; local</span>
              <h1 className="m-0 font-display text-[36px] leading-[1.02] font-extrabold tracking-[-0.035em] md:text-[44px] lg:text-[58px]">
                Le marché bio, en direct des producteurs.
              </h1>
              <p className="m-0 text-[16px] leading-[26px] text-[#D6E4C2] lg:text-[18px] lg:leading-[27px]">
                Fruits, légumes, miel, épicerie et cosmétiques : chaque produit affiche son origine et son producteur.
              </p>
            </div>
            <div className="relative flex flex-wrap items-center gap-3">
              <ButtonLink href={ROUTES.catalogue} size="lg" iconRight="arrowR">
                Explorer le marché
              </ButtonLink>
              <Link
                href={ROUTES.seller}
                className="flex h-13 items-center rounded-md border-[1.5px] border-[rgba(244,250,232,0.4)] px-[22px] text-[16px] font-bold text-pomme-50 no-underline hover:bg-white/10 hover:text-pomme-50"
              >
                Vendre mes produits
              </Link>
            </div>
          </div>
          <div className="grid gap-4 sm:grid-cols-2 md:grid-cols-1 lg:gap-6">
            <Link
              href={withQuery(ROUTES.catalogue, { categorie: "fruits-legumes" })}
              className="relative flex min-h-[180px] flex-col justify-between gap-6 overflow-hidden rounded-[24px] bg-orange-50 p-6 text-ink no-underline hover:text-ink lg:p-7"
            >
              <span className="absolute right-5 bottom-4 flex text-orange-500 opacity-50" aria-hidden>
                <Icon name="basket" size={88} />
              </span>
              <span className="self-start rounded-[6px] bg-orange-500 px-2 py-1 text-[12px] font-extrabold text-on-secondary">
                −20 % jusqu’à dimanche
              </span>
              <span className="relative flex flex-col gap-1.5">
                <b className="font-display text-[22px] leading-[1.1] lg:text-[26px]">Paniers de saison des Hautes Terres</b>
                <span className="flex items-center gap-1.5 text-[15px] font-bold text-orange-700">
                  J’en profite <Icon name="arrowR" size={16} />
                </span>
              </span>
            </Link>
            <Link
              href={withQuery(ROUTES.catalogue, { categorie: "cosmetiques-bio" })}
              className="relative flex min-h-[180px] flex-col justify-between gap-6 overflow-hidden rounded-[24px] bg-pomme-100 p-6 text-ink no-underline hover:text-ink lg:p-7"
            >
              <span className="absolute right-5 bottom-4 flex text-pomme-600 opacity-50" aria-hidden>
                <Icon name="sprout" size={88} />
              </span>
              <span className="self-start rounded-[6px] bg-ink px-2 py-1 text-[12px] font-extrabold text-white">Nouveau</span>
              <span className="relative flex flex-col gap-1.5">
                <b className="font-display text-[22px] leading-[1.1] lg:text-[26px]">Cosmétiques bio faits main</b>
                <span className="flex items-center gap-1.5 text-[15px] font-bold text-pomme-700">
                  Découvrir <Icon name="arrowR" size={16} />
                </span>
              </span>
            </Link>
          </div>
        </section>

        {/* Trust */}
        <section aria-label="Nos engagements" className="grid gap-3 md:grid-cols-3 md:gap-4 lg:gap-6">
          {home.trust.map((t) => (
            <div key={t.title} className="flex items-center gap-3.5 rounded-lg border border-line bg-white px-5 py-[18px]">
              <span className="flex size-11 shrink-0 items-center justify-center rounded-md bg-pomme-100 text-pomme-700">
                <Icon name={t.icon} size={22} />
              </span>
              <span className="flex flex-col gap-0.5">
                <b className="text-[15px]">{t.title}</b>
                <span className="text-[13px] text-muted">{t.detail}</span>
              </span>
            </div>
          ))}
        </section>
      </Container>

      <Container className="flex flex-col gap-12 md:gap-14 lg:gap-16">
        {/* Categories */}
        <section className="flex flex-col gap-5">
          <SectionHeader
            title="Catégories"
            action={
              <Link href={ROUTES.categories} className="text-[15px] font-bold no-underline">
                Tout le catalogue
              </Link>
            }
          />
          <ul className="-mx-4 m-0 flex list-none gap-3 overflow-x-auto px-4 pb-1 scrollbar-none md:mx-0 md:grid md:grid-cols-9 md:gap-2 md:overflow-visible md:px-0 lg:gap-4">
            {categories.map((c) => (
              <li key={c.slug} className="w-[104px] shrink-0 md:w-auto">
                <Link
                  href={withQuery(ROUTES.catalogue, { categorie: c.slug })}
                  className="flex h-full flex-col items-center gap-2 rounded-xl text-ink no-underline hover:text-ink lg:gap-3 lg:border lg:border-line lg:bg-white lg:px-2 lg:py-5 lg:hover:border-pomme-300"
                >
                  <span
                    className="flex size-[60px] items-center justify-center rounded-[18px] lg:size-16 lg:rounded-xl"
                    style={{ background: c.tile?.bg, color: c.tile?.ink }}
                  >
                    <Icon name={c.icon} size={26} />
                  </span>
                  <span className="text-center text-[12px] leading-[15px] font-semibold lg:text-[14px] lg:leading-[18px]">{c.name}</span>
                </Link>
              </li>
            ))}
          </ul>
        </section>

        <ProductRails rails={home.rails} />

        {/* Promotions */}
        <section className="flex flex-col gap-6 rounded-[24px] bg-orange-50 p-5 md:p-7 lg:rounded-[28px] lg:p-9">
          <SectionHeader
            title="Promotions"
            aside={
              <span className="flex items-center gap-1.5 rounded-full bg-white px-3 py-1.5 text-[14px] font-bold text-orange-800">
                <Icon name="clock" size={16} />
                {home.promoEndsIn}
              </span>
            }
            action={
              <Link href={ROUTES.catalogue} className="text-[15px] font-bold text-orange-700 no-underline hover:text-orange-800">
                Toutes les promos
              </Link>
            }
          />
          <ProductGrid products={home.promos} />
        </section>

        {/* Near you */}
        <section className="grid gap-6 lg:grid-cols-[minmax(0,1.4fr)_minmax(0,1fr)]">
          <div className="relative min-h-[320px] overflow-hidden rounded-[24px] bg-[#EEF3E4] lg:min-h-[440px]" aria-label="Carte des producteurs proches">
            <span className="absolute top-[34%] -left-10 h-[22px] w-[140%] -rotate-[9deg] bg-white" />
            <span className="absolute -top-10 left-[43%] h-[140%] w-[18px] rotate-[16deg] bg-white" />
            <span className="absolute top-[55%] left-[68%] h-[140px] w-[240px] rounded-[80px] bg-[#DCEBC6]" />
            <span className="absolute top-[66%] left-[5%] h-[110px] w-[160px] rounded-[60px] bg-[#DCEBC6]" />
            {home.mapPins.map((p) => (
              <span
                key={p.name}
                className="absolute flex h-8 items-center gap-1.5 rounded-full bg-white pr-2.5 pl-1.5 text-[13px] font-bold whitespace-nowrap shadow-[0_4px_12px_rgba(31,35,24,0.18)]"
                style={{ left: `${(p.x / 800) * 100}%`, top: `${(p.y / 440) * 100}%` }}
              >
                <span
                  className="flex size-[22px] items-center justify-center rounded-full text-[10px] font-extrabold text-white"
                  style={{ background: p.color }}
                >
                  {p.initials}
                </span>
                <span className="hidden sm:inline">{p.name}</span>
              </span>
            ))}
            <span className="absolute top-[45%] left-1/2 size-[18px] rounded-full border-[3px] border-white bg-info-strong shadow-[0_0_0_10px_rgba(47,109,168,0.18)]" />
            <div className="absolute top-6 left-6 flex max-w-[300px] flex-col gap-1 rounded-lg bg-white px-[18px] py-4 shadow-md">
              <h2 className="m-0 font-display text-[22px] font-bold lg:text-[24px]">Découvrir près de chez vous</h2>
              <span className="text-[14px] text-body">12 producteurs à moins de 15 km d’Analakely</span>
            </div>
          </div>
          <div className="flex flex-col gap-3">
            {home.nearby.map((s) => (
              <Link
                key={s.slug}
                href={ROUTES.shop(s.slug)}
                className="flex items-center gap-3.5 rounded-[18px] border border-line bg-white p-4 text-ink no-underline hover:border-pomme-300 hover:text-ink"
              >
                <span
                  className="flex size-14 shrink-0 items-center justify-center rounded-lg font-display text-[18px] font-extrabold text-white"
                  style={{ background: s.avatarColor }}
                >
                  {initials(s.name)}
                </span>
                <span className="flex min-w-0 flex-1 flex-col gap-[3px]">
                  <b className="text-[16px]">{s.name}</b>
                  <span className="truncate text-[13px] text-muted">{s.specialty}</span>
                </span>
                <span className="flex flex-col items-end gap-[3px]">
                  <b className="text-[14px] text-pomme-800">{s.distanceKm} km</b>
                  <span className="flex items-center gap-[3px] text-[12px] text-muted">
                    <Icon name="star" size={12} className="text-orange-500" />
                    {formatRating(s.ratingAvg)}
                  </span>
                </span>
              </Link>
            ))}
          </div>
        </section>

        {/* Popular producers */}
        <section className="flex flex-col gap-5">
          <SectionHeader
            title="Producteurs populaires"
            action={
              <Link href={ROUTES.categories} className="text-[15px] font-bold no-underline">
                Tous les producteurs
              </Link>
            }
          />
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4 lg:gap-6">
            {home.popularShops.map((s) => (
              <SellerCard key={s.slug} shop={s} />
            ))}
          </div>
        </section>

        {/* Sell CTA */}
        <section className="grid items-center gap-8 rounded-[24px] border border-line bg-white p-6 md:p-10 lg:grid-cols-[minmax(0,1.2fr)_minmax(0,1fr)] lg:gap-10 lg:rounded-[28px] lg:px-12">
          <div className="flex flex-col gap-3.5">
            <span className="text-[13px] font-bold tracking-[0.06em] text-pomme-700 uppercase">Vous produisez bio ?</span>
            <h2 className="m-0 font-display text-[28px] leading-[1.08] font-extrabold tracking-[-0.025em] lg:text-[36px]">
              Vendez avec le même compte. Aucune seconde inscription.
            </h2>
            <p className="m-0 text-[16px] leading-6 text-body">
              Activez votre boutique en quelques minutes, publiez vos produits et suivez vos ventes depuis l’onglet Mes ventes.
            </p>
          </div>
          <div className="flex flex-col gap-3">
            {home.sellSteps.map((t, i) => (
              <div key={t} className="flex items-center gap-3.5 rounded-[14px] bg-bg px-4 py-3.5">
                <span className="flex size-8 items-center justify-center rounded-full bg-pomme-500 font-extrabold text-on-primary">{i + 1}</span>
                <span className="text-[15px] font-semibold">{t}</span>
              </div>
            ))}
            <ButtonLink href={ROUTES.sellerOnboarding} variant="dark" size="lg" iconRight="arrowR" className="mt-1">
              Ouvrir ma boutique
            </ButtonLink>
          </div>
        </section>
      </Container>
    </main>
  );
}
