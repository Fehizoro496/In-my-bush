import type { Metadata } from "next";
import { Container } from "@/components/layout/Container";
import { Avatar } from "@/components/ui/Avatar";
import { ButtonLink } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import { StepBar } from "@/components/ui/Navigation";
import { getConfirmation } from "@/lib/data/cart";
import { formatAriary } from "@/lib/format";
import { ROUTES } from "@/lib/routing/routes";

export const metadata: Metadata = { title: "Commande confirmée" };

const STEPS = [{ label: "Confirmée" }, { label: "Préparation" }, { label: "En route" }, { label: "Livrée" }];
const NEXT = [
  { icon: "package" as const, title: "Préparation", detail: "Chaque producteur prépare sa partie et vous prévient." },
  { icon: "truck" as const, title: "Livraison", detail: "Suivi en direct et contact du livreur le jour J." },
  { icon: "starO" as const, title: "Votre avis", detail: "Notez les produits pour aider les autres acheteurs." },
];

export default async function ConfirmationPage() {
  const c = await getConfirmation();
  return (
    <main className="pt-6 pb-16 lg:pt-12">
      <Container className="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_380px] lg:gap-8">
        <div className="flex flex-col gap-6">
          <section className="flex flex-col items-start gap-6 rounded-[28px] border border-line bg-white p-6 sm:flex-row sm:items-center md:gap-7 md:p-9">
            <div className="relative flex h-[130px] w-[140px] shrink-0 items-center justify-center" aria-hidden>
              <span className="absolute size-[130px] rounded-full bg-mint" />
              <span className="absolute top-2.5 left-0 flex -rotate-30 text-pomme-600">
                <Icon name="leaf" size={30} />
              </span>
              <span className="absolute right-1 bottom-3 size-5 rounded-full bg-orange-500" />
              <span className="animate-pop relative flex size-20 items-center justify-center rounded-full bg-pomme-500 text-on-primary shadow-[0_10px_24px_rgba(92,145,32,0.35)]">
                <Icon name="check" size={40} />
              </span>
            </div>
            <div className="flex flex-col gap-2.5">
              <span className="overline text-[13px] text-pomme-700">Commande n° {c.orderNumber}</span>
              <h1 className="m-0 font-display text-[30px] leading-[1.05] font-extrabold tracking-[-0.03em] md:text-[40px]">
                Merci {c.firstName}, c’est commandé !
              </h1>
              <p className="m-0 text-[16px] leading-6 text-body">
                {formatAriary(c.total)} payés par {c.paymentLabel}. Un reçu vous a été envoyé par SMS et e-mail. Les producteurs préparent votre commande.
              </p>
            </div>
          </section>
          <div className="grid gap-5 md:grid-cols-2">
            {c.deliveries.map((d) => (
              <section key={d.name} className="flex flex-col gap-3.5 rounded-xl border border-line bg-white p-5">
                <div className="flex items-center gap-3">
                  <Avatar initials={d.initials} color={d.color} size={40} />
                  <span className="flex flex-col">
                    <b className="text-[15px]">{d.name}</b>
                    <span className="text-[13px] text-muted">{d.items}</span>
                  </span>
                </div>
                <div className="flex items-center gap-2.5 rounded-md bg-info-bg px-3.5 py-3 text-[14px] font-bold text-info-fg">
                  <Icon name="truck" size={18} />
                  {d.when}
                </div>
                <StepBar steps={STEPS} current={1} />
              </section>
            ))}
          </div>
          <div className="flex flex-wrap gap-3">
            <ButtonLink href={ROUTES.accountOrder(c.orderId)} icon="truck" size="lg" className="h-[54px] rounded-[14px]">
              Suivre ma commande
            </ButtonLink>
            <ButtonLink href={ROUTES.home} variant="neutral" size="lg" className="h-[54px] rounded-[14px]">
              Continuer mes achats
            </ButtonLink>
          </div>
        </div>
        <aside className="flex flex-col gap-4">
          <section className="flex flex-col gap-3 rounded-[22px] border border-line bg-white p-[22px]">
            <h2 className="m-0 text-[17px] font-bold">Récapitulatif</h2>
            <dl className="m-0 flex flex-col gap-2 text-[14px]">
              <div className="flex justify-between">
                <dt className="text-body">{c.itemCount} articles</dt>
                <dd className="m-0">{formatAriary(c.subtotal)}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-body">Livraison</dt>
                <dd className="m-0">{formatAriary(c.delivery)}</dd>
              </div>
              <div className="flex justify-between text-orange-700">
                <dt>Réduction {c.discount.code}</dt>
                <dd className="m-0">{formatAriary(-c.discount.amount)}</dd>
              </div>
              <div className="flex justify-between border-t border-divider pt-2 text-[16px] font-bold">
                <dt>Total payé</dt>
                <dd className="m-0">{formatAriary(c.total)}</dd>
              </div>
            </dl>
            <div className="flex gap-2.5 pt-1.5 text-[13px] text-body">
              <Icon name="pin" size={16} className="text-pomme-700" />
              {c.address}
            </div>
          </section>
          <section className="flex flex-col gap-3.5 rounded-[22px] bg-sand p-[22px]">
            <h2 className="m-0 text-[17px] font-bold">Et ensuite ?</h2>
            {NEXT.map((n) => (
              <div key={n.title} className="flex gap-3">
                <span className="flex size-8 shrink-0 items-center justify-center rounded-[10px] bg-white text-pomme-700">
                  <Icon name={n.icon} size={17} />
                </span>
                <span className="flex flex-col gap-0.5">
                  <b className="text-[14px]">{n.title}</b>
                  <span className="text-[13px] leading-[18px] text-body">{n.detail}</span>
                </span>
              </div>
            ))}
          </section>
        </aside>
      </Container>
    </main>
  );
}
