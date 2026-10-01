import { AccountShell, SiteChrome } from "@/components/layout/SiteChrome";

/** /compte/* — protected by src/proxy.ts (session required). */
export default function AccountLayout({ children }: { children: React.ReactNode }) {
  return (
    <SiteChrome>
      <AccountShell>{children}</AccountShell>
    </SiteChrome>
  );
}
