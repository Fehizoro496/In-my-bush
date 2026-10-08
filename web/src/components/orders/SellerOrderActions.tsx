"use client";

import { useState } from "react";
import type { OrderStatus, SellerOrderDetail } from "@/lib/types";
import { Alert } from "@/components/ui/Feedback";
import { OrderStatusPill } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Modal } from "@/components/ui/Modal";
import { Breadcrumb, StepBar } from "@/components/ui/Navigation";
import { Textarea } from "@/components/ui/Form";
import { useToast } from "@/components/ui/Toast";
import { ROUTES } from "@/lib/routing/routes";

const FLOW: OrderStatus[] = ["PENDING_CONFIRMATION", "ACCEPTED", "PREPARED", "IN_DELIVERY", "DELIVERED"];
const CTA = ["Accepter la commande", "Marquer comme préparée", "Remettre au livreur", "Confirmer la livraison", "Commande terminée"];
const STEPS = [
  { label: "Reçue", detail: "Aujourd’hui 9h12" },
  { label: "Acceptée", detail: "Avant 14h" },
  { label: "Préparée", detail: "Emballer, étiqueter" },
  { label: "Remise au livreur", detail: "Demain matin" },
  { label: "Livrée", detail: "Paiement libéré" },
];

/**
 * Header + status workflow of a received order (W-Order-Received).
 * Each click calls POST /seller/orders/{id}/{accept|prepare|ship|deliver} (stubbed here).
 */
export function SellerOrderHeader({ order }: { order: SellerOrderDetail }) {
  const [status, setStatus] = useState<OrderStatus>(order.status);
  const [refuse, setRefuse] = useState(false);
  const toast = useToast();
  const idx = Math.max(0, FLOW.indexOf(status));
  const isNew = status === "PENDING_CONFIRMATION";
  const done = status === "DELIVERED";
  const refused = status === "REFUSED";

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div className="flex flex-col gap-1.5">
          <Breadcrumb items={[{ label: "Commandes reçues", href: ROUTES.sellerOrders }, { label: order.number }]} />
          <div className="flex flex-wrap items-center gap-3">
            <h1 className="m-0 font-display text-[28px] font-extrabold tracking-[-0.025em] md:text-[34px]">{order.number}</h1>
            <OrderStatusPill status={status} side="seller" />
          </div>
          <span className="text-[14px] text-muted">{order.receivedLabel}</span>
        </div>
        <div className="flex flex-wrap gap-2.5">
          <Button variant="neutral" icon="receipt" className="px-3.5 text-[14px]">
            Bon de préparation
          </Button>
          {isNew && (
            <Button variant="danger-outline" className="px-3.5 text-[14px]" onClick={() => setRefuse(true)}>
              Refuser
            </Button>
          )}
          {!refused && (
            <Button
              className="text-[14px]"
              disabled={done}
              onClick={() => {
                const next = FLOW[Math.min(FLOW.length - 1, idx + 1)]!;
                setStatus(next);
                toast.show({ title: CTA[idx]!, description: `${order.number} · statut mis à jour` });
              }}
            >
              {CTA[idx]}
            </Button>
          )}
        </div>
      </div>
      {isNew && (
        <Alert tone="warning" icon="clock" className="border border-orange-300">
          <b>À confirmer avant {order.acceptBefore}</b> pour honorer la livraison de demain matin. Sans réponse, la commande est annulée et remboursée.
        </Alert>
      )}
      {refused && (
        <Alert tone="danger" icon="ban">
          Commande refusée. La cliente est remboursée automatiquement.
        </Alert>
      )}
      <section className="rounded-xl border border-line bg-white px-4 py-5 md:px-[22px]">
        <StepBar steps={STEPS} current={refused ? 0 : idx + 1} barHeight={6} />
      </section>
      <Modal
        open={refuse}
        onClose={() => setRefuse(false)}
        icon="ban"
        title="Refuser cette commande ?"
        description="La cliente sera remboursée et notifiée. Un taux de refus élevé fait baisser la visibilité de votre boutique."
        footer={
          <>
            <Button variant="neutral" className="text-[14px]" onClick={() => setRefuse(false)}>
              Annuler
            </Button>
            <Button
              variant="danger"
              className="text-[14px]"
              onClick={() => {
                setStatus("REFUSED");
                setRefuse(false);
              }}
            >
              Refuser la commande
            </Button>
          </>
        }
      >
        <Textarea label="Motif (visible par la cliente)" rows={3} placeholder="Ex. : rupture de stock sur les tomates" />
      </Modal>
    </>
  );
}
