"use client";

import { useState } from "react";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "@/components/ui/Icon";

interface Method {
  id: string;
  title: string;
  detail: string;
  icon: IconName;
  bg: string;
  ink: string;
  isDefault: boolean;
}

/** Selectable list of payment methods (default one highlighted). */
export function PaymentMethods({ methods }: { methods: Method[] }) {
  const [def, setDef] = useState(methods.find((m) => m.isDefault)?.id);
  return (
    <div role="radiogroup" aria-label="Moyen de paiement par défaut" className="flex flex-col gap-3">
      {methods.map((m) => {
        const on = m.id === def;
        return (
          <button
            key={m.id}
            type="button"
            role="radio"
            aria-checked={on}
            onClick={() => setDef(m.id)}
            className={cn("flex items-center gap-3 rounded-[14px] bg-white p-3.5 text-left text-ink", on ? "border-[1.5px] border-pomme-500" : "border border-line")}
          >
            <span className="flex h-[34px] w-12 items-center justify-center rounded-lg" style={{ background: m.bg, color: m.ink }}>
              <Icon name={m.icon} size={20} />
            </span>
            <span className="flex min-w-0 flex-1 flex-col">
              <b className="text-[15px]">{m.title}</b>
              <span className="text-[13px] text-muted">{m.detail}</span>
            </span>
            {on && <span className="inline-flex h-6 items-center rounded-[6px] bg-mint px-2 text-[12px] font-bold text-pomme-800">Par défaut</span>}
            <Icon name="more" size={18} className="text-muted" />
          </button>
        );
      })}
    </div>
  );
}
