"use client";

import { useState } from "react";
import type { Review } from "@/lib/types";
import { Avatar } from "@/components/ui/Avatar";
import { Button } from "@/components/ui/Button";
import { ChipGroup } from "@/components/ui/Chip";
import { Icon } from "@/components/ui/Icon";
import { Stars } from "@/components/ui/Rating";

type Filter = "all" | "unanswered" | "five" | "low";

/** Reviews received with filters and inline reply (W-Reviews-Received). */
export function ReceivedReviews({ reviews }: { reviews: Review[] }) {
  const [filter, setFilter] = useState<Filter>("all");
  const [open, setOpen] = useState<string | null>(reviews.find((r) => !r.sellerReply)?.id ?? null);
  const [replies, setReplies] = useState<Record<string, string>>({});
  const [draft, setDraft] = useState("");
  const unanswered = reviews.filter((r) => !r.sellerReply).length;
  const shown = reviews.filter((r) =>
    filter === "all" ? true : filter === "unanswered" ? !r.sellerReply && !replies[r.id] : filter === "five" ? r.rating === 5 : r.rating <= 3,
  );
  return (
    <div className="flex flex-col gap-3">
      <ChipGroup
        label="Filtrer les avis"
        size="sm"
        value={filter}
        onChange={setFilter}
        className="flex-nowrap overflow-x-auto scrollbar-none"
        options={[
          { value: "all", label: "Tous" },
          { value: "unanswered", label: `Sans réponse (${unanswered})` },
          { value: "five", label: "5 étoiles" },
          { value: "low", label: "3 étoiles et moins" },
        ]}
      />
      {shown.map((r) => {
        const reply = r.sellerReply ?? replies[r.id];
        return (
          <article key={r.id} className="flex flex-col gap-2 rounded-[18px] border border-line bg-white p-[18px]">
            <div className="flex flex-wrap items-center gap-3">
              <Avatar initials={r.author.initials} color={r.author.color} size={38} />
              <span className="flex min-w-0 flex-1 flex-col">
                <b className="text-[15px]">{r.author.name}</b>
                <span className="text-[12px] text-muted">
                  {r.productName} · {r.dateLabel} · achat vérifié
                </span>
              </span>
              <Stars value={r.rating} size={15} />
            </div>
            <p className="m-0 text-[15px] leading-[22px] text-text-soft">{r.comment}</p>
            {reply && (
              <div className="rounded-md bg-sand px-3.5 py-2.5 text-[14px] leading-5">
                <b className="block text-[12px] text-pomme-800">Votre réponse</b>
                {reply}
              </div>
            )}
            {!reply && open === r.id && (
              <form
                className="flex flex-col gap-2.5 sm:flex-row sm:items-start"
                onSubmit={(e) => {
                  e.preventDefault();
                  if (!draft.trim()) return;
                  // TODO(api): sellerApi.replyToReview(r.id, draft)
                  setReplies({ ...replies, [r.id]: draft.trim() });
                  setDraft("");
                  setOpen(null);
                }}
              >
                <label htmlFor={`reply-${r.id}`} className="sr-only">
                  Réponse
                </label>
                <textarea
                  id={`reply-${r.id}`}
                  rows={2}
                  value={draft}
                  onChange={(e) => setDraft(e.target.value)}
                  placeholder="Merci pour votre retour…"
                  className="flex-1 resize-none rounded-[10px] border-[1.5px] border-pomme-600 px-3 py-2.5 text-[14px] shadow-[0_0_0_4px_rgba(140,198,63,0.2)] outline-none"
                />
                <Button type="submit" className="text-[14px]">
                  Publier
                </Button>
              </form>
            )}
            {!reply && open !== r.id && (
              <div className="flex gap-2">
                <Button variant="outline" size="sm" icon="msg" className="rounded-[9px] border-pomme-300 px-3 text-[13px]" onClick={() => setOpen(r.id)}>
                  Répondre
                </Button>
                <Button variant="ghost" size="sm" className="px-3 text-[13px] text-muted">
                  <Icon name="flag" size={15} />
                  Signaler
                </Button>
              </div>
            )}
          </article>
        );
      })}
    </div>
  );
}
