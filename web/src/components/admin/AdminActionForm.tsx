"use client";
import { useActionState, useEffect, useState } from "react";
import { adminMutation } from "@/lib/admin/actions";
import { Button } from "@/components/ui/Button";
import { Modal } from "@/components/ui/Modal";

type AdminAction = { value: string; label: string };

/**
 * Moderation buttons of a backoffice item, with a reason field when the action needs one.
 * `compact` keeps a table row on one line: the buttons open a dialog that asks for the reason.
 */
export function AdminActionForm({ id, actions, reason = false, compact = false, onDone }: {
  id: string; actions: AdminAction[]; reason?: boolean; compact?: boolean;
  /** Called once the change is saved, e.g. to close the popup holding the form. */
  onDone?: () => void;
}) {
  if (compact) return <AdminActionDialog id={id} actions={actions} reason={reason} />;
  return <ActionForm id={id} actions={actions} reason={reason} onDone={onDone} />;
}

function ActionForm({ id, actions, reason, onDone }: {
  id: string; actions: AdminAction[]; reason: boolean; onDone?: () => void;
}) {
  const [state, submit, pending] = useActionState(adminMutation, { error: "", success: "" });
  useEffect(() => { if (state.success) onDone?.(); }, [state, onDone]);
  return <form action={submit} className="flex flex-col gap-2">
    <input type="hidden" name="id" value={id} />
    {reason && <textarea name="reason" aria-label="Motif ou note" placeholder="Motif ou note (500 caractères maximum)" maxLength={500} className="rounded-lg border border-line p-2" />}
    <div className="flex flex-wrap gap-2">{actions.map(a => <Button key={a.value} type="submit" name="action" value={a.value} disabled={pending} size="sm" variant="neutral">{a.label}</Button>)}</div>
    {state.error && <p role="alert" className="text-danger-ink">{state.error}</p>}
    {state.success && <p role="status" className="text-pomme-700">{state.success}</p>}
  </form>;
}

function AdminActionDialog({ id, actions, reason }: { id: string; actions: AdminAction[]; reason: boolean }) {
  const [chosen, setChosen] = useState<AdminAction | null>(null);
  return <div className="flex gap-2">
    {actions.map(a => <Button key={a.value} size="sm" variant="neutral" onClick={() => setChosen(a)}>{a.label}</Button>)}
    <Modal open={chosen !== null} onClose={() => setChosen(null)} title={chosen?.label}>
      {chosen && <ActionForm key={chosen.value} id={id} actions={[chosen]} reason={reason} onDone={() => setChosen(null)} />}
    </Modal>
  </div>;
}
