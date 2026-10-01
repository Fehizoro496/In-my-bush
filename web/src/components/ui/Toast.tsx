"use client";

import { createContext, useCallback, useContext, useMemo, useRef, useState, type ReactNode } from "react";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "./Icon";

export type ToastTone = "success" | "error" | "info" | "warning";

export interface ToastOptions {
  title: string;
  description?: string;
  tone?: ToastTone;
  action?: { label: string; onClick: () => void };
  /** ms, default 4000 */
  duration?: number;
}

interface ToastEntry extends ToastOptions {
  id: number;
}

const TONES: Record<ToastTone, { box: string; iconBg: string; icon: IconName; action: string }> = {
  success: { box: "bg-ink text-white", iconBg: "bg-pomme-500 text-on-primary", icon: "check", action: "text-lime" },
  error: { box: "bg-white text-ink", iconBg: "bg-[#FCEBE9] text-danger-fg", icon: "x", action: "text-danger-fg" },
  info: { box: "bg-white text-ink", iconBg: "bg-info-bg text-info-strong", icon: "info", action: "text-info-strong" },
  warning: { box: "bg-white text-ink", iconBg: "bg-orange-100 text-orange-700", icon: "alert", action: "text-orange-700" },
};

/** Visual toast (also usable statically, e.g. in the design-system page). */
export function Toast({
  title,
  description,
  tone = "success",
  action,
  onClose,
  className,
}: ToastOptions & { onClose?: () => void; className?: string }) {
  const t = TONES[tone];
  return (
    <div
      role="status"
      className={cn(
        "flex items-center gap-3 rounded-[14px] py-3 pr-3 pl-3.5 shadow-[0_10px_28px_rgba(31,35,24,0.14)]",
        t.box,
        className,
      )}
    >
      <span className={cn("flex size-8 shrink-0 items-center justify-center rounded-full", t.iconBg)}>
        <Icon name={t.icon} size={18} />
      </span>
      <div className="flex flex-1 flex-col gap-px">
        <b className="text-[14px]">{title}</b>
        {description && <span className="text-[13px] opacity-85">{description}</span>}
      </div>
      {action && (
        <button type="button" onClick={action.onClick} className={cn("h-9 rounded-lg px-3 text-[14px] font-bold", t.action)}>
          {action.label}
        </button>
      )}
      {onClose && (
        <button
          type="button"
          aria-label="Fermer"
          onClick={onClose}
          className="flex size-9 items-center justify-center rounded-lg opacity-70 hover:opacity-100"
        >
          <Icon name="x" size={16} />
        </button>
      )}
    </div>
  );
}

const ToastContext = createContext<{ show: (t: ToastOptions) => void } | null>(null);

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<ToastEntry[]>([]);
  const nextId = useRef(1);
  const dismiss = useCallback((id: number) => setToasts((all) => all.filter((t) => t.id !== id)), []);
  const show = useCallback(
    (t: ToastOptions) => {
      const id = nextId.current++;
      setToasts((all) => [...all.slice(-2), { ...t, id }]);
      window.setTimeout(() => dismiss(id), t.duration ?? 4000);
    },
    [dismiss],
  );
  const value = useMemo(() => ({ show }), [show]);
  return (
    <ToastContext.Provider value={value}>
      {children}
      <div
        aria-live="polite"
        className="pointer-events-none fixed inset-x-4 bottom-24 z-[200] flex flex-col items-center gap-2 md:right-6 md:bottom-6 md:left-auto md:items-end"
      >
        {toasts.map((t) => (
          <Toast key={t.id} {...t} onClose={() => dismiss(t.id)} className="animate-pop pointer-events-auto w-full max-w-[400px]" />
        ))}
      </div>
    </ToastContext.Provider>
  );
}

/** Returns `show(toast)`; a no-op outside the provider. */
export function useToast() {
  return useContext(ToastContext) ?? { show: () => {} };
}
