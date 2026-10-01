"use client";

import { useState } from "react";
import type { AdminUserRow } from "@/lib/types";
import { Avatar } from "@/components/ui/Avatar";
import { StatusPill, type StatusTone } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { ChipGroup } from "@/components/ui/Chip";
import { Select, Textarea } from "@/components/ui/Form";
import { Icon } from "@/components/ui/Icon";
import { Modal } from "@/components/ui/Modal";
import { SimplePager } from "@/components/ui/Navigation";
import { Table, THead, Td, Th, Tr } from "@/components/ui/Table";
import { useToast } from "@/components/ui/Toast";

const STATUS: Record<AdminUserRow["status"], { label: string; tone: StatusTone }> = {
  ACTIVE: { label: "Actif", tone: "done" },
  VERIFYING: { label: "Vérification", tone: "warning" },
  SUSPENDED: { label: "Suspendu", tone: "danger" },
};

/** Users & sellers list with detail panel and suspend modal (A-Users). */
export function UsersAdmin({ users, tabs }: { users: AdminUserRow[]; tabs: { value: string; label: string; count: string }[] }) {
  const toast = useToast();
  const [tab, setTab] = useState("all");
  const [selId, setSelId] = useState(users[0]!.id);
  const [suspend, setSuspend] = useState(false);
  const shown = users.filter((u) =>
    tab === "all" ? true : tab === "buyers" ? !u.isSeller : tab === "sellers" ? u.isSeller : tab === "requests" ? u.status === "VERIFYING" : u.status === "SUSPENDED",
  );
  const u = users.find((x) => x.id === selId) ?? users[0]!;
  const s = STATUS[u.status];
  return (
    <div className="grid items-start gap-5 xl:grid-cols-[minmax(0,1fr)_340px]">
      <div className="flex min-w-0 flex-col gap-[18px]">
        <div className="flex flex-col gap-1">
          <h1 className="m-0 font-display text-[26px] font-extrabold tracking-[-0.02em] md:text-[30px]">Utilisateurs &amp; vendeurs</h1>
          <span className="text-[14px] text-muted">Un compte peut être acheteur et vendeur à la fois</span>
        </div>
        <ChipGroup
          label="Filtrer les utilisateurs"
          size="sm"
          value={tab}
          onChange={setTab}
          className="flex-nowrap overflow-x-auto scrollbar-none"
          options={tabs.map((t) => ({
            value: t.value,
            label: (
              <>
                {t.label} <span className="opacity-75">{t.count}</span>
              </>
            ),
          }))}
        />
        <section className="overflow-hidden rounded-[18px] border border-line bg-white">
          <div className="flex flex-wrap gap-2.5 border-b border-divider px-4 py-3">
            <label className="flex h-[38px] min-w-[200px] flex-1 items-center gap-2 rounded-[10px] border-[1.5px] border-line-strong px-3 text-[14px] text-muted">
              <Icon name="search" size={16} />
              <span className="sr-only">Rechercher un utilisateur</span>
              <input placeholder="Nom, e-mail, téléphone…" className="min-w-0 flex-1 border-0 bg-transparent text-ink outline-none focus-visible:outline-none" />
            </label>
            <Select aria-label="Région" size="sm" className="h-[38px] w-[130px] text-[13px] font-semibold" options={[{ value: "", label: "Région" }]} />
            <Select aria-label="Inscription" size="sm" className="h-[38px] w-[140px] text-[13px] font-semibold" options={[{ value: "", label: "Inscription" }]} />
          </div>
          <Table minWidth={680}>
            <THead>
              <Th>Utilisateur</Th>
              <Th>Rôles</Th>
              <Th>Inscrit</Th>
              <Th className="text-right">Commandes</Th>
              <Th>Statut</Th>
              <Th>
                <span className="sr-only">Détail</span>
              </Th>
            </THead>
            <tbody>
              {shown.map((r) => (
                <Tr key={r.id} selected={r.id === selId}>
                  <Td>
                    <div className="flex items-center gap-2.5">
                      <Avatar initials={r.initials} color={r.color} size={36} />
                      <div className="flex min-w-0 flex-col">
                        <b className="font-semibold">{r.name}</b>
                        <span className="text-[12px] text-muted">{r.emailMasked}</span>
                      </div>
                    </div>
                  </Td>
                  <Td>
                    <div className="flex gap-1">
                      <span className="inline-flex h-[22px] items-center rounded-[6px] bg-sand px-[7px] text-[11px] font-bold text-body">Acheteur</span>
                      {r.isSeller && (
                        <span className="inline-flex h-[22px] items-center gap-[3px] rounded-[6px] bg-mint px-[7px] text-[11px] font-bold text-pomme-800">
                          <Icon name="store" size={11} />
                          Vendeur
                        </span>
                      )}
                    </div>
                  </Td>
                  <Td className="text-[13px] text-body">{r.since}</Td>
                  <Td className="text-right font-tabular">{r.orders}</Td>
                  <Td>
                    <StatusPill tone={STATUS[r.status].tone} size="sm">
                      {STATUS[r.status].label}
                    </StatusPill>
                  </Td>
                  <Td>
                    <button
                      type="button"
                      aria-label={`Voir le détail de ${r.name}`}
                      aria-pressed={r.id === selId}
                      onClick={() => setSelId(r.id)}
                      className="flex size-[34px] items-center justify-center rounded-lg border-[1.5px] border-line-strong bg-white text-body"
                    >
                      <Icon name="chevR" size={17} />
                    </button>
                  </Td>
                </Tr>
              ))}
            </tbody>
          </Table>
          <SimplePager summary="1–9 sur 12 480" />
        </section>
      </div>

      <aside aria-label="Détail utilisateur" className="flex flex-col gap-4 rounded-[18px] border border-line bg-white p-5 xl:sticky xl:top-[92px]">
        <div className="flex items-start justify-between">
          <Avatar initials={u.initials} color={u.color} size={56} display />
          <StatusPill tone={s.tone} size="sm">
            {s.label}
          </StatusPill>
        </div>
        <div className="flex flex-col gap-0.5">
          <b className="font-display text-[20px]">{u.name}</b>
          <span className="text-[13px] text-muted">
            {u.emailMasked} · inscrit {u.since}
          </span>
        </div>
        <dl className="m-0 grid grid-cols-2 gap-2">
          <div className="rounded-md bg-bg px-3 py-2.5">
            <dt className="text-[12px] text-muted">Achats</dt>
            <dd className="m-0 text-[18px] font-extrabold">{u.orders}</dd>
          </div>
          <div className="rounded-md bg-bg px-3 py-2.5">
            <dt className="text-[12px] text-muted">Ventes (30 j)</dt>
            <dd className="m-0 text-[18px] font-extrabold">{u.sales30d}</dd>
          </div>
        </dl>
        <div className="flex flex-col gap-2">
          <b className="text-[14px]">Vérifications vendeur</b>
          {[
            ["Téléphone vérifié", true],
            ["Pièce d’identité", true],
            ["Exploitation (photos, adresse)", u.status !== "VERIFYING"],
          ].map(([t, ok]) => (
            <div key={String(t)} className="flex items-center gap-2.5 text-[13px]">
              <Icon name={ok ? "checkCircle" : "clock"} size={17} className={ok ? "text-pomme-700" : "text-orange-700"} />
              <span className="flex-1">{t}</span>
              <span className={`text-[12px] font-bold ${ok ? "text-pomme-700" : "text-orange-700"}`}>{ok ? "OK" : "À vérifier"}</span>
            </div>
          ))}
        </div>
        <div className="flex flex-col gap-2 border-t border-divider pt-3">
          <Button icon="shield" className="h-[42px] text-[14px]" onClick={() => toast.show({ title: "Profil vendeur validé", description: u.name })}>
            Valider le profil vendeur
          </Button>
          <div className="grid grid-cols-2 gap-2">
            <Button variant="neutral" icon="mail" className="h-[42px] px-2 text-[13px]">
              Contacter
            </Button>
            <Button variant="danger-outline" icon="ban" className="h-[42px] px-2 text-[13px]" onClick={() => setSuspend(true)}>
              Suspendre
            </Button>
          </div>
          <Button variant="ghost" icon="trash" className="h-[38px] text-[13px] text-danger-ink hover:bg-danger-bg hover:text-danger-ink">
            Supprimer le compte
          </Button>
        </div>
      </aside>

      <Modal
        open={suspend}
        onClose={() => setSuspend(false)}
        icon="ban"
        title={u.isSeller ? "Suspendre ce vendeur ?" : "Suspendre cet utilisateur ?"}
        description={
          u.isSeller
            ? "Ses produits seront masqués de la marketplace. Les commandes en cours restent honorées. Le vendeur sera notifié."
            : "Le compte ne pourra plus passer commande. L’utilisateur sera notifié."
        }
        footer={
          <>
            <Button variant="neutral" onClick={() => setSuspend(false)}>
              Annuler
            </Button>
            <Button
              variant="danger"
              onClick={() => {
                // TODO(api): adminApi.userAction(u.id, "suspend", reason)
                setSuspend(false);
                toast.show({ tone: "info", title: "Compte suspendu", description: u.name });
              }}
            >
              Suspendre
            </Button>
          </>
        }
      >
        <Textarea label="Motif (visible par l’utilisateur)" rows={2} placeholder="Ex. : commandes non livrées" />
      </Modal>
    </div>
  );
}
