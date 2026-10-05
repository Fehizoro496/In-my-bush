# In my bush

Marketplace de produits bio : on achète et on vend avec le même compte. Backoffice d'administration sur le web.

| Dossier | Projet | Stack |
|---|---|---|
| [`mobile/`](mobile) | App acheteur + vendeur | Flutter · Riverpod · go_router · Dio |
| [`web/`](web) | Site public, espace compte et vendeur, backoffice `/admin` | Next.js (App Router) · TypeScript · Tailwind CSS |
| [`api/`](api) | API REST `/api/v1` | Spring Boot 3 · Java 17 · PostgreSQL · Flyway · JWT |
| [`docs/`](docs) | Architecture, routes, modèle de données, design tokens | — |

## Démarrer en local

```bash
# 1. Base de données : PostgreSQL installé en local (port 5432), à créer une seule fois
psql -U postgres -c "CREATE ROLE inmybush LOGIN PASSWORD 'inmybush'"
psql -U postgres -c "CREATE DATABASE inmybush OWNER inmybush"

# 2. API (http://localhost:8080, Swagger sur /swagger-ui.html)
cd api && ./mvnw spring-boot:run

# 3. Web (http://localhost:3000)
cd web && cp .env.example .env.local && npm install && npm run dev

# 4. Mobile
cd mobile && flutter pub get && flutter run

# Mobile : après toute modification d'un modèle (@JsonSerializable), régénérer les *.g.dart
cd mobile && dart run build_runner build ---delete-conflicting-outputs
```

Voir [`docs/architecture.md`](docs/architecture.md) pour le découpage, les routes de chaque app, le modèle de données et la liste des endpoints.

## Conventions

- Branches : `main` (stable), `feat/<zone>-<sujet>`, `fix/<zone>-<sujet>` — zone = `mobile`, `web`, `api`, `docs`.
- Commits : [Conventional Commits](https://www.conventionalcommits.org/fr/) avec la zone en scope, ex. `feat(web): page panier`.
- Textes de l'interface en français ; code, noms de variables et commentaires techniques en anglais.
- Montants en Ariary, entiers. Affichage `12 000 Ar` (espace fine comme séparateur de milliers).
