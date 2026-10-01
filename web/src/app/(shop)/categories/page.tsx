import type { Metadata } from "next";
import Link from "next/link";
import { Container, PageHeader } from "@/components/layout/Container";
import { Icon } from "@/components/ui/Icon";
import { getCategories, getRegions } from "@/lib/data/catalog";

export const metadata: Metadata = { title: "Toutes les catégories" };

export default async function CategoriesPage() {
  const [categories, regions] = await Promise.all([getCategories(), getRegions()]);
  return (
    <main className="pt-6 pb-16 lg:pt-8">
      <Container className="flex flex-col gap-7">
        <PageHeader title="Toutes les catégories" subtitle="1 161 produits bio de 386 producteurs" size="lg" />
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 lg:gap-6">
          {categories.map((c) => (
            <article key={c.slug} className="flex flex-col overflow-hidden rounded-[24px] border border-line bg-white">
              <Link
                href={`/catalogue?categorie=${c.slug}`}
                className="relative flex h-[150px] flex-col justify-end overflow-hidden px-[22px] py-5 no-underline"
                style={{ background: c.visual?.bg, color: c.visual?.fg ?? "#1F2318" }}
              >
                <span className="absolute -top-2.5 -right-2.5 flex opacity-35" style={{ color: c.visual?.ink }} aria-hidden>
                  <Icon name={c.icon} size={140} />
                </span>
                <b className="relative font-display text-[26px] leading-[1.1]">{c.name}</b>
                <span className="relative text-[14px] opacity-85">{c.productCount} produits</span>
              </Link>
              <div className="flex flex-col gap-3 px-[22px] pt-4 pb-5">
                <div className="flex flex-wrap gap-2">
                  {c.children?.map((s) => (
                    <Link
                      key={s.slug}
                      href={`/catalogue?categorie=${c.slug}&sous=${s.slug}`}
                      className="inline-flex h-[34px] items-center rounded-full bg-sand px-3 text-[13px] font-semibold text-ink no-underline hover:bg-divider hover:text-ink"
                    >
                      {s.name}
                    </Link>
                  ))}
                </div>
                <Link href={`/catalogue?categorie=${c.slug}`} className="inline-flex items-center gap-1.5 self-start text-[14px] font-bold no-underline">
                  Tout voir <Icon name="arrowR" size={15} />
                </Link>
              </div>
            </article>
          ))}
        </div>
        <section className="flex flex-col gap-3.5">
          <h2 className="m-0 font-display text-[26px] font-bold">Par région</h2>
          <div className="flex flex-wrap gap-2.5">
            {regions.map((r) => (
              <Link
                key={r.name}
                href={`/catalogue?region=${encodeURIComponent(r.name)}`}
                className="inline-flex h-11 items-center gap-2 rounded-full border-[1.5px] border-line-strong bg-white px-4 text-[14px] font-semibold text-ink no-underline hover:border-pomme-500 hover:text-ink"
              >
                <Icon name="pin" size={15} />
                {r.name}
                <span className="font-medium text-muted">{r.count}</span>
              </Link>
            ))}
          </div>
        </section>
      </Container>
    </main>
  );
}
