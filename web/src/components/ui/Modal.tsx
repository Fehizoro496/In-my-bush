"use client";

import { useEffect, useId, useRef, type ReactNode } from "react";
import { createPortal } from "react-dom";
import { cn } from "@/lib/cn";
import { useIsClient } from "@/lib/useIsClient";
import { Icon, type IconName } from "./Icon";

function useDialogBehaviour(open: boolean, onClose: () => void) {
  const panelRef = useRef<HTMLDivElement>(null);
  const onCloseRef = useRef(onClose);
  useEffect(() => {
    onCloseRef.current = onClose;
  });
  useEffect(() => {
    if (!open) return;
    const previous = document.activeElement as HTMLElement | null;
    const panel = panelRef.current;
    const focusables = () =>
      Array.from(
        panel?.querySelectorAll<HTMLElement>(
          'a[href],button:not([disabled]),textarea,input:not([disabled]),select,[tabindex]:not([tabindex="-1"])',
        ) ?? [],
      );
    (focusables()[0] ?? panel)?.focus();
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onCloseRef.current();
      if (e.key === "Tab") {
        const els = focusables();
        if (els.length === 0) return;
        const first = els[0]!;
        const last = els[els.length - 1]!;
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    };
    document.addEventListener("keydown", onKey);
    const overflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = overflow;
      previous?.focus?.();
    };
  }, [open]);
  return panelRef;
}

export interface ModalProps {
  open: boolean;
  onClose: () => void;
  title: ReactNode;
  description?: ReactNode;
  /** Icon tile shown at the top-left (e.g. "ban" for destructive actions). */
  icon?: IconName;
  iconTone?: "danger" | "pomme" | "warning";
  /** Custom leading visual (replaces `icon`). */
  leading?: ReactNode;
  children?: ReactNode;
  footer?: ReactNode;
  width?: number;
  className?: string;
}

/** Centered modal dialog (focus trap, Escape to close, scroll lock). */
export function Modal({
  open,
  onClose,
  title,
  description,
  icon,
  iconTone = "danger",
  leading,
  children,
  footer,
  width = 520,
  className,
}: ModalProps) {
  const panelRef = useDialogBehaviour(open, onClose);
  const titleId = useId();
  const descId = useId();
  const isClient = useIsClient();
  if (!open || !isClient) return null;
  const tone = {
    danger: "bg-[#FCEBE9] text-danger-fg",
    pomme: "bg-pomme-100 text-pomme-700",
    warning: "bg-orange-100 text-orange-700",
  }[iconTone];
  return createPortal(
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center bg-[rgba(31,35,24,0.45)] p-4"
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        ref={panelRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        aria-describedby={description ? descId : undefined}
        tabIndex={-1}
        className={cn(
          "animate-pop flex max-h-[calc(100dvh-32px)] w-full flex-col gap-4 overflow-y-auto rounded-xl bg-white p-6 shadow-[0_16px_40px_rgba(31,35,24,0.25)]",
          className,
        )}
        style={{ maxWidth: width }}
      >
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-3.5">
            {leading ??
              (icon && (
                <span className={cn("flex size-11 shrink-0 items-center justify-center rounded-md", tone)}>
                  <Icon name={icon} size={22} />
                </span>
              ))}
            {(leading || !icon) && (
              <div className="flex flex-col gap-0.5">
                <h2 id={titleId} className="m-0 font-display text-[22px] font-bold">
                  {title}
                </h2>
                {description && (
                  <p id={descId} className="m-0 text-[14px] text-muted">
                    {description}
                  </p>
                )}
              </div>
            )}
          </div>
          <button
            type="button"
            aria-label="Fermer"
            onClick={onClose}
            className="flex size-10 shrink-0 items-center justify-center rounded-[10px] text-muted hover:bg-sand"
          >
            <Icon name="x" size={20} />
          </button>
        </div>
        {icon && !leading && (
          <div className="-mt-1 flex flex-col gap-1.5">
            <h2 id={titleId} className="m-0 font-display text-[22px] font-bold">
              {title}
            </h2>
            {description && (
              <p id={descId} className="m-0 text-[15px] leading-[22px] text-body">
                {description}
              </p>
            )}
          </div>
        )}
        {children}
        {footer && <div className="flex flex-wrap items-center justify-end gap-2.5 pt-1">{footer}</div>}
      </div>
    </div>,
    document.body,
  );
}

/** Side drawer (filters on tablet/phone, admin navigation). */
export function Drawer({
  open,
  onClose,
  title,
  side = "right",
  children,
  footer,
  width = 380,
  dark,
}: {
  open: boolean;
  onClose: () => void;
  title: ReactNode;
  side?: "left" | "right";
  children: ReactNode;
  footer?: ReactNode;
  width?: number;
  dark?: boolean;
}) {
  const panelRef = useDialogBehaviour(open, onClose);
  const titleId = useId();
  const isClient = useIsClient();
  if (!open || !isClient) return null;
  return createPortal(
    <div
      className="fixed inset-0 z-[100] flex bg-[rgba(31,35,24,0.45)]"
      style={{ justifyContent: side === "right" ? "flex-end" : "flex-start" }}
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        ref={panelRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className={cn(
          "flex h-full w-full flex-col shadow-[0_16px_40px_rgba(31,35,24,0.25)]",
          dark ? "bg-admin-sidebar text-[#E4EBD6]" : "bg-white",
        )}
        style={{ maxWidth: width }}
      >
        <div className={cn("flex items-center justify-between gap-3 px-5 py-4", !dark && "border-b border-divider")}>
          <h2 id={titleId} className="m-0 text-[17px] font-bold">
            {title}
          </h2>
          <button
            type="button"
            aria-label="Fermer"
            onClick={onClose}
            className={cn(
              "flex size-11 items-center justify-center rounded-[10px]",
              dark ? "text-[#C5D0B5] hover:bg-white/10" : "text-muted hover:bg-sand",
            )}
          >
            <Icon name="x" size={20} />
          </button>
        </div>
        <div className="flex-1 overflow-y-auto">{children}</div>
        {footer && <div className="border-t border-divider p-4">{footer}</div>}
      </div>
    </div>,
    document.body,
  );
}
