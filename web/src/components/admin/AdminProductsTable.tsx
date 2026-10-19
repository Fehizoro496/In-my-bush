"use client";
import { useState } from "react";
import type { AdminProduct } from "@/lib/api/admin-contract";
import { PRODUCT_STATUS } from "@/lib/admin/labels";
import { formatAriary } from "@/lib/format";
import { Modal } from "@/components/ui/Modal";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { AdminActionForm } from "./AdminActionForm";
import { AdminTag } from "./AdminTag";

/** A product of the moderation list, with its submission date already formatted by the server. */
export type AdminProductRow = AdminProduct & { submitted: string };

/** Products to moderate, one per row; tapping a row opens its full sheet and the moderation actions. */
export function AdminProductsTable({ items }: { items: AdminProductRow[] }) {
  const [open, setOpen] = useState<AdminProductRow | null>(null);
  return <>
    <Table fill minWidth={900}><THead><Th>Produit</Th><Th>Boutique</Th><Th>Catégorie</Th><Th>Prix</Th><Th>Stock</Th><Th>Statut</Th><Th>Soumis le</Th></THead><tbody>
      {items.map(p => <Tr key={p.id} tabIndex={0} aria-label={`Voir la fiche de ${p.name}`} className="cursor-pointer hover:bg-bg focus-visible:bg-bg"
        onClick={() => setOpen(p)} onKeyDown={e => { if (e.key === "Enter" || e.key === " ") { e.preventDefault(); setOpen(p); } }}>
        <Td className="w-1/4 max-w-0 truncate font-bold" title={p.name}>{p.name}</Td>
        <Td className="w-1/6 max-w-0 truncate" title={p.shop.name}>{p.shop.name}</Td>
        <Td className="w-1/6 max-w-0 truncate" title={p.category.name}>{p.category.name}</Td>
        <Td>{formatAriary(p.price)} / {p.unitLabel}</Td><Td>{p.stock}</Td>
        <Td><AdminTag tags={PRODUCT_STATUS} value={p.status} /></Td><Td>{p.submitted}</Td>
      </Tr>)}
    </tbody></Table>
    <Modal open={open !== null} onClose={() => setOpen(null)} title={open?.name} width={640}
      description={open && `${open.shop.name} · ${open.category.name} · soumis le ${open.submitted}`}>
      {open && <ProductSheet key={open.id} product={open} onDone={() => setOpen(null)} />}
    </Modal>
  </>;
}

function ProductSheet({ product: p, onDone }: { product: AdminProductRow; onDone: () => void }) {
  const photos = p.images.filter(url => /^https?:\/\//.test(url));
  return <div className="flex flex-col gap-4 text-[14px]">
    <dl className="grid grid-cols-3 gap-3">
      <div><dt className="text-muted">Prix</dt><dd className="font-bold">{formatAriary(p.price)} / {p.unitLabel}</dd></div>
      <div><dt className="text-muted">Stock</dt><dd className="font-bold">{p.stock}</dd></div>
      <div><dt className="text-muted">Statut</dt><dd><AdminTag tags={PRODUCT_STATUS} value={p.status} /></dd></div>
    </dl>
    <section><h3 className="mb-1 font-bold">Description</h3><p className="whitespace-pre-wrap">{p.description || "—"}</p></section>
    <section><h3 className="mb-1 font-bold">Photos</h3>
      {photos.length ? <div className="flex flex-wrap gap-2">{photos.map((url, i) =>
        <a key={url} href={url} target="_blank" rel="noopener noreferrer" className="rounded-lg border border-line px-3 py-1.5 font-semibold">Photo {i + 1}</a>)}</div>
        : <p className="text-muted">Aucune photo.</p>}
    </section>
    {p.rejectionReason && <p className="rounded-lg bg-danger-bg p-3 text-danger-ink">Motif du refus : {p.rejectionReason}</p>}
    {p.status === "PENDING_REVIEW" && <AdminActionForm id={p.id} reason onDone={onDone} actions={[{ value: "approve", label: "Approuver" }, { value: "reject", label: "Refuser" }]} />}
  </div>;
}
