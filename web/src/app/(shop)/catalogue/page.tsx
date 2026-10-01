import type { Metadata } from "next";
import { Suspense } from "react";
import { Container } from "@/components/layout/Container";
import {
  ActiveFilters,
  FilterPanel,
  MobileFilters,
  SortSelect,
  SubcategoryChips,
  ViewToggle,
} from "@/components/catalog/CatalogControls";
import { ProductGrid } from "@/components/product/ProductGrid";
import { Button } from "@/components/ui/Button";
import { Breadcrumb, Pagination } from "@/components/ui/Navigation";
import { EmptyState } from "@/components/ui/Feedback";
import { Icon } from "@/components/ui/Icon";
import { getCatalog } from "@/lib/data/catalog";
import { formatNumber } from "@/lib/format";
import type { CatalogFilters } from "@/lib/types";

export const metadata: Metadata = { title: "Catalogue" };

type SP = Promise<Record<string, string | string[] | undefined>>;

const one = (v: string | string[] | undefined) => (Array.isArray(v) ? v[0] : v);

export default async function CataloguePage({ searchParams }: { searchParams: SP }) {
  const sp = await searchParams;
  const filters: CatalogFilters = {
    categorie: one(sp.categorie),
    q: one(sp.q),
    tri: one(sp.tri) as CatalogFilters["tri"],
    page: Number(one(sp.page) ?? 1) || 1,
  };
  const data = await getCatalog(filters);
  const slug = data.category?.slug ?? "fruits-legumes";
  const page = filters.page ?? 1;
  const hrefFor = (p: number) => {
    const q = new URLSearchParams();
    q.set("categorie", slug);
    if (filters.tri) q.set("tri", filters.tri);
    if (p > 1) q.set("page", String(p));
    return `/catalogue?${q.toString()}`;
  };
  const shown = data.products.items.length;

  return (
    <main className="pt-4 pb-16 lg:pt-6">
      <Container className="flex flex-col gap-5 lg:gap-6">
        <div className="flex flex-col gap-2.5">
          <Breadcrumb className="hidden lg:block" items={[{ label: "Accueil", href: "/" }, { label: data.title }]} />
          <div className="flex flex-wrap items-end justify-between gap-4">
            <div className="flex flex-col gap-0.5 lg:flex-row lg:items-baseline lg:gap-3.5">
              <h1 className="m-0 font-display text-[30px] font-extrabold tracking-[-0.02em] lg:text-[40px] lg:tracking-[-0.03em]">
                {filters.q ? `« ${filters.q} »` : data.title}
              </h1>
              <span className="text-[14px] text-muted lg:text-[15px]">
                {formatNumber(data.products.totalItems)} produits · {data.producerCount} producteurs
              </span>
            </div>
            <div className="flex items-center gap-2.5">
              <Suspense>
                <SortSelect value={filters.tri ?? "pertinence"} />
              </Suspense>
              <ViewToggle />
              <MobileFilters subcategories={data.subcategories} categorySlug={slug} activeCount={3} />
            </div>
          </div>
        </div>

        {/* Tablet/phone search + subcategory pills (T-Catalog) */}
        <form role="search" action="/recherche" className="flex h-[50px] items-center gap-2.5 rounded-[14px] border-[1.5px] border-line-strong bg-white px-3.5 text-muted lg:hidden">
          <Icon name="search" size={20} />
          <label htmlFor="cat-q" className="sr-only">
            Rechercher dans {data.title}
          </label>
          <input
            id="cat-q"
            name="q"
            placeholder={`Rechercher dans ${data.title}`}
            className="h-full min-w-0 flex-1 border-0 bg-transparent text-[15px] text-ink outline-none focus-visible:outline-none"
          />
        </form>
        <SubcategoryChips subcategories={data.subcategories} />

        <div className="grid items-start gap-8 lg:grid-cols-[260px_minmax(0,1fr)] xl:grid-cols-[280px_minmax(0,1fr)]">
          <aside aria-label="Filtres" className="hidden lg:block">
            <FilterPanel subcategories={data.subcategories} categorySlug={slug} />
          </aside>
          <div className="flex flex-col gap-5">
            <ActiveFilters filters={data.activeFilters} />
            {shown === 0 ? (
              <EmptyState
                icon="search"
                tone="sand"
                title="Aucun résultat"
                description="Aucun produit ne correspond. Essayez un autre mot ou élargissez la zone."
              />
            ) : (
              <ProductGrid products={data.products.items} cols={4} />
            )}
            <Pagination
              className="hidden pt-3 md:flex"
              page={page}
              totalPages={data.products.totalPages}
              hrefFor={hrefFor}
              summary={`1–${shown} sur ${formatNumber(data.products.totalItems)} produits`}
            />
            <Button variant="neutral" size="md" className="self-center md:hidden">
              Afficher 12 produits de plus
            </Button>
          </div>
        </div>
      </Container>
    </main>
  );
}
