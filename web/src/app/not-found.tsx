import Link from "next/link";
import { Container } from "@/components/layout/Container";
import { SiteChrome } from "@/components/layout/SiteChrome";
import { ButtonLink } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import { ROUTES, withQuery } from "@/lib/routing/routes";

const POPULAR = ["Miel de litchi", "Paniers de saison", "Vanille", "Riz rouge"];

export default function NotFound() {
  return (
    <SiteChrome footer={false}>
      <main className="flex flex-1 items-center py-10 lg:min-h-[640px]">
        <Container className="grid items-center gap-8 lg:grid-cols-2 lg:gap-12 xl:px-[120px]">
          <div className="flex flex-col gap-5">
            <span className="text-[14px] font-bold tracking-[0.08em] text-orange-700 uppercase">Erreur 404</span>
            <h1 className="m-0 font-display text-[40px] leading-[1.02] font-extrabold tracking-[-0.035em] lg:text-[56px]">
              Cette page s’est perdue dans la brousse.
            </h1>
            <p className="m-0 max-w-[480px] text-[17px] leading-[27px] text-body lg:text-[18px]">
              Le produit a peut-être été retiré par son producteur, ou le lien est incorrect.
            </p>
            <div className="flex flex-wrap gap-3">
              <ButtonLink href={ROUTES.home} icon="home" size="lg" className="px-[22px]">
                Retour à l’accueil
              </ButtonLink>
              <ButtonLink href={ROUTES.categories} variant="neutral" size="lg" className="px-[22px]">
                Parcourir les catégories
              </ButtonLink>
            </div>
            <div className="flex flex-wrap items-center gap-2 pt-2">
              <span className="text-[14px] text-muted">Recherches populaires :</span>
              {POPULAR.map((p) => (
                <Link
                  key={p}
                  href={withQuery(ROUTES.search, { q: p })}
                  className="inline-flex h-[34px] items-center rounded-full bg-pomme-100 px-3 text-[13px] font-semibold text-pomme-800 no-underline"
                >
                  {p}
                </Link>
              ))}
            </div>
          </div>
          <div className="relative flex h-[300px] items-center justify-center lg:h-[460px]" aria-hidden>
            <span className="absolute size-[280px] rounded-full bg-pomme-100 lg:size-[420px]" />
            <span className="absolute bottom-[50px] h-[50px] w-[220px] rounded-full bg-[#E6DACB] lg:bottom-[70px] lg:h-[60px] lg:w-[300px]" />
            <span className="absolute top-10 right-[20%] size-12 rounded-full bg-orange-200" />
            <b className="relative font-display text-[120px] leading-none font-extrabold tracking-[-0.05em] text-pomme-300 lg:text-[170px]">404</b>
            <span className="absolute bottom-[74px] flex text-pomme-700 lg:bottom-[104px]">
              <Icon name="sprout" size={96} />
            </span>
          </div>
        </Container>
      </main>
    </SiteChrome>
  );
}
