"use client";
import { useActionState } from "react";
import { loginAction } from "@/lib/auth/actions";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Form";

export function LoginForm({ next }: { next?: string }) {
  const [state, action, pending] = useActionState(loginAction, { error: "" });
  return <form action={action} className="flex w-full max-w-[440px] flex-col gap-[18px]">
    <h1 className="font-display text-[34px] font-extrabold">Bon retour !</h1>
    <p className="text-muted">Connectez-vous à votre compte In my bush.</p>
    <input type="hidden" name="next" value={next ?? ""} />
    <Input name="identifier" label="Téléphone ou e-mail" autoComplete="username" required size="lg" />
    <Input name="password" label="Mot de passe" type="password" autoComplete="current-password" required size="lg" />
    {state.error && <p role="alert" className="text-danger-ink">{state.error}</p>}
    <Button type="submit" size="lg" disabled={pending}>{pending ? "Connexion…" : "Se connecter"}</Button>
    <p className="text-sm text-muted">Pour créer un compte, utilisez actuellement l’application mobile.</p>
  </form>;
}

