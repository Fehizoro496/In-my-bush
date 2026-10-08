# Roadmap de développement — In my bush

Date : 8 octobre 2026

## Objectif

Construire d’abord un **backoffice admin opérationnel**, valider le parcours complet avec l’application mobile, puis brancher le site web et ouvrir une bêta. Le paiement Mobile Money arrive ensuite, sans bloquer la bêta.

Cette roadmap décrit les travaux à réaliser, pas des fonctionnalités déjà toutes disponibles.

## État de départ

| Partie | État au 8 octobre 2026 |
|---|---|
| **API** | La plus avancée : modules métier, endpoints et protection par rôle en place. Aucun test automatisé. |
| **Mobile** | Branchée sur l’API, inscription par code SMS. Écrans acheteur et vendeur présents ; validation de bout en bout à réaliser aux lots 2 et 3. |
| **Web** | Tous les écrans existent mais fonctionnent sur des données simulées : connexion, commande, formulaire produit et actions admin ne sont pas branchés. |
| **Outillage** | Pas d’intégration continue ni de configuration de déploiement. |

Écarts connus dans les règles métier de l’API, à corriger au lot 3 :

- L’expiration du délai d’acceptation d’une commande n’est jamais exécutée.
- Le stock n’est pas restitué après une annulation ou un refus.
- Le statut d’un paiement ne change plus après sa création.
- Seule la modération d’un produit envoie une notification.

## Vue d’ensemble

Les durées sont des estimations de charge pour un développeur à temps plein, à ajuster après le premier lot. Compter **10 à 15 semaines jusqu’à la bêta** (lots 1 à 5) et **12 à 19 semaines pour les six lots**, hors délais externes. Le lot 6 dépend aussi des accès fournis par les opérateurs. Avec un seul développeur, son développement et le suivi de la bêta se partagent la capacité disponible : leur chevauchement ne réduit pas automatiquement la charge totale.

- **P0** : indispensable au jalon concerné.
- **P1** : amélioration importante, à réaliser après les éléments bloquants.

| Étape | Priorité | Charge indicative | Résultat attendu |
|---|---|---|---|
| 1. Fondations et accès admin | P0 | 2–3 semaines | Connexion réelle, contrats API cohérents, actions traçables, CI en place |
| 2. Administration de la marketplace | P0 | 2–3 semaines | Produits, utilisateurs, boutiques et signalements gérables ; parcours soumission → modération → achat validé avec le mobile |
| 3. Règles de commande et supervision | P0/P1 | 2–3 semaines | Commandes fiables, consultables et corrigibles par l’admin |
| 4. Site web vendeur et acheteur | P0 | 3–4 semaines | Parcours complet sur le web avec données réelles |
| 5. Bêta et mise en production | P0 | 1–2 semaines | Version testée, surveillée et déployée, en paiement à la livraison |
| 6. Paiements Mobile Money et administration financière | P0 avant activation du Mobile Money | 2–4 semaines | Transactions et versements suivis et vérifiables |

## Décisions prises

- **Paiement à la livraison :** la bêta s’ouvre avec ce seul mode de paiement ; le Mobile Money arrive au lot 6.
- **Sessions :** le jeton de rafraîchissement reste valable 30 jours et renouvelle un jeton d’accès de 15 minutes. À l’ouverture de l’application, renouveler si nécessaire ; après un 401, autoriser une seule tentative de renouvellement et une seule répétition de la requête. Les requêtes simultanées partagent le même renouvellement. En cas d’échec, fermer la session et revenir à la connexion.
- **Suspension :** le statut du compte est vérifié à chaque requête authentifiée, sans cache pour commencer ; les jetons de rafraîchissement du compte sont révoqués.

### Décisions à trancher avant la bêta

- **Encaissement à la livraison :** définir qui collecte l’argent, qui confirme l’encaissement et quelle preuve est conservée.
- **Commission :** définir comment la plateforme récupère sa commission selon la personne qui encaisse, et comment sont suivis les montants dus et réglés.
- **Panier multiboutique :** définir les montants et frais restant dus lorsqu’une boutique refuse ou annule sa commande, sans annuler les commandes des autres boutiques.

Ces décisions conditionnent les règles et le suivi admin du lot 3 ; elles ne sont pas reportées à l’intégration Mobile Money.

## 1. Fondations : rendre l’administration utilisable

**Accès et sessions**

- [ ] Brancher la connexion web : appel à l’API, cookie de session, déconnexion.
- [ ] Implémenter le renouvellement côté web et mobile selon les règles ci-dessus : contrôle à l’ouverture, tentative unique après un 401, coordination des requêtes simultanées et retour à la connexion en cas d’échec. Exclure les appels de connexion et de renouvellement de cette relance automatique.
- [ ] Vérifier le statut du compte à chaque requête authentifiée, pour qu’une suspension ou un bannissement prenne effet immédiatement.
- [ ] Désactiver par défaut les données simulées et le contournement d’authentification ; les rendre impossibles en production.
- [ ] Révoquer les jetons de rafraîchissement d’un compte suspendu ou banni, pour fermer ses sessions ouvertes.
- [ ] Limiter le nombre de tentatives de connexion et de demandes de code SMS.

**Contrats entre le web et l’API**

- [ ] Ajouter la liste des produits admin (`GET /admin/products`), absente de l’API.
- [ ] Unifier la route de traitement des signalements (le web appelle `PATCH /admin/reports/{id}`, l’API expose `POST /admin/reports/{id}/resolve`).
- [ ] Raccorder le dashboard aux seuls compteurs réels utiles au MVP et adapter le contrat web à l’API. Masquer les graphiques et filtres non pris en charge ; reporter les séries, périodes et files d’attente au pilotage P1 du lot 3.
- [ ] Prendre en charge les filtres envoyés par le web : rôle, statut et recherche pour les utilisateurs ; statut pour les commandes.
- [ ] Recevoir et enregistrer le motif d’une suspension ou d’un bannissement ; rendre obligatoire le motif de rejet d’un produit.
- [ ] Remplacer l’identité admin et les compteurs statiques du menu par les données réelles.

**Traçabilité et qualité**

- [ ] Ajouter un journal d’audit : administrateur, action, cible, date et motif.
- [ ] Mettre en place une intégration continue minimale : compilation, analyse statique et tests des trois projets.
- [ ] Écrire les premiers tests d’accès et d’intégration de l’API.

**Démarches externes**

- [ ] Lancer les demandes d’accès marchand auprès des opérateurs Mobile Money (MVola, Orange Money, Airtel Money).

**Critère de validation :** un administrateur se connecte avec un vrai compte, consulte les données et réalise une action persistante et journalisée ; un acheteur ne peut pas accéder aux fonctions admin ; la CI passe.

## 2. Priorité admin : gérer et modérer la marketplace

| Module | Travaux à réaliser |
|---|---|
| **Produits** | Liste paginée, recherche, filtres par statut/catégorie/boutique, fiche complète, approbation, rejet motivé et retrait de la vente. |
| **Utilisateurs** | Recherche, filtres par rôle/statut, fiche utilisateur, suspension, bannissement, réactivation et historique des décisions. |
| **Boutiques** | Espace dédié, consultation du propriétaire et des produits, suspension/réactivation avec effets explicites sur les nouvelles ventes. |
| **Signalements** | Accès au contenu signalé, traitement des statuts, notes internes, décision motivée et historique. |
| **Catégories** | Création, modification, ordre d’affichage et désactivation avec gestion des produits déjà associés. |
| **Notifications métier** | Informer les personnes concernées d’une suspension ou d’une décision de modération (le rejet et l’approbation d’un produit notifient déjà le vendeur). |

- [ ] Finaliser la gestion et la modération des produits.
- [ ] Finaliser la gestion des utilisateurs.
- [ ] Créer l’espace de gestion des boutiques.
- [ ] Finaliser le traitement des signalements.
- [ ] Implémenter la gestion des catégories.
- [ ] Déclencher les notifications liées aux décisions de modération.
- [ ] Prévoir des protections contre l’auto-suspension accidentelle et la suppression du dernier accès administrateur.
- [ ] Valider le parcours **soumission → modération → achat** avec l’application mobile côté vendeur et acheteur, et le backoffice web côté admin. La livraison, la réception et les cas d’annulation seront validés au lot 3.

**Critère de validation :** l’équipe gère les cas courants de modération depuis le backoffice, sans modification directe en base. Sur mobile, un vendeur soumet un produit, l’admin le valide sur le web, un acheteur le commande.

## 3. Règles de commande et supervision

Les interventions admin reposent sur des règles de commande fiables : celles-ci sont corrigées en premier.

**Règles de commande (P0)**

- [ ] Exécuter l’annulation automatique des commandes dont le délai d’acceptation est dépassé.
- [ ] Restituer le stock lors d’une annulation, d’un refus ou d’une expiration, une seule fois même si l’action est répétée.
- [ ] Vérifier le comportement du stock lors d’achats simultanés.
- [ ] Définir les transitions de paiement par mode et les distinguer des statuts de commande. Pour le paiement à la livraison, distinguer montant à encaisser, encaissement confirmé et annulation avant encaissement ; cette dernière ne constitue pas un remboursement. Préparer les transitions Mobile Money, dont l’exécution sera implémentée au lot 6.
- [ ] Gérer les paniers multiboutiques : acceptation ou refus indépendant par boutique, restitution du seul stock concerné et recalcul du montant restant dû, frais compris, selon les règles retenues.
- [ ] Valider sur mobile la suite du parcours : traitement vendeur, livraison, confirmation de réception et avis, ainsi que les annulations et refus partiels d’un panier multiboutique.
- [ ] Notifier l’acheteur et le vendeur à chaque changement de statut d’une commande.
- [ ] Vérifier les droits sur chaque commande, conversation et produit.
- [ ] Couvrir ces règles par des tests automatisés au moment où elles sont écrites.

**Supervision admin (P0)**

- [ ] **Commandes :** recherche par référence, filtres par statut/date/boutique, fiche détaillée avec acheteur, vendeur, articles, montants et chronologie.
- [ ] **Interventions :** définir précisément les annulations autorisées, les motifs obligatoires et leurs effets sur le stock et le paiement.
- [ ] **Paiement à la livraison :** afficher par commande le montant dû, le montant encaissé, la personne ayant collecté l’argent, la preuve ou référence de confirmation et les éventuels écarts ; journaliser les confirmations et corrections autorisées.
- [ ] **Commissions :** afficher les commissions dues et réglées ainsi que les sommes à reverser, selon le circuit d’encaissement retenu pour la bêta.
- [ ] **Navigation :** faire correspondre chaque entrée du menu à une fonctionnalité opérationnelle ; masquer les entrées sans écran.

**Pilotage (P1)**

- [ ] **Dashboard réel :** indicateurs par période, volumes de commandes, ventes livrées, annulations et commissions ; distinguer les montants commandés des montants réellement encaissés.
- [ ] **Alertes opérationnelles :** commandes sans réponse, préparation en retard, signalements en attente et produits à valider.
- [ ] **Paramètres :** interface pour les commissions, frais et seuils de livraison, délais d’acceptation et de libération des fonds.
- [ ] **Exports :** export CSV des commandes et des données nécessaires au suivi opérationnel.

**Critère de validation :** une commande non acceptée à temps est annulée et son stock restitué une seule fois. Dans un panier multiboutique, le refus d’une boutique préserve les autres commandes et ajuste le montant dû. Le parcours mobile jusqu’à la réception et à l’avis est validé. L’admin peut traiter une commande bloquée et consulter les encaissements à la livraison ainsi que les commissions dues et réglées.

### Jalon : MVP admin

À la fin des trois premiers lots (éléments P0), le backoffice doit permettre de :

- Modérer les produits.
- Gérer les comptes et boutiques.
- Traiter les signalements.
- Superviser les commandes et intervenir dessus.
- Suivre les encaissements à la livraison et les commissions.
- Consulter l’historique des actions administratives.

## 4. Site web vendeur et acheteur

Les parcours mobiles sont validés aux lots 2 et 3 ; ce lot amène le web au même niveau.

- [ ] Brancher l’inscription web avec vérification du numéro par SMS.
- [ ] Brancher les formulaires encore simulés : profil, adresses, produits, panier, commande, messages et avis.
- [ ] Brancher les actions vendeur sur les commandes reçues et les réponses aux avis.
- [ ] Finaliser l’ouverture de boutique et la soumission des produits.
- [ ] Compléter les endpoints de statistiques vendeur, ventes et versements.
- [ ] Composer la page d’accueil à partir des endpoints du catalogue.
- [ ] Harmoniser les comportements web et mobile.

**Critère de validation :** sur le web, un vendeur soumet un produit, l’admin le valide, un acheteur commande, le vendeur traite la commande et l’acheteur confirme la réception puis laisse un avis.

## 5. Préparer la bêta et la production

La bêta s’ouvre en paiement à la livraison, sans attendre le lot 6.

- [ ] Compléter les tests automatisés des parcours critiques et des autorisations.
- [ ] Tester les achats concurrents, ruptures de stock et annulations.
- [ ] Valider le circuit de paiement à la livraison avec les participants : collecte, confirmation d’encaissement, suivi des commissions et traitement des écarts dans le backoffice.
- [ ] Déplacer les images vers un stockage adapté à la production.
- [ ] Préparer un environnement de préproduction sans données simulées.
- [ ] Mettre en place les sauvegardes et vérifier leur restauration.
- [ ] Configurer les journaux, alertes et suivi des erreurs.
- [ ] Automatiser le déploiement.
- [ ] Rédiger les conditions générales et les mentions légales.
- [ ] Publier l’application mobile sur les stores (prévoir les délais de validation).
- [ ] Lancer une bêta avec un petit groupe de vendeurs, acheteurs et administrateurs.

**Critère de validation :** les parcours critiques passent, le circuit d’encaissement à la livraison et de règlement des commissions est validé, les erreurs sont détectables et une restauration des données a été testée.

## 6. Paiements Mobile Money et administration financière

L’intégration démarre lorsque les accès d’un opérateur sont disponibles et que les règles de commande du lot 3 sont stabilisées. Elle peut se dérouler pendant la bêta, en tenant compte du temps consacré à son suivi. Les préparatifs techniques et les démarches opérateurs peuvent commencer plus tôt.

- [ ] Intégrer un premier opérateur Mobile Money, puis les suivants.
- [ ] Traiter les confirmations opérateur, échecs, délais et notifications reçues plusieurs fois.
- [ ] Empêcher les doubles paiements et doubles versements.
- [ ] Ajouter l’endpoint et la page admin **Transactions** : référence opérateur, commande, montant, statut et historique.
- [ ] Créer une page **Versements vendeurs** : montants dus, commissions, versements en attente, réussis ou échoués.
- [ ] Implémenter les transitions Mobile Money : confirmation d’encaissement, échec, annulation avant encaissement, remboursement et versement, en traitant aussi les confirmations tardives après annulation.
- [ ] Définir et implémenter les remboursements totaux et partiels, notamment lorsqu’une seule boutique refuse ou annule dans un panier multiboutique ; préserver les montants des autres commandes.
- [ ] Ajouter le rapprochement entre données internes et transactions opérateur.
- [ ] Restreindre et journaliser les interventions financières.
- [ ] Tester les pannes de paiement, notifications en double, confirmations tardives et remboursements partiels multiboutiques.

**Critère de validation :** chaque montant encaissé, remboursé ou versé peut être relié à une commande et à une opération identifiable ; les échecs restent visibles et peuvent être traités.

## Après le MVP

- Rôles admin spécialisés : support, modération et finance.
- Promotions et campagnes de notifications.
- Statistiques avancées et rapports programmés.
- Modération en masse.
- Suivi de boutiques, photos dans les messages et autres améliorations d’engagement.

## Premier sprint recommandé

1. Authentification admin réelle, avec renouvellement de session.
2. Intégration continue minimale.
3. Liste et détail des produits côté API et web.
4. Approbation et rejet persistants, avec motif obligatoire.
5. Journal d’audit.
6. Validation du parcours complet : **produit soumis sur mobile → décision admin sur le web → résultat visible côté vendeur**.

En parallèle : lancer les demandes d’accès auprès des opérateurs Mobile Money.

## Références du projet

- [Architecture et rôles](architecture.md)
- [Contrôleur admin](../api/src/main/java/mg/inmybush/api/admin/controller/AdminController.java)
- [Service admin](../api/src/main/java/mg/inmybush/api/admin/service/AdminService.java)
- [Client API admin web](../web/src/lib/api/admin.ts)
- [Protection des routes web](../web/src/proxy.ts)
- [Navigation admin](../web/src/components/layout/AdminNav.tsx)
