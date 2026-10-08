"use client";

import Link from "next/link";
import { useRef, useState } from "react";
import { cn } from "@/lib/cn";
import type { Conversation, Message, MessageContext } from "@/lib/types";
import { Avatar } from "@/components/ui/Avatar";
import { Icon } from "@/components/ui/Icon";
import { TabList } from "@/components/ui/Tabs";
import { ROUTES } from "@/lib/routing/routes";

/** Conversations list · chat thread · context panel (W-Messages). */
export function MessagesView({ conversations, messages }: { conversations: Conversation[]; messages: Record<string, Message[]> }) {
  const [ctx, setCtx] = useState<MessageContext>("PURCHASE");
  const list = conversations.filter((c) => c.context === ctx);
  const [selId, setSelId] = useState<string | null>(list[0]?.id ?? null);
  const [mobileThread, setMobileThread] = useState(false);
  const [sent, setSent] = useState<Record<string, Message[]>>({});
  const [draft, setDraft] = useState("");
  const [q, setQ] = useState("");
  const nextId = useRef(1);

  const current = list.find((c) => c.id === selId) ?? list[0];
  const thread = current ? [...(messages[current.id] ?? [{ id: "x", conversationId: current.id, body: current.lastMessage.replace(/^Vous : /, ""), time: current.lastMessageAt, mine: current.lastMessage.startsWith("Vous") }]), ...(sent[current.id] ?? [])] : [];
  const unread = (c: MessageContext) => conversations.filter((x) => x.context === c && x.unread).length;
  const shown = list.filter((c) => `${c.counterpart.name} ${c.topic}`.toLowerCase().includes(q.toLowerCase()));

  const send = () => {
    if (!current || !draft.trim()) return;
    // TODO(api): messagesApi.send(current.id, draft)
    setSent({ ...sent, [current.id]: [...(sent[current.id] ?? []), { id: `local-${nextId.current++}`, conversationId: current.id, body: draft.trim(), time: "à l’instant", mine: true }] });
    setDraft("");
  };

  return (
    <div className="grid min-h-[640px] overflow-hidden rounded-xl border border-line md:grid-cols-[320px_minmax(0,1fr)] lg:h-[calc(100dvh-128px-56px)] lg:min-h-[600px] xl:grid-cols-[360px_minmax(0,1fr)_300px]">
      <section aria-label="Conversations" className={cn("flex min-h-0 flex-col bg-white md:border-r md:border-line", mobileThread && "hidden md:flex")}>
        <div className="flex flex-col gap-3 border-b border-divider px-[18px] pt-[18px] pb-3">
          <h1 className="m-0 font-display text-[26px] font-extrabold">Messages</h1>
          <TabList
            variant="segmented"
            size="sm"
            fullWidth
            label="Contexte"
            value={ctx}
            onChange={(v) => {
              setCtx(v);
              setSelId(conversations.find((c) => c.context === v)?.id ?? null);
            }}
            items={[
              { value: "PURCHASE", label: "Mes achats", count: unread("PURCHASE") || undefined, icon: "basket" },
              { value: "SALE", label: "Mes ventes", count: unread("SALE") || undefined, icon: "store" },
            ]}
          />
          <label className="flex h-10 items-center gap-2 rounded-[10px] border-[1.5px] border-line-strong px-3 text-[14px] text-muted">
            <Icon name="search" size={16} />
            <span className="sr-only">Rechercher une conversation</span>
            <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Rechercher" className="min-w-0 flex-1 border-0 bg-transparent text-ink outline-none focus-visible:outline-none" />
          </label>
        </div>
        <ul className="m-0 flex-1 list-none overflow-y-auto p-0">
          {shown.map((c) => {
            const on = current?.id === c.id;
            return (
              <li key={c.id}>
                <button
                  type="button"
                  aria-current={on ? "true" : undefined}
                  onClick={() => {
                    setSelId(c.id);
                    setMobileThread(true);
                  }}
                  className={cn("flex w-full gap-3 border-b border-divider px-[18px] py-3.5 text-left text-ink", on ? "bg-pomme-50" : "bg-white hover:bg-bg")}
                >
                  <Avatar initials={c.counterpart.initials} color={c.counterpart.color} size={44} />
                  <span className="flex min-w-0 flex-1 flex-col gap-0.5">
                    <span className="flex justify-between gap-2">
                      <b className="text-[14px]">{c.counterpart.name}</b>
                      <span className="text-[12px] text-muted">{c.lastMessageAt}</span>
                    </span>
                    <span className="text-[12px] font-semibold text-pomme-700">{c.topic}</span>
                    <span className={cn("truncate text-[13px]", c.unread ? "font-semibold text-ink" : "text-muted")}>{c.lastMessage}</span>
                  </span>
                </button>
              </li>
            );
          })}
        </ul>
      </section>

      <section aria-label="Conversation" className={cn("min-h-0 flex-col bg-admin-bg", mobileThread ? "flex" : "hidden md:flex")}>
        {current && (
          <>
            <div className="flex items-center gap-3 border-b border-line bg-white px-4 py-3.5 md:px-5">
              <button type="button" aria-label="Retour aux conversations" onClick={() => setMobileThread(false)} className="flex size-10 items-center justify-center rounded-[10px] md:hidden">
                <Icon name="arrowL" size={20} />
              </button>
              <Avatar initials={current.counterpart.initials} color={current.counterpart.color} size={40} />
              <div className="flex flex-1 flex-col">
                <b className="text-[15px]">{current.counterpart.name}</b>
                <span className="flex items-center gap-1 text-[12px] text-pomme-700">
                  <span className="size-[7px] rounded-full bg-pomme-600" />
                  En ligne
                </span>
              </div>
              <button type="button" aria-label="Plus d’options" className="flex size-10 items-center justify-center rounded-[10px] text-body hover:bg-sand">
                <Icon name="more" size={18} />
              </button>
            </div>
            <div className="flex flex-1 flex-col gap-2.5 overflow-y-auto p-4 md:p-5" aria-live="polite">
              <div className="self-center rounded-full bg-[#EDEAE1] px-2.5 py-1 text-[12px] text-muted">Aujourd’hui</div>
              {thread.map((m) => (
                <div key={m.id} className={cn("flex flex-col gap-[3px]", m.mine ? "items-end" : "items-start")}>
                  <div
                    className={cn(
                      "max-w-[85%] px-3.5 py-2.5 text-[15px] leading-[22px] md:max-w-[70%]",
                      m.mine ? "rounded-[16px_16px_4px_16px] bg-mint" : "rounded-[16px_16px_16px_4px] border border-line bg-white",
                    )}
                  >
                    {m.body}
                  </div>
                  <span className="text-[11px] text-muted">{m.time}</span>
                </div>
              ))}
            </div>
            <form
              className="flex items-center gap-2.5 border-t border-line bg-white px-3 py-3 md:px-4"
              onSubmit={(e) => {
                e.preventDefault();
                send();
              }}
            >
              <button type="button" aria-label="Joindre une photo" className="flex size-11 shrink-0 items-center justify-center rounded-md bg-sand text-ink">
                <Icon name="camera" size={19} />
              </button>
              <label htmlFor="chat-input" className="sr-only">
                Message
              </label>
              <input
                id="chat-input"
                value={draft}
                onChange={(e) => setDraft(e.target.value)}
                placeholder="Écrire un message…"
                className="h-11 min-w-0 flex-1 rounded-[22px] border-[1.5px] border-line-strong bg-bg px-4 text-[15px] outline-none focus:border-pomme-600"
              />
              <button type="submit" className="flex h-11 shrink-0 items-center gap-1.5 rounded-[22px] bg-pomme-500 px-4 text-[14px] font-bold text-on-primary md:px-[18px]">
                <span className="hidden sm:inline">Envoyer</span>
                <Icon name="arrowR" size={16} />
              </button>
            </form>
          </>
        )}
      </section>

      <aside className="hidden flex-col gap-3.5 border-l border-line bg-white p-5 xl:flex">
        <span className="overline text-muted">À propos de cet échange</span>
        {current?.order && (
          <Link href={ROUTES.accountOrder("ord-24817")} className="flex items-center gap-2.5 rounded-[14px] border border-line p-3 text-ink no-underline hover:text-ink">
            <span className="flex size-11 items-center justify-center rounded-[10px] bg-[#FDE6CC] text-orange-700">
              <Icon name="package" size={20} />
            </span>
            <span className="flex flex-col">
              <b className="text-[14px]">Commande {current.order.number}</b>
              <span className="text-[12px] text-muted">{current.order.label}</span>
            </span>
          </Link>
        )}
        {current?.shopSlug && (
          <Link
            href={ROUTES.shop(current.shopSlug)}
            className="flex h-[42px] items-center justify-center gap-1.5 rounded-[10px] bg-pomme-100 text-[14px] font-bold text-pomme-800 no-underline"
          >
            <Icon name="store" size={16} />
            Voir la boutique
          </Link>
        )}
        <div className="mt-auto flex gap-2 text-[12px] leading-[18px] text-muted">
          <Icon name="shield" size={16} className="text-pomme-700" />
          Restez sur In my bush pour payer : votre achat n’est protégé que sur la plateforme.
        </div>
      </aside>
    </div>
  );
}
