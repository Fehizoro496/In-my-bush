"use client";

import { useState } from "react";
import type { Visual } from "@/lib/types";
import { Button } from "@/components/ui/Button";
import { FilterChip } from "@/components/ui/Chip";
import { Icon } from "@/components/ui/Icon";
import { PhotoPlaceholder } from "@/components/ui/Media";
import { Stars } from "@/components/ui/Rating";
import { RatingInput } from "@/components/ui/RatingInput";
import { TabList } from "@/components/ui/Tabs";
import { useToast } from "@/components/ui/Toast";

interface ToLeave {
  id: string;
  productName: string;
  shopName: string;
  deliveredLabel: string;
  visual: Visual;
}
interface Published {
  id: string;
  product: string;
  shop: string;
  date: string;
  rating: number;
  text: string;
  reply: string | null;
}

/** Reviews to leave (form) & published reviews (W-Reviews). */
export function MyReviewsView({ toLeave, published, tags }: { toLeave: ToLeave[]; published: Published[]; tags: string[] }) {
  const [tab, setTab] = useState<"todo" | "done">("todo");
  const [selTags, setSelTags] = useState<string[]>(["Parfum agréable"]);
  const [open, setOpen] = useState<string | undefined>(toLeave[0]?.id);
  const toast = useToast();

  return (
    <div className="flex flex-col gap-[18px]">
      <h1 className="m-0 font-display text-[28px] font-extrabold tracking-[-0.025em] md:text-[36px]">Mes avis</h1>
      <TabList
        label="Avis"
        value={tab}
        onChange={setTab}
        items={[
          { value: "todo", label: `À laisser (${toLeave.length})` },
          { value: "done", label: `Publiés (${published.length + 2})` },
        ]}
      />
      {tab === "todo" ? (
        <div className="flex flex-col gap-3.5">
          {toLeave.map((r) =>
            r.id === open ? (
              <section key={r.id} className="grid gap-6 rounded-xl border-[1.5px] border-pomme-300 bg-white p-5 md:grid-cols-[220px_minmax(0,1fr)] md:gap-7 md:p-[22px]">
                <div className="flex flex-col gap-2.5">
                  <PhotoPlaceholder visual={r.visual} iconSize={48} className="aspect-[1.2] w-full" rounded="rounded-lg" />
                  <b className="text-[16px]">{r.productName}</b>
                  <span className="text-[13px] text-muted">
                    {r.shopName} · {r.deliveredLabel}
                  </span>
                </div>
                <form
                  className="flex flex-col gap-4"
                  onSubmit={(e) => {
                    e.preventDefault();
                    toast.show({ title: "Avis publié", description: "Merci, votre avis aide les autres acheteurs." });
                    setOpen(undefined);
                  }}
                >
                  <RatingInput defaultValue={4} />
                  <div className="flex flex-wrap gap-2" role="group" aria-label="Points forts">
                    {tags.map((t) => (
                      <FilterChip
                        key={t}
                        size="sm"
                        className="font-semibold"
                        selected={selTags.includes(t)}
                        onToggle={(on) => setSelTags(on ? [...selTags, t] : selTags.filter((x) => x !== t))}
                      >
                        {t}
                      </FilterChip>
                    ))}
                  </div>
                  <label htmlFor={`rv-${r.id}`} className="sr-only">
                    Commentaire
                  </label>
                  <textarea
                    id={`rv-${r.id}`}
                    rows={4}
                    placeholder="Goût, fraîcheur, emballage… Votre avis aide les autres acheteurs et le producteur."
                    className="resize-y rounded-md border-[1.5px] border-line-strong p-3 text-[15px] outline-none focus:border-pomme-600 focus:shadow-[0_0_0_4px_rgba(140,198,63,0.28)]"
                  />
                  <div className="flex flex-wrap items-center justify-between gap-3">
                    <button
                      type="button"
                      className="flex h-10 items-center gap-1.5 rounded-[10px] border-[1.5px] border-dashed border-lime bg-pomme-50 px-3 text-[13px] font-bold text-pomme-800"
                    >
                      <Icon name="camera" size={16} />
                      Ajouter des photos
                    </button>
                    <div className="flex gap-2.5">
                      <Button variant="ghost" className="text-[14px] text-muted" onClick={() => setOpen(undefined)}>
                        Plus tard
                      </Button>
                      <Button type="submit" className="px-5 text-[14px]">
                        Publier l’avis
                      </Button>
                    </div>
                  </div>
                </form>
              </section>
            ) : (
              <section key={r.id} className="flex flex-wrap items-center gap-4 rounded-xl border border-line bg-white px-5 py-[18px] md:px-[22px]">
                <PhotoPlaceholder visual={r.visual} iconSize={26} className="size-16" />
                <span className="flex min-w-0 flex-1 flex-col gap-0.5">
                  <b className="text-[16px]">{r.productName}</b>
                  <span className="text-[13px] text-muted">
                    {r.shopName} · {r.deliveredLabel}
                  </span>
                </span>
                <Stars value={0} size={26} className="hidden sm:inline-flex" emptyClassName="text-line-strong" />
                <Button variant="outline" size="md" className="h-10 border-pomme-300 text-[14px]" onClick={() => setOpen(r.id)}>
                  Écrire un avis
                </Button>
              </section>
            ),
          )}
        </div>
      ) : (
        <div className="grid gap-3.5 md:grid-cols-2">
          {published.map((r) => (
            <article key={r.id} className="flex flex-col gap-2 rounded-[18px] border border-line bg-white p-[18px]">
              <div className="flex justify-between gap-2">
                <b className="text-[15px]">{r.product}</b>
                <Stars value={r.rating} size={15} />
              </div>
              <span className="text-[12px] text-muted">
                {r.shop} · {r.date}
              </span>
              <p className="m-0 text-[14px] leading-[21px] text-text-soft">{r.text}</p>
              {r.reply && (
                <div className="rounded-[10px] bg-sand px-3 py-2.5 text-[13px] leading-[19px]">
                  <b className="block text-[12px] text-pomme-800">Réponse du vendeur</b>
                  {r.reply}
                </div>
              )}
            </article>
          ))}
        </div>
      )}
    </div>
  );
}
