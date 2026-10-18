import { AccountShell, SiteChrome } from "@/components/layout/SiteChrome";
import { requireUser } from "@/lib/auth/require-user";

/** /compte/* — protected by src/proxy.ts (session required). */
export default async function AccountLayout({ children }: { children: React.ReactNode }) {
  await requireUser();
  return (
    <SiteChrome>
      <AccountShell>{children}</AccountShell>
    </SiteChrome>
  );
}
