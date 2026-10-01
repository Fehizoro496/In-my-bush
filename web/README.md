# In my bush — web

Site public, espace compte / vendeur et backoffice `/admin`, dans un seul projet **Next.js 16 (App Router)** · TypeScript strict · Tailwind CSS v4.

## Démarrer

```bash
cp .env.example .env.local   # NEXT_PUBLIC_AUTH_BYPASS=true pour ouvrir /compte, /vendre, /admin en dev
npm install
npm run dev                  # http://localhost:3000
```

| Script | Rôle |
|---|---|
| `npm run dev` | serveur de dev (Turbopack) |
| `npm run build` | build de production |
| `npm start` | sert le build |
| `npm run lint` | ESLint (config `eslint-config-next`, flat config) |

### Variables d’environnement

| Variable | Défaut | Rôle |
|---|---|---|
| `NEXT_PUBLIC_API_URL` | `http://localhost:8080/api/v1` | base de l’API Spring Boot |
| `NEXT_PUBLIC_USE_MOCKS` | `true` | `true` = données de `src/lib/mock`, `false` = appels API |
| `NEXT_PUBLIC_AUTH_BYPASS` | — | `true` = pas de contrôle de session (dev uniquement, **jamais en prod**) |

## Structure

```
src/
├── app/
│   ├── layout.tsx            polices, ToastProvider
│   ├── not-found.tsx         404 (W-404)
│   ├── fonts/                Bricolage Grotesque + Figtree (variables, OFL)
│   ├── (shop)/               header + footer : /, /categories, /catalogue, /recherche,
│   │                         /produits/[slug], /vendeurs/[slug], /panier, /commande/confirmation,
│   │                         /compte/messages (3 colonnes, sans menu compte), /vendre/ouvrir-ma-boutique
│   ├── (checkout)/commande/  en-tête réduit (logo · étapes · paiement sécurisé)
│   ├── (auth)/connexion/     écran scindé, sans header
│   ├── (account)/compte/     header + AccountNav : commandes, favoris, notifications, avis, adresses…
│   ├── (seller)/vendre/      header + AccountNav : dashboard, produits, commandes, historique, avis, boutique
│   └── admin/                AdminSidebar + AdminTopbar : dashboard, produits, utilisateurs, commandes, signalements
├── components/
│   ├── ui/                   primitives du design system (Button, Badge, StatusPill, Form, Tabs, Modal/Drawer, Toast…)
│   ├── layout/               WebHeader, CompactHeader, MobileNav (rail tablette + tab bar), Footer, AccountNav, AdminNav, Logo
│   ├── product/ seller/ cart/ checkout/ orders/ messages/ notifications/ reviews/
│   ├── seller-dashboard/ charts/ admin/ account/ catalog/ home/ auth/
├── lib/
│   ├── types.ts              types du modèle de données (§3) et des réponses API
│   ├── format.ts             formatAriary (« 12 000 Ar », espace fine insécable), dates FR
│   ├── api/                  client fetch typé (JWT, problem+json) + un module par zone de l’API (§5)
│   ├── data/                 couche d’accès appelée par les pages (mock ⇄ API)
│   └── mock/                 données reprises des maquettes
├── styles/tokens.css         tokens de docs/design-tokens.json → @theme Tailwind
└── proxy.ts                  protection des routes (ex-middleware, renommé en Next 16)
```

Les pages sont des **Server Components** ; seules les parties interactives (filtres, onglets, quantités, favoris, formulaires, modales, chat…) sont des Client Components.

## Passer des mocks à l’API

1. Mettre `NEXT_PUBLIC_USE_MOCKS=false` et `NEXT_PUBLIC_API_URL`.
2. Chaque fonction de `src/lib/data/*` bascule alors sur le module `src/lib/api/*` correspondant ; les formes de réponse attendues sont les types de `src/lib/types.ts`.
3. Les points encore câblés en local sont marqués `TODO(api)` (mutations : panier, checkout, actions vendeur, modération). Les brancher via des server actions qui appellent `src/lib/api/*` (le module est `server-only` : le jeton est lu dans le cookie `imb_session`).

## Authentification (stub)

`src/proxy.ts` protège `/compte/*` (session), `/vendre/*` (rôle `SELLER`, sauf `/vendre/ouvrir-ma-boutique`) et `/admin/*` (rôle `ADMIN`). Il lit les rôles dans le JWT du cookie `imb_session` **sans vérifier la signature** — suffisant pour choisir l’écran, l’API reste seule juge. À remplacer par une vérification réelle (ex. `jose`) avec le flux de connexion.

## Design system

- Couleurs, rayons, tailles : `src/styles/tokens.css` (miroir de `docs/design-tokens.json`, plus quelques nuances des maquettes en « extended »). Utilitaires : `bg-pomme-500`, `text-on-primary`, `border-line`, `text-muted`, `rounded-xl`…
- Polices : Bricolage Grotesque (`font-display`) et Figtree (`font-sans`) servies via `next/font/local` depuis `src/app/fonts` (le build n’a pas besoin d’accéder à Google Fonts).
- Icônes : `<Icon name="cart" />` fait correspondre les noms des maquettes aux icônes Lucide.
- Responsive : desktop ≥ 1024 px (WebHeader), tablette 768–1023 px (rail de navigation, maquettes T-*), téléphone < 768 px (tab bar du bas).
