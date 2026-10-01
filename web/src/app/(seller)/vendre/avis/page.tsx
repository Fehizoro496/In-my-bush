import type { Metadata } from "next";
import { ReceivedReviews } from "@/components/reviews/ReceivedReviews";
import { RatingBars } from "@/components/ui/Rating";
import { getSellerReviews } from "@/lib/data/seller";
import { formatRating } from "@/lib/format";

export const metadata: Metadata = { title: "Avis reçus" };

export default async function ReviewsReceivedPage() {
  const { reviews, breakdown, byProduct } = await getSellerReviews();
  return (
    <>
      <h1 className="m-0 font-display text-[28px] font-extrabold tracking-[-0.025em] md:text-[36px]">Avis reçus</h1>
      <div className="grid items-start gap-5 xl:grid-cols-[290px_minmax(0,1fr)]">
        <aside className="grid gap-4 md:grid-cols-2 xl:grid-cols-1">
          <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-5">
            <div className="flex items-baseline gap-2.5">
              <b className="font-display text-[48px] leading-none">4,8</b>
              <span className="text-[14px] text-muted">57 avis · 96 % positifs</span>
            </div>
            <RatingBars breakdown={breakdown} compact />
          </section>
          <section className="flex flex-col gap-2.5 rounded-xl border border-line bg-white p-5">
            <h2 className="m-0 text-[15px] font-bold">Par produit</h2>
            {byProduct.map((p) => (
              <div key={p.name} className="flex items-center gap-2.5 text-[14px]">
                <span className="size-8 rounded-lg" style={{ background: p.tint }} aria-hidden />
                <span className="flex-1">{p.name}</span>
                <b>{formatRating(p.rating)}</b>
                <span className="text-[12px] text-muted">({p.count})</span>
              </div>
            ))}
          </section>
        </aside>
        <ReceivedReviews reviews={reviews} />
      </div>
    </>
  );
}
