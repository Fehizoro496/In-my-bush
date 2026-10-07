"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { Button } from "@/components/ui/Button";
import { Checkbox, Input } from "@/components/ui/Form";
import { TabList } from "@/components/ui/Tabs";

/** Connexion / Inscription (W-Login). */
export function LoginForm({ next }: { next?: string }) {
  const [mode, setMode] = useState<"login" | "signup">("login");
  const router = useRouter();
  const login = mode === "login";
  return (
    <form
      className="flex w-full max-w-[440px] flex-col gap-[18px]"
      onSubmit={(e) => {
        e.preventDefault();
        // TODO(api): server action → authApi.login / authApi.register, then set the imb_session cookie.
        router.push(next ?? "/");
      }}
    >
      <div className="flex flex-col gap-1.5">
        <h1 className="m-0 font-display text-[30px] font-extrabold tracking-[-0.02em] md:text-[34px]">{login ? "Bon retour !" : "Créer un compte"}</h1>
        <p className="m-0 text-[15px] text-muted">
          {login ? "Connectez-vous pour retrouver votre panier et vos commandes." : "Achetez dès maintenant, vendez quand vous voulez."}
        </p>
      </div>
      <TabList
        variant="segmented"
        fullWidth
        label="Connexion ou inscription"
        value={mode}
        onChange={setMode}
        items={[
          { value: "login", label: "Connexion" },
          { value: "signup", label: "Inscription" },
        ]}
        className="[&>button]:h-[42px] [&>button]:text-[15px]"
      />
      {!login && <Input label="Nom complet" size="lg" placeholder="Hery Rakoto" autoComplete="name" required />}
      <Input label="Téléphone ou e-mail" size="lg" placeholder="+261 34 00 000 00" autoComplete="username" required />
      <Input
        label="Mot de passe"
        size="lg"
        type="password"
        placeholder="••••••••"
        autoComplete={login ? "current-password" : "new-password"}
        required
        labelAside={
          login ? (
            <a href="#" className="text-[13px] font-bold no-underline">
              Mot de passe oublié ?
            </a>
          ) : undefined
        }
      />
      <Checkbox label="Rester connecté sur cet appareil" defaultChecked />
      <Button type="submit" size="lg" className="h-[54px]">
        {login ? "Se connecter" : "Créer mon compte"}
      </Button>
      <p className="m-0 text-center text-[13px] leading-[19px] text-muted">
        En continuant, vous acceptez les <a href="#">conditions d’utilisation</a> et la <a href="#">politique de confidentialité</a>.
      </p>
    </form>
  );
}
