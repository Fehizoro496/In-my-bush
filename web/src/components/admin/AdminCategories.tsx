"use client";
import { useActionState, useEffect, useState } from "react";
import type { AdminCategory } from "@/lib/api/admin-contract";
import { CATEGORY_STATE } from "@/lib/admin/labels";
import { deactivateCategory, moveCategory, reactivateCategory, saveCategory, type CategoryState } from "@/lib/admin/category-actions";
import { Button } from "@/components/ui/Button";
import { Icon, type IconName } from "@/components/ui/Icon";
import { Modal } from "@/components/ui/Modal";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { AdminTag } from "./AdminTag";

/** Icons offered for a category, shown in the catalogue navigation. */
export const CATEGORY_ICONS: IconName[] = ["leaf", "sprout", "basket", "package", "store", "pin", "heart", "star", "tag", "award", "layers", "grid", "truck"];
const initial: CategoryState = { error: "", success: "" };
const field = "rounded-lg border border-line bg-white p-2";

/** Top-level, active categories a category can be placed under. */
export const parentChoices = (all: AdminCategory[], category?: AdminCategory) =>
  all.filter(c => c.parentId === null && c.active && c.id !== category?.id);
/** Active categories that can receive the products of a deactivated one. */
export const replacementChoices = (all: AdminCategory[], category: AdminCategory) =>
  all.filter(c => c.active && c.id !== category.id && c.parentId !== category.id);
/** Whether the category can still move up or down among its siblings. */
export function canMove(all: AdminCategory[], category: AdminCategory) {
  const siblings = all.filter(c => c.parentId === category.parentId);
  const index = siblings.findIndex(c => c.id === category.id);
  return { up: index > 0, down: index >= 0 && index < siblings.length - 1 };
}

/** "Nouvelle catégorie" button, next to the page title. */
export function AdminCategoryCreate({ all }: { all: AdminCategory[] }) {
  const [open, setOpen] = useState(false);
  return <>
    <Button icon="plus" onClick={() => setOpen(true)}>Nouvelle catégorie</Button>
    <Modal open={open} onClose={() => setOpen(false)} title="Nouvelle catégorie">
      {open && <CategoryForm all={all} onDone={() => setOpen(false)} />}
    </Modal>
  </>;
}

/** Categories of one page, each sub-category under its parent, with ordering and moderation actions. */
export function AdminCategoriesTable({ items, all }: { items: AdminCategory[]; all: AdminCategory[] }) {
  const [editing, setEditing] = useState<AdminCategory | null>(null);
  const [closing, setClosing] = useState<AdminCategory | null>(null);
  return <>
    <Table fill minWidth={900}><THead><Th>Ordre</Th><Th>Nom</Th><Th>Catégorie parente</Th><Th>Lien</Th><Th>Icône</Th><Th>Produits</Th><Th>Statut</Th><Th>Action</Th></THead><tbody>
      {items.map(c => {
        const move = canMove(all, c);
        return <Tr key={c.id}>
          <Td><span className="flex gap-1"><MoveButton id={c.id} direction="UP" disabled={!move.up} /><MoveButton id={c.id} direction="DOWN" disabled={!move.down} /></span></Td>
          <Td className={c.parentId ? "w-1/5 max-w-0 truncate pl-8!" : "w-1/5 max-w-0 truncate font-bold"} title={c.name}>{c.name}</Td>
          <Td>{c.parentName ?? "—"}</Td>
          <Td className="w-1/6 max-w-0 truncate font-mono text-[12px]" title={c.slug}>{c.slug}</Td>
          <Td>{c.icon ? <Icon name={c.icon as IconName} size={18} /> : "—"}</Td>
          <Td>{c.productCount}</Td>
          <Td><AdminTag tags={CATEGORY_STATE} value={c.active ? "ACTIVE" : "INACTIVE"} /></Td>
          <Td><span className="flex gap-2">
            <Button size="sm" variant="neutral" onClick={() => setEditing(c)}>Modifier</Button>
            {c.active ? <Button size="sm" variant="neutral" onClick={() => setClosing(c)}>Désactiver</Button> : <ReactivateButton id={c.id} />}
          </span></Td>
        </Tr>;
      })}
    </tbody></Table>
    <Modal open={editing !== null} onClose={() => setEditing(null)} title="Modifier la catégorie">
      {editing && <CategoryForm key={editing.id} all={all} category={editing} onDone={() => setEditing(null)} />}
    </Modal>
    <Modal open={closing !== null} onClose={() => setClosing(null)} title={closing ? `Désactiver « ${closing.name} »` : ""}
      description="Elle disparaît du catalogue et ne peut plus recevoir de nouveaux produits.">
      {closing && <DeactivateForm key={closing.id} all={all} category={closing} onDone={() => setClosing(null)} />}
    </Modal>
  </>;
}

function useCategoryAction(action: typeof saveCategory, onDone?: () => void) {
  const [state, submit, pending] = useActionState(action, initial);
  useEffect(() => { if (state.success) onDone?.(); }, [state, onDone]);
  return { state, submit, pending };
}

function Feedback({ state }: { state: CategoryState }) {
  return state.error ? <p role="alert" className="text-danger-ink">{state.error}</p> : null;
}

function CategoryForm({ all, category, onDone }: { all: AdminCategory[]; category?: AdminCategory; onDone: () => void }) {
  const { state, submit, pending } = useCategoryAction(saveCategory, onDone);
  const [icon, setIcon] = useState(category?.icon ?? "");
  const hasChildren = !!category && all.some(c => c.parentId === category.id);
  return <form action={submit} className="flex flex-col gap-3 text-[14px]">
    {category && <input type="hidden" name="id" value={category.id} />}
    <label className="flex flex-col gap-1">Nom<input name="name" required minLength={2} maxLength={80} defaultValue={category?.name} className={field} /></label>
    <label className="flex flex-col gap-1">Lien dans l’adresse<input name="slug" maxLength={100} defaultValue={category?.slug} placeholder="Déduit du nom s’il est vide" className={field} /></label>
    <label className="flex flex-col gap-1">Catégorie parente
      <select name="parentId" defaultValue={category?.parentId ?? ""} disabled={hasChildren} className={field}>
        <option value="">Aucune (catégorie principale)</option>
        {parentChoices(all, category).map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
      </select>
      {hasChildren && <span className="text-muted">Elle a des sous-catégories : elle reste une catégorie principale.</span>}
    </label>
    <label className="flex flex-col gap-1">Icône
      <span className="flex items-center gap-3">
        <select name="icon" value={icon} onChange={e => setIcon(e.target.value)} className={`${field} flex-1`}>
          <option value="">Aucune</option>
          {CATEGORY_ICONS.map(name => <option key={name} value={name}>{name}</option>)}
        </select>
        <span aria-hidden className="flex size-10 items-center justify-center rounded-lg bg-pomme-100 text-pomme-700">{icon ? <Icon name={icon as IconName} size={20} /> : null}</span>
      </span>
    </label>
    <Feedback state={state} />
    <div className="flex justify-end gap-2"><Button type="submit" disabled={pending}>{category ? "Enregistrer" : "Créer la catégorie"}</Button></div>
  </form>;
}

function DeactivateForm({ all, category, onDone }: { all: AdminCategory[]; category: AdminCategory; onDone: () => void }) {
  const { state, submit, pending } = useCategoryAction(deactivateCategory, onDone);
  const activeChildren = all.filter(c => c.parentId === category.id && c.active);
  if (activeChildren.length) {
    return <p>Désactivez d’abord ses sous-catégories : {activeChildren.map(c => c.name).join(", ")}.</p>;
  }
  return <form action={submit} className="flex flex-col gap-3 text-[14px]">
    <input type="hidden" name="id" value={category.id} />
    {category.productCount > 0 ? <label className="flex flex-col gap-1">
      {category.productCount} produit(s) y sont rattachés. Ils seront déplacés vers :
      <select name="replacementId" required defaultValue="" className={field}>
        <option value="" disabled>Choisir une catégorie</option>
        {replacementChoices(all, category).map(c => <option key={c.id} value={c.id}>{c.parentName ? `${c.parentName} › ${c.name}` : c.name}</option>)}
      </select>
    </label> : <p>Aucun produit n’y est rattaché.</p>}
    <Feedback state={state} />
    <div className="flex justify-end"><Button type="submit" disabled={pending}>Désactiver</Button></div>
  </form>;
}

function ReactivateButton({ id }: { id: string }) {
  const { state, submit, pending } = useCategoryAction(reactivateCategory);
  return <form action={submit} className="flex items-center gap-2">
    <input type="hidden" name="id" value={id} />
    <Button type="submit" size="sm" variant="neutral" disabled={pending}>Réactiver</Button>
    {state.error && <span role="alert" className="max-w-48 truncate text-danger-ink" title={state.error}>{state.error}</span>}
  </form>;
}

function MoveButton({ id, direction, disabled }: { id: string; direction: "UP" | "DOWN"; disabled: boolean }) {
  const { submit, pending } = useCategoryAction(moveCategory);
  const label = direction === "UP" ? "Monter" : "Descendre";
  return <form action={submit}>
    <input type="hidden" name="id" value={id} /><input type="hidden" name="direction" value={direction} />
    <button type="submit" aria-label={label} title={label} disabled={disabled || pending}
      className="flex size-8 items-center justify-center rounded-lg border border-line-strong bg-white disabled:opacity-30">
      <Icon name={direction === "UP" ? "chevU" : "chevD"} size={16} />
    </button>
  </form>;
}
