import type { Metadata } from "next";
import Link from "next/link";
import { Container, PageHeader } from "@/components/layout/Container";
import { SearchBox, SearchRefine } from "@/components/catalog/SearchRefine";
import { ProductGrid } from "@/components/product/ProductGrid";
import { Button } from "@/components/ui/Button";
import { EmptyState } from "@/components/ui/Feedback";
import { Select } from "@/components/ui/Form";
import { searchCatalog } from "@/lib/data/catalog";

export const metadata: Metadata = { title: "Recherche" };

export default async function SearchPage({ searchParams }: { searchParams: Promise<{ q?: string | string[] }> }) {
  const sp = await searchParams;
  const q = (Array.isArray(sp.q) ? sp.q[0] : sp.q) ?? "miel";
  const data = await searchCatalog(q);
  const remaining = data.products.totalItems - data.products.items.length;

  return (
    <main className="pt-6 pb-16 lg:pt-7">
      <Container className="flex flex-col gap-[22px]">
        <div className="max-w-[640px]">
          <SearchBox query={data.query} suggestions={data.suggestions} recent={data.recent} />
        </div>
        <PageHeader
          title={`Résultats pour « ${data.query} »`}
          subtitle={`${data.products.totalItems} produits · ${data.shops.length} producteurs · livrables à Analakely`}
          actions={
            <Select
              aria-label="Trier"
              size="sm"
              className="h-11 w-[200px] font-semibold"
              options={[
                { value: "pertinence", label: "Trier : pertinence" },
                { value: "prix-asc", label: "Trier : prix croissant" },
                { value: "note", label: "Trier : mieux notés" },
              ]}
            />
          }
        />
        <SearchRefine options={data.refinements} />
        {data.shops.length > 0 && (
          <section aria-label="Producteurs" className="grid gap-4 md:grid-cols-2">
            {data.shops.map((s) => (
              <Link
                key={s.slug}
                href={`/vendeurs/${s.slug}`}
                className="flex items-center gap-3.5 rounded-[18px] border border-line bg-white px-[18px] py-4 text-ink no-underline hover:border-pomme-300 hover:text-ink"
              >
                <span
                  className="flex size-14 shrink-0 items-center justify-center rounded-full font-display text-[18px] font-extrabold text-white"
                  style={{ background: s.color }}
                >
                  {s.initials}
                </span>
                <span className="flex min-w-0 flex-1 flex-col gap-0.5">
                  <span className="text-[12px] font-bold tracking-[0.06em] text-muted uppercase">Producteur</span>
                  <b className="text-[17px]">{s.name}</b>
                  <span className="text-[13px] text-body">{s.meta}</span>
                </span>
                <span className="hidden h-10 items-center rounded-[10px] bg-pomme-100 px-3.5 text-[14px] font-bold text-pomme-800 sm:flex">
                  Voir la boutique
                </span>
              </Link>
            ))}
          </section>
        )}
        {data.products.items.length === 0 ? (
          <EmptyState
            icon="search"
            tone="sand"
            title="Aucun résultat"
            description={`Aucun produit pour « ${data.query} ». Essayez un autre mot ou élargissez la zone.`}
          />
        ) : (
          <ProductGrid products={data.products.items} />
        )}
        {remaining > 0 && (
          <div className="flex justify-center">
            <Button variant="neutral" size="md" className="h-12">
              Afficher les {remaining} autres résultats
            </Button>
          </div>
        )}
      </Container>
    </main>
  );
}
