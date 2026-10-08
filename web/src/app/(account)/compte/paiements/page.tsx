import type { Metadata } from "next";
import Link from "next/link";
import { PaymentMethods } from "@/components/account/PaymentMethods";
import { Icon } from "@/components/ui/Icon";
import { getPaymentSettings } from "@/lib/data/account";
import { ROUTES } from "@/lib/routing/routes";

export const metadata: Metadata = { title: "Paiement & versements" };

export default async function PaymentsPage() {
  const { methods, payouts, nextPayout } = await getPaymentSettings();
  return (
    <>
      <h1 className="m-0 font-display text-[28px] font-extrabold tracking-[-0.025em] md:text-[36px]">Paiement &amp; versements</h1>
      <div className="grid items-start gap-5 xl:grid-cols-2">
        <section className="flex flex-col gap-3 rounded-xl border border-line bg-white p-5 md:p-[22px]">
          <div className="flex items-center gap-2.5">
            <span className="flex size-9 items-center justify-center rounded-[10px] bg-pomme-100 text-pomme-700">
              <Icon name="basket" size={18} />
            </span>
            <h2 className="m-0 text-[18px] font-bold">Pour payer mes achats</h2>
          </div>
          <PaymentMethods methods={methods} />
          <button
            type="button"
            className="flex h-12 items-center justify-center gap-2 rounded-md border-[1.5px] border-dashed border-lime bg-pomme-50 text-[14px] font-bold text-pomme-800"
          >
            <Icon name="plus" size={17} />
            Ajouter un compte Mobile Money
          </button>
          <div className="flex gap-2.5 pt-1.5 text-[13px] leading-[19px] text-body">
            <Icon name="lock" size={16} className="text-pomme-700" />
            Numéros chiffrés. In my bush ne stocke jamais votre code secret.
          </div>
        </section>
        <section className="flex flex-col gap-4">
          <div className="flex flex-col gap-3.5 rounded-xl bg-pomme-900 p-5 text-pomme-50 md:p-[22px]">
            <div className="flex items-center gap-2.5">
              <span className="flex size-9 items-center justify-center rounded-[10px] bg-[rgba(178,218,106,0.18)] text-lime">
                <Icon name="store" size={18} />
              </span>
              <h2 className="m-0 text-[18px] font-bold">Pour recevoir mes ventes</h2>
            </div>
            <div className="flex flex-wrap items-end justify-between gap-3">
              <span className="flex flex-col gap-0.5">
                <span className="text-[13px] text-lime">{nextPayout.label}</span>
                <b className="font-display text-[32px]">{nextPayout.amount}</b>
              </span>
              <Link href={`${ROUTES.accountPayments}#versement`} className="flex h-10 items-center rounded-[10px] bg-[rgba(244,250,232,0.12)] px-3.5 text-[14px] font-bold text-pomme-50 no-underline hover:text-pomme-50">
                Modifier
              </Link>
            </div>
            <span className="border-t border-[rgba(244,250,232,0.15)] pt-3 text-[14px]">Versé sur {nextPayout.target}</span>
          </div>
          <div className="overflow-hidden rounded-xl border border-line bg-white">
            <div className="flex items-center justify-between px-[18px] py-3.5">
              <b className="text-[16px]">Derniers versements</b>
              <Link href={ROUTES.sellerHistory} className="text-[13px] font-bold no-underline">
                Tout voir
              </Link>
            </div>
            <ul className="m-0 list-none p-0">
              {payouts.map((p) => (
                <li key={p.id} className="flex items-center gap-3 border-t border-divider px-[18px] py-3 text-[14px]">
                  <span className="flex flex-1 flex-col">
                    <b>{p.label}</b>
                    <span className="text-[12px] text-muted">{p.orderCount} commandes</span>
                  </span>
                  <b className="font-tabular">{p.amount ?? "[MONTANT]"}</b>
                  <span className="inline-flex h-[22px] items-center rounded-full bg-success-bg px-2 text-[11px] font-bold text-success-fg">Versé</span>
                </li>
              ))}
            </ul>
          </div>
        </section>
      </div>
    </>
  );
}
