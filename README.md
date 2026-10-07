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
```

## Commandes utiles

### API (depuis `api/`)

```bash
# Lancer avec les données de test (comptes, boutiques, produits, commandes)
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Vider la base : supprime toutes les tables. Arrêter l'API avant ;
# au démarrage suivant, Flyway recrée le schéma (et les données de test avec le profil dev)
./mvnw initialize -PresetDb

# Vider une autre base que la base locale
./mvnw initialize -PresetDb -Ddb.url=jdbc:postgresql://hote:5432/base -Ddb.user=utilisateur -Ddb.password=motdepasse

# État des migrations Flyway (lecture seule)
./mvnw -PresetDb flyway:info
```

Réglages locaux et secrets : copier `api/.env.example` vers `api/.env` (ignoré par git), lu au démarrage depuis `api/`.

| Variable | Rôle |
|---|---|
| `MMSDUCK_API_KEY` | Clé de l'API SMS [MMSDuck](https://mmsduck.com/documentation) (codes d'inscription) : `mmsduck_test_…` en bac à sable, `mmsduck_live_…` en production. Vide : les SMS sont écrits dans les logs au lieu d'être envoyés. |
| `OTP_EXPOSE_CODE` | `true` : l'API renvoie le code dans sa réponse, pour tester sans SMS. À ne jamais activer en production. |

### Mobile (depuis `mobile/`)

```bash
# Après toute modification d'un modèle (@JsonSerializable), régénérer les *.g.dart
dart run build_runner build

# Sur un téléphone physique : pointer vers l'IP du PC sur le réseau local (10.0.2.2 ne marche que sur l'émulateur)
flutter run --dart-define=API_URL=http://<IP-du-PC>:8080/api/v1

# Sans backend, avec les données de maquette
flutter run --dart-define=USE_MOCK=true

# Analyse statique et tests
flutter analyze && flutter test
```

Voir [`docs/architecture.md`](docs/architecture.md) pour le découpage, les routes de chaque app, le modèle de données et la liste des endpoints.

## Conventions

- Branches : `main` (stable), `feat/<zone>-<sujet>`, `fix/<zone>-<sujet>` — zone = `mobile`, `web`, `api`, `docs`.
- Commits : [Conventional Commits](https://www.conventionalcommits.org/fr/) avec la zone en scope, ex. `feat(web): page panier`.
- Textes de l'interface en français ; code, noms de variables et commentaires techniques en anglais.
- Montants en Ariary, entiers. Affichage `12 000 Ar` (espace fine comme séparateur de milliers).
