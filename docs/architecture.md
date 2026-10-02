# In my bush — Architecture

Marketplace de produits bio (Madagascar, prix en Ariary). Un seul compte peut **acheter et vendre** ; les administrateurs ont un backoffice web.

## 1. Monorepo

```
in-my-bush/
├── mobile/     App Flutter (acheteur + vendeur)
├── web/        Next.js : site public, espace compte/vendeur, backoffice /admin
├── api/        Spring Boot 3 + PostgreSQL (API REST /api/v1)
└── docs/       Architecture, design tokens, conventions
```

Chaque dossier est un projet autonome (son propre outil de build, ses dépendances, son README). Pas d'outil de monorepo imposé : on garde les trois écosystèmes (pub, npm, Maven) indépendants. Le contrat entre eux est l'API REST (section 5), et le style est partagé via `docs/design-tokens.json`.

## 2. Rôles et comptes

| Rôle | Obtenu comment | Accès |
|---|---|---|
| `BUYER` | à l'inscription | catalogue, panier, commandes, favoris, messages, avis |
| `SELLER` | en ouvrant une boutique (onboarding « Devenir vendeur ») | en plus : espace vendeur (produits, commandes reçues, versements, avis reçus, profil boutique) |
| `ADMIN` | attribué en base | backoffice `/admin` (web uniquement) |

Un utilisateur a un ensemble de rôles (`BUYER` + `SELLER` le plus souvent). Messages et notifications portent un **contexte** `PURCHASE` / `SALE` pour séparer « J'achète » et « Je vends ».

## 3. Modèle de données (PostgreSQL)

Montants en **Ariary, entiers** (`BIGINT`, pas de centimes). Identifiants `UUID`. Dates `TIMESTAMPTZ`.

| Table | Champs principaux |
|---|---|
| `users` | id, first_name, last_name, email (unique, nullable), phone (unique), password_hash, avatar_url, status (`ACTIVE`, `SUSPENDED`, `BANNED`), created_at |
| `user_roles` | user_id, role |
| `addresses` | id, user_id, label, recipient, phone, line1, district, city, landmark, is_default |
| `shops` | id, owner_id (1-1 user), name, slug (unique), description, region, city, logo_url, cover_url, status (`ACTIVE`, `PAUSED`, `SUSPENDED`), rating_avg, rating_count, created_at |
| `categories` | id, parent_id, name, slug, icon, position |
| `products` | id, shop_id, category_id, name, slug, description, price, compare_at_price, unit (`KG`, `G`, `L`, `PIECE`, `BUNCH`, `JAR`, `PACK`), unit_label, stock, low_stock_threshold, origin_region, status (`DRAFT`, `PENDING_REVIEW`, `PUBLISHED`, `REJECTED`, `ARCHIVED`), rejection_reason, rating_avg, rating_count, created_at, updated_at |
| `product_images` | id, product_id, url, position |
| `favorites` | user_id, product_id (PK composite), created_at |
| `carts` / `cart_items` | cart: id, user_id · item: id, cart_id, product_id, quantity |
| `checkouts` | id, buyer_id, address_id, delivery_mode (`HOME`, `PICKUP`), total, created_at — regroupe les commandes d'un même paiement |
| `orders` | id, number (`IMB-00001`), checkout_id, buyer_id, shop_id, status, subtotal, delivery_fee, discount, commission, total, seller_net, delivery_slot, accept_before, created_at |
| `order_items` | id, order_id, product_id, product_name, unit_price, unit_label, quantity, line_total |
| `order_events` | id, order_id, status, note, created_at (timeline de suivi) |
| `payments` | id, checkout_id, method (`MVOLA`, `ORANGE_MONEY`, `AIRTEL_MONEY`, `CASH_ON_DELIVERY`), phone, amount, status (`PENDING`, `HELD`, `RELEASED`, `REFUNDED`, `FAILED`), provider_ref |
| `payout_methods` | id, user_id, method, phone_masked, is_default |
| `payouts` | id, shop_id, amount, status (`SCHEDULED`, `PAID`, `FAILED`), period_start, period_end, paid_at |
| `reviews` | id, product_id, order_id, author_id, rating 1–5, comment, seller_reply, replied_at, created_at |
| `conversations` | id, buyer_id, shop_id, product_id (nullable), order_id (nullable), last_message_at |
| `messages` | id, conversation_id, sender_id, body, read_at, created_at |
| `notifications` | id, user_id, context (`PURCHASE`, `SALE`, `SYSTEM`), type, title, body, link, read_at, created_at |
| `reports` | id, reporter_id, target_type (`PRODUCT`, `SHOP`, `USER`, `REVIEW`, `MESSAGE`), target_id, reason, details, status (`OPEN`, `IN_REVIEW`, `RESOLVED`, `DISMISSED`), resolved_by, created_at |
| `platform_settings` | key, value (ex. `commission_rate`) |

### Cycle de vie d'une commande

`PENDING_CONFIRMATION` → `ACCEPTED` → `PREPARED` → `IN_DELIVERY` → `DELIVERED`
avec sorties possibles `REFUSED` (par le vendeur, avant acceptation) et `CANCELLED` (acheteur avant préparation, ou délai de confirmation dépassé). Le paiement est **conservé par In my bush** (`HELD`) puis versé au vendeur (`RELEASED`) après livraison ; refus/annulation ⇒ `REFUNDED`.

### Cycle de vie d'un produit

`DRAFT` → `PENDING_REVIEW` (relu par l'équipe In my bush sous 24 h) → `PUBLISHED` ou `REJECTED` (avec motif) ; `ARCHIVED` quand le vendeur le retire.

## 4. Écrans et routes

### Web (Next.js, App Router) — un seul projet

| Zone | Route | Maquette |
|---|---|---|
| Public | `/` | W-Home (T-Home en tablette) |
| | `/categories` | W-Categories |
| | `/catalogue` (`?categorie=&q=&tri=`) | W-Catalog (T-Catalog) |
| | `/recherche` | W-Search |
| | `/produits/[slug]` | W-Product |
| | `/vendeurs/[slug]` | W-Seller |
| | `/panier` | W-Cart |
| | `/commande` | W-Checkout |
| | `/commande/confirmation` | W-Confirmation |
| | `/connexion` | W-Login |
| Compte (connecté) | `/compte` (commandes) | W-Account |
| | `/compte/commandes/[id]` | W-Order-Detail |
| | `/compte/favoris` | W-Favorites |
| | `/compte/messages` | W-Messages |
| | `/compte/notifications` | W-Notifications |
| | `/compte/avis` | W-Reviews |
| | `/compte/adresses` | W-Addresses |
| | `/compte/paiements` | W-Payments |
| | `/compte/parametres` | W-Settings |
| Vendeur (rôle SELLER) | `/vendre` | W-Sell-Dashboard |
| | `/vendre/ouvrir-ma-boutique` | W-Become-Seller (connecté, sans boutique) |
| | `/vendre/produits` | W-Stock |
| | `/vendre/produits/nouveau` | W-Add-Product |
| | `/vendre/produits/[id]` | W-Edit-Product |
| | `/vendre/commandes` | W-Orders-Received |
| | `/vendre/commandes/[id]` | W-Order-Received |
| | `/vendre/historique` | W-Sales-History |
| | `/vendre/avis` | W-Reviews-Received |
| | `/vendre/boutique` | W-Shop-Profile |
| Backoffice (rôle ADMIN) | `/admin` | A-Dashboard |
| | `/admin/produits` | A-Products |
| | `/admin/utilisateurs` | A-Users |
| | `/admin/commandes` | A-Orders |
| | `/admin/signalements` | A-Reports |
| | 404 | W-404 |

### Mobile (Flutter, go_router)

Barre du bas (StatefulShellRoute, 5 onglets) : **Accueil** `/` · **Messages** `/messages` · **Vendre** `/vendre` · **Notifs** `/notifications` · **Paramètres** `/parametres`. Le panier est dans la barre du haut (icône + badge), pas dans la barre du bas.

| Route | Écran | Maquette |
|---|---|---|
| `/` | Accueil + catalogue (Explorer fusionné) | M-Home |
| `/filtres` (bottom sheet) | Filtres | M-Filters |
| `/categories` | Catégories | M-Categories |
| `/recherche` | Recherche | M-Search |
| `/produits/:slug` | Fiche produit | M-Product |
| `/vendeurs/:slug` | Profil vendeur | M-Seller |
| `/panier` | Panier | M-Cart |
| `/commande` | Checkout | M-Checkout |
| `/commande/confirmation` | Confirmation | M-Confirmation |
| `/connexion` | Connexion / inscription | M-Login |
| `/messages`, `/messages/:id` | Messages, conversation | M-Messages, M-Chat |
| `/notifications` | Notifications | M-Notifications |
| `/parametres` | Paramètres (onglet) | M-Settings |
| `/profil` | Mon profil | M-Account |
| `/favoris` | Favoris | M-Favorites |
| `/commandes`, `/commandes/:id` | Mes commandes, suivi | M-Orders, M-Order-Detail |
| `/commandes/:id/avis` | Laisser un avis | M-Review |
| `/adresses` | Adresses | M-Addresses |
| `/paiements` | Moyens de paiement & versements | M-Payments |
| `/vendre` | Dashboard vendeur (onglet) | M-Sell-Dashboard |
| `/vendre/ouvrir-ma-boutique` | Devenir vendeur | M-Become-Seller |
| `/vendre/produits` | Mes produits & stock | M-My-Products |
| `/vendre/produits/nouveau` | Ajouter un produit | M-Add-Product |
| `/vendre/produits/:id` | Modifier un produit | M-Edit-Product |
| `/vendre/commandes`, `/vendre/commandes/:id` | Commandes reçues, détail | M-Orders-Received, M-Order-Received |
| `/vendre/historique` | Historique des ventes | M-Sales-History |
| `/vendre/avis` | Avis reçus | M-Reviews-Received |
| `/vendre/boutique` | Profil de la boutique | M-Shop-Profile |

## 5. API REST (`/api/v1`)

Auth par **JWT** (access token court + refresh token). Réponses JSON, erreurs au format RFC 7807 (`application/problem+json`). Pagination `?page=0&size=20` → `{ items, page, size, totalItems, totalPages }`. Documentation OpenAPI sur `/swagger-ui.html`.

| Module | Endpoints |
|---|---|
| auth | `POST /auth/register` · `POST /auth/login` · `POST /auth/refresh` · `POST /auth/logout` · `POST /auth/otp/request` · `POST /auth/otp/verify` |
| me | `GET/PATCH /me` · `GET/POST/PATCH/DELETE /me/addresses[/{id}]` · `GET/POST/DELETE /me/payout-methods[/{id}]` |
| catalogue | `GET /categories` · `GET /products` (q, category, region, minPrice, maxPrice, sort) · `GET /products/{slug}` · `GET /products/{id}/reviews` · `GET /shops/{slug}` · `GET /shops/{slug}/products` · `GET /search/suggestions?q=` |
| favoris | `GET /me/favorites` · `PUT /me/favorites/{productId}` · `DELETE /me/favorites/{productId}` |
| panier | `GET /me/cart` · `POST /me/cart/items` · `PATCH /me/cart/items/{id}` · `DELETE /me/cart/items/{id}` · `DELETE /me/cart` |
| commandes (acheteur) | `POST /checkouts` (panier → commandes par boutique + paiement) · `GET /me/orders` · `GET /me/orders/{id}` · `POST /me/orders/{id}/cancel` · `POST /me/orders/{id}/confirm-delivery` · `POST /me/orders/{id}/reviews` · `GET /me/reviews` |
| vendeur | `POST /seller/shop` (ouvrir sa boutique) · `GET/PATCH /seller/shop` · `GET /seller/dashboard` · `GET/POST /seller/products` · `GET/PATCH/DELETE /seller/products/{id}` · `POST /seller/products/{id}/submit` · `PATCH /seller/products/{id}/stock` · `GET /seller/orders` · `GET /seller/orders/{id}` · `POST /seller/orders/{id}/{accept\|refuse\|prepare\|ship\|deliver}` · `GET /seller/sales` · `GET /seller/payouts` · `GET /seller/reviews` · `POST /seller/reviews/{id}/reply` |
| messages | `GET /conversations?context=PURCHASE\|SALE` · `POST /conversations` · `GET /conversations/{id}/messages` · `POST /conversations/{id}/messages` · `POST /conversations/{id}/read` |
| notifications | `GET /notifications?context=` · `POST /notifications/{id}/read` · `POST /notifications/read-all` · `GET /notifications/unread-count` |
| signalements | `POST /reports` |
| uploads | `POST /uploads/images` (multipart) → `{ url }` |
| admin | `GET /admin/dashboard` · `GET /admin/products?status=` · `POST /admin/products/{id}/{approve\|reject}` · `GET /admin/users` · `POST /admin/users/{id}/{suspend\|ban\|reactivate}` · `GET /admin/orders` · `GET /admin/transactions` · `GET /admin/reports` · `PATCH /admin/reports/{id}` · `GET/PATCH /admin/settings` |

## 6. Design system

Source : `docs/design-tokens.json` (couleurs, typo, rayons, espacements). Web et mobile les recopient dans leur thème (`web/src/styles/tokens.css`, `mobile/lib/core/theme/app_colors.dart`). Si un token change, le modifier dans les trois fichiers.

- Titres : **Bricolage Grotesque** (600–800). Texte : **Figtree** (400–700).
- Vert pomme `#8CC63F` = action principale (texte dessus `#1F3608`). Orange `#F28C28` = secondaire, promos et **tous les badges de compteur** (texte dessus `#3A1E05`).
- Fond `#FBFAF6`, surfaces blanches, bordures `#EAE6DB`.
- Icônes : jeu **Lucide** (`lucide-react` sur le web, `lucide_icons_flutter` sur mobile).
- Cibles tactiles ≥ 44 px ; contraste AA minimum.
