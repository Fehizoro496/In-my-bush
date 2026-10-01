import type { Metadata } from "next";
import Link from "next/link";
import { LoginForm } from "@/components/auth/LoginForm";
import { Logo } from "@/components/layout/Logo";
import { Icon } from "@/components/ui/Icon";

export const metadata: Metadata = { title: "Connexion" };

const PERKS = [
  { icon: "pin" as const, text: "Des producteurs vérifiés près de chez vous" },
  { icon: "leaf" as const, text: "L’origine affichée sur chaque produit" },
  { icon: "store" as const, text: "Vendez vos produits sans créer un second compte" },
];

export default async function LoginPage({ searchParams }: { searchParams: Promise<{ next?: string }> }) {
  const { next } = await searchParams;
  const safeNext = next?.startsWith("/") && !next.startsWith("//") ? next : undefined;
  return (
    <div className="grid min-h-dvh lg:grid-cols-2">
      <section className="relative flex flex-col justify-between gap-10 overflow-hidden bg-pomme-900 px-6 py-8 text-pomme-50 md:px-12 md:py-12 lg:px-[72px] lg:py-14">
        <span className="absolute -top-[100px] -right-[120px] size-[520px] rounded-full bg-[#2A4A0C]" />
        <span className="absolute right-[60px] -bottom-40 size-[380px] rounded-full bg-pomme-800" />
        <span className="absolute top-[190px] right-[120px] hidden text-pomme-500 lg:flex" aria-hidden>
          <Icon name="sprout" size={200} />
        </span>
        <Link href="/" aria-label="In my bush — accueil" className="relative flex no-underline">
          <Logo tone="dark" />
        </Link>
        <div className="relative hidden max-w-[460px] flex-col gap-7 md:flex">
          <h2 className="m-0 font-display text-[40px] leading-[1.02] font-extrabold tracking-[-0.035em] lg:text-[52px]">
            Un seul compte pour acheter et vendre bio.
          </h2>
          <ul className="m-0 flex list-none flex-col gap-3.5 p-0 text-[16px] text-[#D6E4C2]">
            {PERKS.map((p) => (
              <li key={p.text} className="flex items-center gap-3">
                <span className="flex size-9 shrink-0 items-center justify-center rounded-[10px] bg-[rgba(178,218,106,0.18)] text-lime">
                  <Icon name={p.icon} size={18} />
                </span>
                {p.text}
              </li>
            ))}
          </ul>
        </div>
        <span className="relative hidden text-[13px] text-[#A9BE8E] md:block">© 2026 In my bush · Aide · Confidentialité</span>
      </section>
      <main className="flex items-center justify-center px-4 py-10 md:p-10">
        <LoginForm next={safeNext} />
      </main>
    </div>
  );
}
