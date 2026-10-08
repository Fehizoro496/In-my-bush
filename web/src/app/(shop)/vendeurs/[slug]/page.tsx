import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { Container } from "@/components/layout/Container";
import { ProductCard } from "@/components/product/ProductCard";
import { FollowButton, ShopTabs } from "@/components/seller/ShopProfileTabs";
import { ButtonLink } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import { Stars } from "@/components/ui/Rating";
import { getShop } from "@/lib/data/catalog";
import { formatRating, initials } from "@/lib/format";
import { ROUTES } from "@/lib/routing/routes";

type Params = Promise<{ slug: string }>;

export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const shop = await getShop((await params).slug);
  return { title: shop?.name ?? "Producteur introuvable" };
}

export default async function SellerPage({ params }: { params: Params }) {
  const shop = await getShop((await params).slug);
  if (!shop) notFound();
  const since = new Date(shop.createdAt).getFullYear();

  const reviewsBlock = (
    <div className="grid gap-6 rounded-xl border border-line bg-white p-6 md:grid-cols-[200px_minmax(0,1fr)_minmax(0,1fr)] md:gap-8">
      <div className="flex flex-col gap-1">
        <span className="overline text-[13px] text-muted">Avis clients</span>
        <span className="font-display text-[48px] leading-none font-extrabold">{formatRating(shop.ratingAvg)}</span>
        <span className="text-[14px] text-muted">{shop.ratingCount} avis vérifiés</span>
      </div>
      {shop.reviews.map((r) => (
        <div key={r.author} className="flex flex-col gap-1.5">
          <Stars value={5} size={15} />
          <p className="m-0 text-[15px] leading-[22px] text-text-soft">« {r.text} »</p>
          <span className="text-[13px] text-muted">
            {r.author} · {r.product}
          </span>
        </div>
      ))}
    </div>
  );

  return (
    <main className="pt-4 pb-16 lg:pt-6 lg:pb-[72px]">
      <Container className="flex flex-col gap-8">
        <section className="flex flex-col">
          <div className="relative h-[160px] overflow-hidden rounded-[24px] md:h-[240px] md:rounded-[28px]" style={{ background: shop.cover.tint, color: shop.cover.ink }}>
            <span className="absolute -top-20 -right-[60px] size-[360px] rounded-full bg-white/25" />
            <span className="absolute right-7 bottom-5 text-[12px] font-bold tracking-[0.08em] uppercase opacity-70">Photo de couverture · l’exploitation</span>
          </div>
          <div className="relative -mt-14 flex flex-col gap-4 px-2 md:flex-row md:items-end md:gap-6 md:px-8">
            <span
              className="flex size-[104px] shrink-0 items-center justify-center rounded-full border-[6px] border-bg font-display text-[36px] font-extrabold text-white md:size-32 md:text-[44px]"
              style={{ background: shop.avatarColor }}
            >
              {initials(shop.name)}
            </span>
            <div className="flex flex-1 flex-col gap-1.5 md:pb-2">
              <div className="flex flex-wrap items-center gap-3">
                <h1 className="m-0 font-display text-[30px] font-extrabold tracking-[-0.03em] lg:text-[38px]">{shop.name}</h1>
                {shop.verified && (
                  <span className="inline-flex items-center gap-1 rounded-full bg-info-bg px-2.5 py-1.5 text-[13px] font-bold text-info-fg">
                    <Icon name="shield" size={15} />
                    Vendeur vérifié
                  </span>
                )}
              </div>
              <div className="flex flex-wrap items-center gap-x-5 gap-y-1 text-[14px] text-body lg:text-[15px]">
                <span className="flex items-center gap-1.5">
                  <Icon name="pin" size={16} />
                  {shop.city}, {shop.region} · {shop.distanceKm} km
                </span>
                <span className="flex items-center gap-1.5">
                  <Icon name="star" size={16} className="text-orange-500" />
                  <b className="text-ink">{formatRating(shop.ratingAvg)}</b> ({shop.ratingCount} avis)
                </span>
                <span>{shop.products.length} produits</span>
                <span>Membre depuis {since}</span>
                <span>{shop.responseTime}</span>
              </div>
            </div>
            <div className="flex gap-2.5 md:pb-2">
              <FollowButton />
              <ButtonLink href={ROUTES.accountMessages} icon="msg" size="lg" className="h-12 text-[15px]">
                Contacter le vendeur
              </ButtonLink>
            </div>
          </div>
        </section>

        <section className="grid items-start gap-8 lg:grid-cols-[300px_minmax(0,1fr)] xl:grid-cols-[340px_minmax(0,1fr)]">
          <aside className="flex flex-col gap-4">
            <div className="flex flex-col gap-3 rounded-xl border border-line bg-white p-[22px]">
              <h2 className="m-0 font-display text-[20px] font-bold">À propos</h2>
              <p className="m-0 text-[15px] leading-[23px] text-text-soft">{shop.description}</p>
            </div>
            <div className="flex flex-col gap-3 rounded-xl border border-line bg-white p-[22px]">
              <h2 className="m-0 font-display text-[20px] font-bold">Badges</h2>
              {shop.badges.map((b) => (
                <div key={b.title} className="flex items-center gap-3">
                  <span className="flex size-10 shrink-0 items-center justify-center rounded-md" style={{ background: b.bg, color: b.ink }}>
                    <Icon name={b.icon} size={20} />
                  </span>
                  <div className="flex flex-col gap-px">
                    <b className="text-[14px]">{b.title}</b>
                    <span className="text-[12px] text-muted">{b.detail}</span>
                  </div>
                </div>
              ))}
            </div>
            <div className="flex flex-col gap-3 rounded-xl border border-line bg-white p-[22px]">
              <h2 className="m-0 font-display text-[20px] font-bold">Livraison &amp; retrait</h2>
              {shop.deliveryInfo.map((d) => (
                <div key={d} className="flex gap-2.5 text-[14px]">
                  <Icon name="truck" size={18} className="text-pomme-700" />
                  {d}
                </div>
              ))}
              {shop.pickupInfo && (
                <div className="flex gap-2.5 text-[14px]">
                  <Icon name="store" size={18} className="text-pomme-700" />
                  {shop.pickupInfo}
                </div>
              )}
              <div className="relative mt-1 h-[120px] overflow-hidden rounded-[14px] bg-[#EEF3E4]" aria-hidden>
                <span className="absolute top-[60px] -left-2.5 h-2.5 w-[400px] -rotate-[10deg] bg-white" />
                <span className="absolute top-9 left-[140px] size-[30px] -rotate-45 rounded-[999px_999px_999px_4px]" style={{ background: shop.avatarColor }} />
              </div>
            </div>
          </aside>
          <ShopTabs
            productCount={shop.products.length}
            reviewCount={shop.ratingCount}
            products={
              <div className="flex flex-col gap-5">
                <div className="grid grid-cols-2 gap-3 sm:gap-4 md:grid-cols-3 xl:gap-6">
                  {shop.products.map((p) => (
                    <ProductCard key={p.id} product={p} />
                  ))}
                </div>
                {reviewsBlock}
              </div>
            }
            reviews={reviewsBlock}
          />
        </section>
      </Container>
    </main>
  );
}
