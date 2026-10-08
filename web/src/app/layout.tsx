import type { Metadata, Viewport } from "next";
import localFont from "next/font/local";
import { ToastProvider } from "@/components/ui/Toast";
import { RouteServiceBinder } from "@/lib/routing/RouteServiceBinder";
import "./globals.css";

/*
 * Bricolage Grotesque (display) + Figtree (body), variable fonts self-hosted in
 * ./fonts (SIL OFL). Equivalent to next/font/google, which needs access to
 * fonts.googleapis.com at build time — swap back if your CI can reach it:
 *   const figtree = Figtree({ variable: "--font-figtree", subsets: ["latin"] })
 */
const bricolage = localFont({
  src: "./fonts/BricolageGrotesque-Variable.woff2",
  variable: "--font-bricolage",
  weight: "200 800",
  display: "swap",
});

const figtree = localFont({
  src: "./fonts/Figtree-Variable.woff2",
  variable: "--font-figtree",
  weight: "300 900",
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "In my bush — le marché bio, en direct des producteurs",
    template: "%s · In my bush",
  },
  description:
    "Marketplace de produits bio et locaux à Madagascar : fruits, légumes, miel, épicerie et cosmétiques, en direct des producteurs.",
};

export const viewport: Viewport = {
  themeColor: "#8CC63F",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="fr" className={`${bricolage.variable} ${figtree.variable}`}>
      <body className="min-h-dvh bg-bg text-ink antialiased">
        <RouteServiceBinder />
        <ToastProvider>{children}</ToastProvider>
      </body>
    </html>
  );
}
