import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { Container } from "@/components/layout/Container";
import { ProductGallery } from "@/components/product/ProductGallery";
import { ProductGrid } from "@/components/product/ProductGrid";
import { PurchaseBox } from "@/components/product/PurchaseBox";
import { SellerCard } from "@/components/seller/SellerCard";
import { Avatar } from "@/components/ui/Avatar";
import { ButtonLink } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import { Breadcrumb } from "@/components/ui/Navigation";
import { RatingBars, Stars } from "@/components/ui/Rating";
import { getProduct, getProductReviews, getSimilarProducts } from "@/lib/data/catalog";
import { formatAriary, formatRating } from "@/lib/format";
import { ROUTES, withQuery } from "@/lib/routing/routes";

type Params = Promise<{ slug: string }>;

export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const p = await getProduct((await params).slug);
  return { title: p?.name ?? "Produit introuvable" };
}

export default async function ProductPage({ params }: { params: Params }) {
  const { slug } = await params;
  const product = await getProduct(slug);
  if (!product) notFound();
  const [reviews, similar] = await Promise.all([getProductReviews(product.id), getSimilarProducts(slug)]);
  const out = product.stockLevel === "OUT";

  return (
    <main className="pt-4 pb-16 lg:pt-5 lg:pb-[72px]">
      <Container className="flex flex-col gap-8 lg:gap-10">
        <Breadcrumb
          items={[
            { label: "Accueil", href: ROUTES.home },
            { label: product.category.name, href: withQuery(ROUTES.catalogue, { categorie: product.category.slug }) },
            { label: product.name },
          ]}
        />

        <section className="grid grid-cols-1 items-start gap-6 lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)] lg:gap-12">
          <ProductGallery images={product.images} badge={product.distanceKm ? `Local · ${product.distanceKm} km` : undefined} />
          <div className="flex flex-col gap-5">
            <div className="flex flex-col gap-2.5">
              <Link href={ROUTES.shop(product.shop.slug)} className="flex items-center gap-1.5 text-[14px] font-bold no-underline">
                {product.shopDetail.name}
                <Icon name="shield" size={15} className="text-info-strong" label="Vendeur vérifié" />
              </Link>
              <h1 className="m-0 font-display text-[32px] leading-[1.05] font-extrabold tracking-[-0.03em] lg:text-[42px]">{product.name}</h1>
              <div className="flex flex-wrap items-center gap-2 text-[15px]">
                <Stars value={product.ratingAvg} />
                <b>{formatRating(product.ratingAvg)}</b>
                <a href="#avis" className="text-body">
                  {product.ratingCount} avis
                </a>
                <span className="text-disabled">·</span>
                <span className="text-body">{product.soldCount} vendus</span>
              </div>
            </div>
            <div className="flex flex-wrap items-baseline gap-2.5">
              {product.compareAtPrice && (
                <span className="text-[18px] text-muted line-through font-tabular">{formatAriary(product.compareAtPrice)}</span>
              )}
              <span className={`font-display text-[34px] font-extrabold font-tabular lg:text-[40px] ${out ? "text-muted" : product.compareAtPrice ? "text-orange-700" : ""}`}>
                {formatAriary(product.price)}
              </span>
              <span className="text-[17px] text-muted">/ {product.unitLabel}</span>
              {product.pricePerKgLabel && <span className="text-[14px] text-muted">· {product.pricePerKgLabel}</span>}
            </div>
            {out ? (
              <span className="inline-flex items-center gap-2.5">
                <span className="inline-flex h-[26px] items-center rounded-full bg-sand px-2.5 text-[12px] font-bold text-body">Rupture de stock</span>
                <span className="text-[13px] text-muted">Prochaine récolte prévue : [DATE]</span>
              </span>
            ) : (
              <span className={`inline-flex items-center gap-2 text-[14px] font-bold ${product.stockLevel === "LOW" ? "text-orange-700" : "text-pomme-800"}`}>
                <span className={`size-[9px] rounded-full ${product.stockLevel === "LOW" ? "bg-orange-500" : "bg-pomme-600"}`} />
                {product.stockLevel === "LOW" ? product.stockLabel : `En stock · ${product.stock} ${product.unit === "JAR" ? "pots" : product.unitLabel} disponibles`}
              </span>
            )}
            <PurchaseBox name={product.name} price={product.price} unitLabel={product.unitLabel} stock={product.stock} out={out} />
            <ul className="m-0 flex list-none flex-col rounded-lg border border-line bg-white p-0">
              {product.delivery.map((d, i) => (
                <li key={i} className={`flex items-center gap-3 px-4 py-3.5 ${i > 0 ? "border-t border-divider" : ""}`}>
                  <Icon name={d.icon} size={20} className="text-pomme-700" />
                  <span className="flex-1 text-[14px]">
                    {d.title && <b>{d.title}</b>}
                    {d.title && (d.icon === "store" ? " · " : " ")}
                    {d.detail}
                  </span>
                  {d.price && <span className={`text-[14px] ${d.free ? "font-bold text-pomme-700" : "font-semibold"}`}>{d.price}</span>}
                </li>
              ))}
            </ul>
          </div>
        </section>

        <section aria-label="Provenance" className="grid gap-4 md:grid-cols-2 lg:gap-6">
          <div className="flex flex-col gap-3.5 rounded-xl bg-sand p-6">
            <div className="flex items-center gap-2.5">
              <span className="flex size-10 items-center justify-center rounded-md bg-white text-orange-700">
                <Icon name="pin" size={20} />
              </span>
              <span className="overline text-muted">Provenance</span>
            </div>
            <b className="font-display text-[22px]">{product.originRegion}</b>
            <div className="flex items-center gap-2">
              <span className="text-[13px] font-semibold">Producteur</span>
              <span className="flex-1 border-t-2 border-dashed border-stone" />
              <span className="rounded-full bg-mint px-2.5 py-[3px] text-[12px] font-bold text-pomme-800">{product.distanceKm} km</span>
              <span className="flex-1 border-t-2 border-dashed border-stone" />
              <span className="text-[13px] font-semibold">Chez vous</span>
            </div>
          </div>
          <div className="flex flex-col gap-3 rounded-xl border border-line bg-white p-6">
            <div className="flex items-center gap-2.5">
              <span className="flex size-10 items-center justify-center rounded-md bg-sand text-ink">
                <Icon name="leaf" size={20} />
              </span>
              <span className="overline text-muted">Traçabilité</span>
            </div>
            <dl className="m-0 grid grid-cols-[120px_minmax(0,1fr)] gap-2 text-[14px]">
              {product.traceability.map((t) => (
                <div key={t.label} className="contents">
                  <dt className="text-muted">{t.label}</dt>
                  <dd className="m-0 font-semibold">{t.value}</dd>
                </div>
              ))}
            </dl>
          </div>
        </section>

        <section className="grid items-start gap-10 lg:grid-cols-[minmax(0,8fr)_minmax(0,4fr)] lg:gap-12">
          <div className="flex flex-col gap-8">
            <div className="flex flex-col gap-4">
              <h2 className="m-0 font-display text-[26px] font-bold lg:text-[28px]">Description</h2>
              <p className="m-0 max-w-[720px] text-[16px] leading-[26px] text-text-soft lg:text-[17px] lg:leading-[27px]">{product.description}</p>
              <dl className="m-0 grid grid-cols-2 gap-3 md:grid-cols-4">
                {product.specs.map((s) => (
                  <div key={s.label} className="flex flex-col gap-1 rounded-[14px] border border-line bg-white px-4 py-3.5">
                    <dt className="text-[12px] font-semibold text-muted">{s.label}</dt>
                    <dd className="m-0 text-[15px] font-bold">{s.value}</dd>
                  </div>
                ))}
              </dl>
            </div>
            <div id="avis" className="flex scroll-mt-6 flex-col gap-5">
              <div className="flex items-center justify-between gap-3">
                <h2 className="m-0 font-display text-[26px] font-bold lg:text-[28px]">Avis clients</h2>
                <ButtonLink href={ROUTES.accountReviews} variant="outline">
                  Écrire un avis
                </ButtonLink>
              </div>
              <div className="grid items-center gap-6 rounded-xl border border-line bg-white p-6 md:grid-cols-[220px_minmax(0,1fr)] md:gap-8">
                <div className="flex flex-col gap-1">
                  <span className="font-display text-[56px] leading-none font-extrabold">{formatRating(product.ratingAvg)}</span>
                  <span className="text-[14px] text-muted">sur 5 · {product.ratingCount} avis vérifiés</span>
                </div>
                <RatingBars breakdown={product.ratingBreakdown} />
              </div>
              {reviews.map((r) => (
                <article key={r.id} className="grid gap-3 border-t border-line py-5 md:grid-cols-[200px_minmax(0,1fr)] md:gap-6">
                  <div className="flex items-center gap-2.5">
                    <Avatar initials={r.author.initials} color={r.author.color} size={40} />
                    <div className="flex flex-col">
                      <b className="text-[14px]">{r.author.name}</b>
                      <span className="text-[12px] text-muted">{r.dateLabel}</span>
                    </div>
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <Stars value={r.rating} size={15} />
                    <p className="m-0 text-[15px] leading-[23px] text-text-soft">{r.comment}</p>
                    <span className="inline-flex items-center gap-1 text-[12px] font-semibold text-pomme-700">
                      <Icon name="checkCircle" size={14} />
                      Achat vérifié
                    </span>
                  </div>
                </article>
              ))}
            </div>
          </div>
          <aside className="flex flex-col gap-4">
            <SellerCard shop={product.shopDetail} />
            <div className="flex flex-col gap-2.5 rounded-lg border border-line bg-white p-[18px]">
              <b className="text-[15px]">Une question sur ce produit ?</b>
              <span className="text-[14px] text-body">Le vendeur répond en général en moins d’une heure.</span>
              <ButtonLink href={ROUTES.accountMessages} icon="msg" size="md" className="text-[14px]">
                Contacter le vendeur
              </ButtonLink>
            </div>
          </aside>
        </section>

        <section className="flex flex-col gap-5">
          <h2 className="m-0 font-display text-[26px] font-bold lg:text-[28px]">Produits similaires</h2>
          <ProductGrid products={similar} />
        </section>
      </Container>
    </main>
  );
}
