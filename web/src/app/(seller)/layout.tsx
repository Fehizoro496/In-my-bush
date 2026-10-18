import { AccountShell, SiteChrome } from "@/components/layout/SiteChrome";
import { requireUser } from "@/lib/auth/require-user";
import { redirect } from "next/navigation";
import { ROUTES } from "@/lib/routing/routes";

/** /vendre/* — protected by src/proxy.ts (role SELLER). */
export default async function SellerLayout({ children }: { children: React.ReactNode }) {
  const user = await requireUser();
  if (!user.roles.includes("SELLER")) redirect(ROUTES.sellerOnboarding);
  return (
    <SiteChrome>
      <AccountShell>{children}</AccountShell>
    </SiteChrome>
  );
}
