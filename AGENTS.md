# Instructions pour les agents IA

Ces règles s’appliquent à tout assistant IA qui travaille sur ce dépôt.

## Commits

- Suivre les [Conventional Commits](https://www.conventionalcommits.org/fr/), avec la zone en scope : `mobile`, `web`, `api` ou `docs`. Exemple : `feat(web): page panier`.
- Ne jamais mentionner une IA comme auteur ou co-auteur : pas de ligne `Co-Authored-By`, pas de mention « Generated with … », ni dans les commits ni dans les pull requests.
- Privilégier des commits courts : une seule ligne de titre, sans body.
- Un commit par changement cohérent, plutôt qu’un gros commit qui mélange plusieurs sujets.

## Repères

- Conventions du projet (branches, langue, montants) : [`README.md`](README.md).
- Architecture, routes, modèle de données et endpoints : [`docs/architecture.md`](docs/architecture.md).
- Travaux prévus et priorités : [`docs/roadmap.md`](docs/roadmap.md).
- Le projet `web/` a ses propres instructions : [`web/AGENTS.md`](web/AGENTS.md).
