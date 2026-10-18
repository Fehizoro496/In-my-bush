"use client";
import { Button } from "@/components/ui/Button";

export default function AdminError({ reset }: { reset: () => void }) {
  return <section role="alert" className="rounded-xl border border-line bg-white p-6">
    <h2 className="text-xl font-bold">Impossible de charger cette page</h2>
    <p className="my-3">Vérifiez les filtres ou réessayez dans quelques instants.</p>
    <Button onClick={reset}>Réessayer</Button>
  </section>;
}
