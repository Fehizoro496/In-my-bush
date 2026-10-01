import { AccountShell, SiteChrome } from "@/components/layout/SiteChrome";

/** /vendre/* — protected by src/proxy.ts (role SELLER). */
export default function SellerLayout({ children }: { children: React.ReactNode }) {
  return (
    <SiteChrome>
      <AccountShell>{children}</AccountShell>
    </SiteChrome>
  );
}
