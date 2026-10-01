import Link from "next/link";
import { Logo } from "@/components/layout/Logo";
import { Icon } from "@/components/ui/Icon";
import { NumberedSteps } from "@/components/ui/Navigation";

/** Checkout: minimal header (logo · steps · secure payment), no site navigation. */
export default function CheckoutLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-dvh flex-col">
      <header className="border-b border-line bg-white">
        <div className="mx-auto flex h-16 max-w-[1440px] items-center justify-between gap-4 px-4 md:h-20 md:px-8 xl:px-20">
          <Link href="/" aria-label="In my bush — accueil" className="flex no-underline">
            <span className="sm:hidden">
              <Logo markOnly size="sm" />
            </span>
            <span className="hidden sm:block">
              <Logo />
            </span>
          </Link>
          <NumberedSteps
            steps={[
              { label: "Panier", state: "done" },
              { label: "Livraison", state: "current" },
              { label: "Paiement", state: "current" },
              { label: "Confirmation", state: "todo" },
            ]}
          />
          <span className="hidden items-center gap-1.5 text-[14px] font-semibold text-pomme-700 md:flex">
            <Icon name="lock" size={16} />
            Paiement sécurisé
          </span>
        </div>
      </header>
      {children}
    </div>
  );
}
