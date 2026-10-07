import type { Metadata } from "next";
import { PageHeader } from "@/components/layout/Container";
import { Avatar } from "@/components/ui/Avatar";
import { Button } from "@/components/ui/Button";
import { Input, Select } from "@/components/ui/Form";
import { Icon, type IconName } from "@/components/ui/Icon";
import { Switch } from "@/components/ui/Switch";
import { getCurrentUser } from "@/lib/data/account";
import { initials } from "@/lib/format";

export const metadata: Metadata = { title: "Profil & paramètres" };

const SECURITY: { title: string; detail: string; icon: IconName; cta: string }[] = [
  { title: "Mot de passe", detail: "Modifié il y a 3 mois", icon: "lock", cta: "Modifier" },
  { title: "Appareils connectés", detail: "2 appareils", icon: "info", cta: "Voir" },
];

function Row({ icon, children, first }: { icon: IconName; children: React.ReactNode; first?: boolean }) {
  return (
    <div className={`flex min-h-14 items-center gap-3 ${first ? "" : "border-t border-divider"}`}>
      <Icon name={icon} size={19} className="text-body" />
      <div className="min-w-0 flex-1">{children}</div>
    </div>
  );
}

export default async function SettingsPage() {
  const user = await getCurrentUser();
  const name = `${user.firstName} ${user.lastName}`;
  return (
    <>
      <PageHeader
        title="Profil & paramètres"
        actions={
          <Button className="text-[14px]" type="submit" form="profile-form">
            Enregistrer les modifications
          </Button>
        }
      />
      <div className="grid items-start gap-5 xl:grid-cols-2">
        <div className="flex flex-col gap-5">
          <section id="profil" className="flex scroll-mt-6 flex-col gap-3.5 rounded-xl border border-line bg-white p-5 md:p-[22px]">
            <div className="flex items-center gap-4">
              <Avatar initials={initials(name)} size={72} display />
              <div className="flex flex-col gap-1.5">
                <b className="text-[17px]">Photo de profil</b>
                <div className="flex gap-2">
                  <Button variant="neutral" size="sm" className="rounded-[9px] px-3 text-[13px]">
                    Changer
                  </Button>
                  <Button variant="ghost" size="sm" className="px-3 text-[13px] text-muted">
                    Retirer
                  </Button>
                </div>
              </div>
            </div>
            <form id="profile-form" className="grid gap-3 sm:grid-cols-2">
              <Input label="Nom complet" defaultValue={name} autoComplete="name" size="sm" controlClassName="h-11" />
              <Input label="Ville" defaultValue="Antananarivo" size="sm" controlClassName="h-11" />
              <Input label="Téléphone" defaultValue={user.phone} type="tel" size="sm" controlClassName="h-11" trailing={<Icon name="checkCircle" size={16} className="text-pomme-700" label="Vérifié" />} />
              <Input label="E-mail" defaultValue={user.email ?? ""} type="email" size="sm" controlClassName="h-11" trailing={<Icon name="checkCircle" size={16} className="text-pomme-700" label="Vérifié" />} />
            </form>
          </section>
          <section className="flex flex-col gap-1 rounded-xl border border-line bg-white p-5 md:p-[22px]">
            <h2 className="m-0 mb-2 text-[17px] font-bold">Sécurité</h2>
            {SECURITY.map((s, i) => (
              <Row key={s.title} icon={s.icon} first={i === 0}>
                <div className="flex items-center gap-3">
                  <span className="flex min-w-0 flex-1 flex-col">
                    <span className="text-[15px]">{s.title}</span>
                    <span className="text-[12px] text-muted">{s.detail}</span>
                  </span>
                  <Button variant="neutral" size="sm" className="rounded-[9px] px-3 text-[13px]">
                    {s.cta}
                  </Button>
                </div>
              </Row>
            ))}
          </section>
        </div>
        <div className="flex flex-col gap-5">
          <section className="flex flex-col gap-1 rounded-xl border border-line bg-white p-5 md:p-[22px]">
            <h2 className="m-0 mb-2 text-[17px] font-bold">Préférences</h2>
            <Row icon="info" first>
              <div className="flex items-center justify-between gap-3">
                <label htmlFor="lang" className="text-[15px]">
                  Langue
                </label>
                <Select id="lang" size="sm" className="h-9 w-[150px]" options={[{ value: "fr", label: "Français" }, { value: "mg", label: "Malagasy" }]} />
              </div>
            </Row>
            <Row icon="wallet">
              <div className="flex items-center justify-between gap-3">
                <label htmlFor="cur" className="text-[15px]">
                  Devise
                </label>
                <Select id="cur" size="sm" className="h-9 w-[150px]" options={[{ value: "MGA", label: "Ariary (Ar)" }]} />
              </div>
            </Row>
            <Row icon="percent">
              <Switch showLabel label="Recevoir les promotions" description="Notifications détaillées dans Notifications" />
            </Row>
          </section>
          <section className="flex flex-col gap-1 rounded-xl border border-line bg-white p-5 md:p-[22px]">
            <h2 className="m-0 mb-2 text-[17px] font-bold">Espace vendeur</h2>
            <Row icon="clock" first>
              <Switch showLabel label="Mettre ma boutique en pause" description="Masque vos produits (vacances, fin de saison)" />
            </Row>
            <Row icon="package">
              <div className="flex items-center justify-between gap-3">
                <label htmlFor="prep" className="text-[15px]">
                  Délai de préparation
                </label>
                <Select id="prep" size="sm" className="h-9 w-[150px]" options={["24 h", "48 h", "72 h"].map((v) => ({ value: v, label: v }))} />
              </div>
            </Row>
          </section>
          <section className="flex flex-wrap items-center gap-3.5 rounded-xl border border-[#F1C7C2] bg-white p-5 md:p-[22px]">
            <span className="flex min-w-0 flex-1 flex-col gap-0.5">
              <b className="text-[15px] text-danger-ink">Supprimer mon compte</b>
              <span className="text-[13px] text-body">Vos achats, votre boutique et vos avis seront supprimés.</span>
            </span>
            <Button variant="danger-outline" className="h-10 text-[14px]">
              Supprimer
            </Button>
          </section>
        </div>
      </div>
    </>
  );
}
