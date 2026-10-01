import type { Metadata } from "next";
import { MyReviewsView } from "@/components/reviews/MyReviewsView";
import { getMyReviews } from "@/lib/data/account";

export const metadata: Metadata = { title: "Mes avis" };

export default async function MyReviewsPage() {
  const { toLeave, published, tags } = await getMyReviews();
  return <MyReviewsView toLeave={toLeave} published={published} tags={tags} />;
}
