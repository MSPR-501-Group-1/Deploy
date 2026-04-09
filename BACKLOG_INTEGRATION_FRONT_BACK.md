# BACKLOG INTEGRATION FRONT-BACK — MSPR HealthAI

## Scope appliqué
Périmètre strictement retenu:
- Uniquement des tâches avec impact Frontend et Backend.
- Aucun ticket Backend-only.
- Aucun ticket Frontend-only.
- Aucun ticket ETL ou Spark/Python.
- Uniquement exploitation du schéma et du seed SQL actuels, sans refonte de modèle.
- Exclusion des tâches déjà implémentées en bout-en-bout (auth login/logout, gestion utilisateurs, analytics business, analytics fitness pour rôle ADMIN).

## Tickets restants (triés par priorité puis dépendances)

### INT-FB-001
ID: INT-FB-001
Titre: Aligner RBAC Analytics Fitness entre Front et Back
**Statut: DONE**
Description: Harmoniser les rôles autorisés sur la page Fitness et sur la route API associée pour éliminer les 403 fonctionnels.
Il manque quoi et pourquoi: Il manque un contrat RBAC unique car le Front autorise plusieurs rôles alors que le Back limite actuellement à ADMIN.
Impact évaluation (critère de grille concerné): Sécurité et accès différencié par rôle, cohérence de l’interface d’administration.
Périmètre impacté (au moins 1 fichier Front + 1 fichier Back): Front [frontend/healthai-admin/src/lib/nav.constants.ts](frontend/healthai-admin/src/lib/nav.constants.ts), [frontend/healthai-admin/src/routes/index.tsx](frontend/healthai-admin/src/routes/index.tsx) ; Back [backend/routes/userMetrics.route.js](backend/routes/userMetrics.route.js), [backend/middlewares/auth.middleware.js](backend/middlewares/auth.middleware.js)
Données DB concernées (tables/champs): user_.role_id, role.role_id, role.role_type
Critères d’acceptation (Definition of Done):
1. Le même set de rôles est appliqué côté garde Front et middleware Back pour le flux Fitness.
2. Un utilisateur autorisé côté Front ne reçoit plus de 403 sur GET /metrics/fitness.
3. Un utilisateur non autorisé est bloqué de manière cohérente côté Front et côté Back.
Estimation IA agent (heures): 4
Priorité: P0
Faisabilité: Haute
Dépendances / blocages: Aucun
Date de démarrage: 2026-04-05
Date de réalisation: 2026-04-05
Temps réel passé (heures): 1.4
Statut détaillé: ON GOING -> DONE (validations Front + Back OK)
Règle RBAC appliquée (dérivée DB): role_type autorisés sur Fitness = ADMIN, PREMIUM, PREMIUM_PLUS, B2B (enum + seed DB), FREEMIUM explicitement exclu.
Fichiers modifiés:
- backend/routes/userMetrics.route.js
- frontend/healthai-admin/src/lib/nav.constants.ts
- BACKLOG_INTEGRATION_FRONT_BACK.md
Preuves d'exécution:
- Vérification source de vérité DB:
	- database/01_initdb.sql: role_type_enum = FREEMIUM, PREMIUM, PREMIUM_PLUS, B2B, ADMIN
	- database/02_seed.sql: rôles seedés ROLE_01..ROLE_05 alignés sur ces 5 valeurs
- Validation API backend après rebuild `docker compose up -d --build backend`:
	- Login PREMIUM (`alice.martin@email.com`) + GET /metrics/fitness?range=30d -> HTTP 200, `success=true`
	- Login FREEMIUM (`bob.dupont@email.com`) + GET /metrics/fitness?range=30d -> HTTP 403, message `Accès non autorisé pour ce rôle`
- Validation Front:
	- `npm run build` dans frontend/healthai-admin -> succès (warning Node/Vite déjà connu hors périmètre)
	- Contrat unique appliqué navigation + guard Fitness via `ANALYTICS_ROLES` (même set que backend)
Blocages éventuels:
- Aucun blocage fonctionnel. Point d'attention: un rebuild du conteneur backend était nécessaire pour charger la nouvelle règle RBAC.

### INT-FB-002
ID: INT-FB-002
Titre: Connecter le Dashboard principal à une API réelle
**Statut: TODO**
Description: Remplacer la source mock du Dashboard par une agrégation Backend basée sur les tables SQL existantes.
Il manque quoi et pourquoi: Il manque un endpoint Dashboard car la page consomme encore des mocks par défaut.
Impact évaluation (critère de grille concerné): Interface web + dashboard interactif, API REST exploitable par le Front.
Périmètre impacté (au moins 1 fichier Front + 1 fichier Back): Front [frontend/healthai-admin/src/services/dashboard.service.ts](frontend/healthai-admin/src/services/dashboard.service.ts), [frontend/healthai-admin/src/features/dashboard/DashboardPage.tsx](frontend/healthai-admin/src/features/dashboard/DashboardPage.tsx) ; Back [backend/routes/analytics.route.js](backend/routes/analytics.route.js), [backend/controllers/analyticsController/businessKpi.controller.js](backend/controllers/analyticsController/businessKpi.controller.js), [backend/services/analyticsService/businessKpi.service.js](backend/services/analyticsService/businessKpi.service.js), [backend/app.js](backend/app.js)
Données DB concernées (tables/champs): login_history.last_login, login_history.user_id, etl_execution.started_at, etl_execution.status, etl_execution.records_extracted, etl_execution.records_loaded, data_source.source_name, data_quality_check_.records_failed, data_quality_check_.records_checked, data_anomaly.detected_at, data_anomaly.is_resolved
Critères d’acceptation (Definition of Done):
1. GET /dashboard retourne un payload compatible avec les KPIs et séries de la page Dashboard.
2. La page Dashboard charge les données réelles sans fallback mock en environnement Docker.
3. Les cartes KPI et graphiques affichent des valeurs cohérentes avec le seed SQL.
Estimation IA agent (heures): 12
Priorité: P0
Faisabilité: Haute
Dépendances / blocages: Aucun

### INT-FB-003
ID: INT-FB-003
Titre: Brancher Data Quality sur les contrôles SQL réels
**Statut: TODO**
Description: Alimenter DataQualityPage depuis data_quality_check_ et non depuis dataQualityMock.
Il manque quoi et pourquoi: Il manque un endpoint Data Quality car la page lit encore une source simulée.
Impact évaluation (critère de grille concerné): Suivi qualité des données, visualisation des indicateurs de qualité.
Périmètre impacté (au moins 1 fichier Front + 1 fichier Back): Front [frontend/healthai-admin/src/services/data-quality.service.ts](frontend/healthai-admin/src/services/data-quality.service.ts), [frontend/healthai-admin/src/features/data-quality/DataQualityPage.tsx](frontend/healthai-admin/src/features/data-quality/DataQualityPage.tsx) ; Back [backend/routes/analytics.route.js](backend/routes/analytics.route.js), [backend/controllers/analyticsController/businessKpi.controller.js](backend/controllers/analyticsController/businessKpi.controller.js), [backend/services/analyticsService/businessKpi.service.js](backend/services/analyticsService/businessKpi.service.js), [backend/app.js](backend/app.js)
Données DB concernées (tables/champs): data_quality_check_.check_type, data_quality_check_.records_checked, data_quality_check_.records_failed, data_quality_check_.checked_at, data_quality_check_.status, data_quality_check_.target_table, etl_execution.execution_id
Critères d’acceptation (Definition of Done):
1. GET /data-quality/score retourne overall, dimensions et history au format attendu par le Front.
2. Les dimensions affichées sont calculées uniquement depuis les checks existants en base.
3. La page Data Quality fonctionne avec USE_MOCK désactivé.
Estimation IA agent (heures): 10
Priorité: P0
Faisabilité: Haute
Dépendances / blocages: Aucun

### INT-FB-004
ID: INT-FB-004
Titre: Connecter le monitoring Pipeline ETL au backend SQL
**Statut: TODO**
Description: Exposer l’historique des runs ETL pour PipelinePage via etl_execution + data_source.
Il manque quoi et pourquoi: Il manque l’endpoint pipeline car le Front s’appuie encore sur pipelineMock.
Impact évaluation (critère de grille concerné): Visualisation des flux d’ingestion, traçabilité des exécutions.
Périmètre impacté (au moins 1 fichier Front + 1 fichier Back): Front [frontend/healthai-admin/src/services/pipeline.service.ts](frontend/healthai-admin/src/services/pipeline.service.ts), [frontend/healthai-admin/src/features/data/PipelinePage.tsx](frontend/healthai-admin/src/features/data/PipelinePage.tsx) ; Back [backend/routes/analytics.route.js](backend/routes/analytics.route.js), [backend/controllers/analyticsController/businessKpi.controller.js](backend/controllers/analyticsController/businessKpi.controller.js), [backend/services/analyticsService/businessKpi.service.js](backend/services/analyticsService/businessKpi.service.js), [backend/app.js](backend/app.js)
Données DB concernées (tables/champs): etl_execution.execution_id, etl_execution.started_at, etl_execution.ended_at, etl_execution.status, etl_execution.records_extracted, etl_execution.records_rejected, etl_execution.triggered_by, etl_execution.source_id, data_source.source_id, data_source.source_name
Critères d’acceptation (Definition of Done):
1. GET /data/pipeline retourne la liste des runs au format PipelineRun attendu.
2. Les statuts success/failed/running/pending sont dérivés de la donnée SQL existante sans nouvelle table.
3. Le filtre de statut et le tri de la page Pipeline fonctionnent en données réelles.
Estimation IA agent (heures): 8
Priorité: P0
Faisabilité: Haute
Dépendances / blocages: Aucun

### INT-FB-005
ID: INT-FB-005
Titre: Connecter AnomaliesPage à data_anomaly avec correction persistée
**Statut: TODO**
Description: Rendre opérationnels la liste anomalies et le patch de correction via API Backend réelle.
Il manque quoi et pourquoi: Il manque des endpoints anomalies car la correction est encore simulée côté Front.
Impact évaluation (critère de grille concerné): Outils de nettoyage interactifs, workflow de correction manuelle.
Périmètre impacté (au moins 1 fichier Front + 1 fichier Back): Front [frontend/healthai-admin/src/services/anomalies.service.ts](frontend/healthai-admin/src/services/anomalies.service.ts), [frontend/healthai-admin/src/features/anomalies/AnomaliesPage.tsx](frontend/healthai-admin/src/features/anomalies/AnomaliesPage.tsx), [frontend/healthai-admin/src/components/anomalies/CorrectionDialog.tsx](frontend/healthai-admin/src/components/anomalies/CorrectionDialog.tsx) ; Back [backend/routes/analytics.route.js](backend/routes/analytics.route.js), [backend/controllers/analyticsController/businessKpi.controller.js](backend/controllers/analyticsController/businessKpi.controller.js), [backend/services/analyticsService/businessKpi.service.js](backend/services/analyticsService/businessKpi.service.js), [backend/app.js](backend/app.js)
Données DB concernées (tables/champs): data_anomaly.anomaly_id, data_anomaly.detected_at, data_anomaly.severity, data_anomaly.field_name, data_anomaly.original_value, data_anomaly.is_resolved, data_anomaly.resolution_action, data_anomaly.check_id, data_anomaly.execution_id, data_quality_check_.check_type
Critères d’acceptation (Definition of Done):
1. GET /anomalies retourne une liste compatible avec le type Anomaly du Front.
2. PATCH /anomalies/:id/correct met à jour is_resolved et resolution_action en base.
3. Une correction faite dans l’UI est visible après rechargement de la page.
Estimation IA agent (heures): 12
Priorité: P0
Faisabilité: Haute
Dépendances / blocages: INT-FB-003

### INT-FB-006
ID: INT-FB-006
Titre: Rendre le workflow Validation exploitable sans nouvelle table
**Statut: TODO**
Description: Mapper ValidationPage sur le modèle SQL existant en utilisant etl_execution comme batch et data_anomaly comme records KO.
Il manque quoi et pourquoi: Il manque les endpoints validation car le workflow actuel repose sur une structure mock non branchée.
Impact évaluation (critère de grille concerné): Workflow de validation/approbation avant exploitation des données.
Périmètre impacté (au moins 1 fichier Front + 1 fichier Back): Front [frontend/healthai-admin/src/services/validation.service.ts](frontend/healthai-admin/src/services/validation.service.ts), [frontend/healthai-admin/src/features/data/ValidationPage.tsx](frontend/healthai-admin/src/features/data/ValidationPage.tsx) ; Back [backend/routes/analytics.route.js](backend/routes/analytics.route.js), [backend/controllers/analyticsController/businessKpi.controller.js](backend/controllers/analyticsController/businessKpi.controller.js), [backend/services/analyticsService/businessKpi.service.js](backend/services/analyticsService/businessKpi.service.js), [backend/app.js](backend/app.js)
Données DB concernées (tables/champs): etl_execution.execution_id, etl_execution.status, etl_execution.records_rejected, etl_execution.started_at, etl_execution.source_id, data_anomaly.anomaly_id, data_anomaly.execution_id, data_anomaly.field_name, data_anomaly.original_value, data_anomaly.is_resolved, data_anomaly.resolution_action, data_source.source_name
Critères d’acceptation (Definition of Done):
1. Les routes validation renvoient des lots et des records construits à partir des tables existantes.
2. Les actions corriger/ignorer/modifier d’un record mettent à jour data_anomaly.
3. Les actions approuver/rejeter d’un lot modifient un indicateur existant de etl_execution sans ajout de colonne.
4. La page Validation fonctionne entièrement sans validationMock.
Estimation IA agent (heures): 18
Priorité: P1
Faisabilité: Moyenne
Dépendances / blocages: INT-FB-004, INT-FB-005

### INT-FB-007
ID: INT-FB-007
Titre: Brancher PartnersPage sur organization et activity réelle
**Statut: DONE**
Description: Alimenter la vue partenaires B2B avec des agrégats SQL existants au lieu du mock.
Il manque quoi et pourquoi: Il manque des endpoints partenaires car la page n’est pas connectée à la base réelle.
Impact évaluation (critère de grille concerné): Exploitation business B2B et visualisation pour pilotage.
Périmètre impacté (au moins 1 fichier Front + 1 fichier Back): Front [frontend/healthai-admin/src/services/partners.service.ts](frontend/healthai-admin/src/services/partners.service.ts), [frontend/healthai-admin/src/features/partners/PartnersPage.tsx](frontend/healthai-admin/src/features/partners/PartnersPage.tsx) ; Back [backend/routes/analytics.route.js](backend/routes/analytics.route.js), [backend/controllers/analyticsController/businessKpi.controller.js](backend/controllers/analyticsController/businessKpi.controller.js), [backend/services/analyticsService/businessKpi.service.js](backend/services/analyticsService/businessKpi.service.js), [backend/app.js](backend/app.js)
Données DB concernées (tables/champs): organization.organization_id, organization.name, user_organization.organization_id, user_organization.user_id, user_.user_id, user_.role_id, role.role_type, login_history.last_login, workout_session.start_at
Critères d’acceptation (Definition of Done):
1. GET /partners et GET /partners/dashboard sont disponibles et sécurisés.
2. PartnersPage affiche la liste et les graphiques sur données SQL réelles.
3. usersCount est calculée via agrégats SQL; apiCallsMonth est explicitement neutralisée et remplacée par activityEvents30d (connexions + sessions workout 30j).
Estimation IA agent (heures): 14
Priorité: P1
Faisabilité: Moyenne
Dépendances / blocages: INT-FB-002
Date de démarrage: 2026-04-05
Date de réalisation: 2026-04-05
Temps réel passé (heures): 2.2
Statut détaillé: ON GOING -> DONE (API partenaires + RBAC + build frontend validés)
Décision métrique apiCallsMonth: non calculable proprement avec le schéma actuel (aucune table de logs API). La métrique est conservée en UI avec fallback "Non disponible" et remplacée fonctionnellement par activityEvents30d calculée depuis login_history + workout_session sur 30 jours.
Fichiers modifiés:
- BACKLOG_INTEGRATION_FRONT_BACK.md
- backend/app.js
- backend/controllers/analyticsController/businessKpi.controller.js
- backend/middlewares/auth.middleware.js
- backend/routes/analytics.route.js
- backend/services/analyticsService/businessKpi.service.js
- frontend/healthai-admin/src/components/partners/PartnerUsageChart.tsx
- frontend/healthai-admin/src/features/partners/PartnersPage.tsx
- frontend/healthai-admin/src/lib/nav.constants.ts
- frontend/healthai-admin/src/mocks/partners.mock.ts
- frontend/healthai-admin/src/routes/index.tsx
- frontend/healthai-admin/src/services/partners.service.ts
- frontend/healthai-admin/src/types/index.ts
Preuves d'exécution:
- Source DB vérifiée sur schéma/seed: database/01_initdb.sql (organization, user_organization, user_, role, login_history, workout_session) + database/02_seed.sql (données ORG_001..ORG_005 et associations utilisateur-organisation).
- Exécution backend réelle en conteneur: docker compose up -d --build db backend -> database healthy + backend started.
- Test API manuel (rôle autorisé B2B: david.petit@email.com):
	- GET /partners -> HTTP 200, success=true, count=5
	- GET /partners/dashboard -> HTTP 200, success=true, partners=5, usagePoints=5
- Test API manuel (rôle non autorisé PREMIUM: alice.martin@email.com):
	- GET /partners -> HTTP 403, message "Accès non autorisé pour ce rôle"
	- GET /partners/dashboard -> HTTP 403, message "Accès non autorisé pour ce rôle"
- Payload réel vérifié: partner row contient usersCount/activeUsers30d/logins30d/workoutSessions30d/activityEvents30d calculés; apiCallsMonth/contractStart/contractEnd/satisfactionScore à null avec fallback UI explicite.
- Build frontend validé: npm run build (success). Warning environnement existant: Node 22.11.0 < 22.12 recommandé par Vite.
- Cohérence RBAC front/back validée:
	- Front navigation + route guard partenaires: PARTNER_ROLES = ADMIN,B2B
	- Back middleware partenaires: ROLE_GROUPS.PARTNERS = ADMIN,B2B
- PartnersPage n'utilise plus le mock en runtime: partners.service.ts appelle uniquement /partners et /partners/dashboard.
Blocages éventuels:
- Aucun blocage fonctionnel sur INT-FB-007.

### INT-FB-008
ID: INT-FB-008
Titre: Compléter l’intégration Analytics Nutrition + Biométrique
**Statut: TODO**
Description: Ajouter les flux Front+Back manquants pour les analyses nutritionnelles et biométriques demandées par le sujet.
Il manque quoi et pourquoi: Il manque les routes UI et endpoints API nutrition/biométrique car seuls business et fitness sont branchés.
Impact évaluation (critère de grille concerné): Analyses nutritionnelles et biométriques, visualisation métier complète.
Périmètre impacté (au moins 1 fichier Front + 1 fichier Back): Front [frontend/healthai-admin/src/routes/index.tsx](frontend/healthai-admin/src/routes/index.tsx), [frontend/healthai-admin/src/services/analytics.service.ts](frontend/healthai-admin/src/services/analytics.service.ts), [frontend/healthai-admin/src/lib/nav.constants.ts](frontend/healthai-admin/src/lib/nav.constants.ts) ; Back [backend/routes/analytics.route.js](backend/routes/analytics.route.js), [backend/controllers/analyticsController/businessKpi.controller.js](backend/controllers/analyticsController/businessKpi.controller.js), [backend/services/analyticsService/businessKpi.service.js](backend/services/analyticsService/businessKpi.service.js), [backend/app.js](backend/app.js)
Données DB concernées (tables/champs): meal.meal_id, meal.consumed_at, meal.calories_consumed, meal.user_id, meal_ingredient.ingredient_id, meal_ingredient.quantity, ingredient.protein_g, ingredient.carbs_g, ingredient.fat_g, ingredient.calories_g, user_metrics.recorded_date, user_metrics.weight_kg, user_metrics.heart_rate_avg, user_metrics.sleep_hours, user_.user_id
Critères d’acceptation (Definition of Done):
1. Les routes Front analytics/nutrition et analytics/biometric existent et sont accessibles via navigation.
2. Les endpoints Back correspondants retournent des structures AnalyticsPageData compatibles.
3. Les deux pages affichent des données réelles et gèrent loading/error via React Query.
Estimation IA agent (heures): 20
Priorité: P1
Faisabilité: Moyenne
Dépendances / blocages: INT-FB-001

### INT-FB-009
ID: INT-FB-009
Titre: Connecter AuditPage à un journal consolidé SQL existant
**Statut: BACKLOG**
Description: Exposer un endpoint audit consolidant les traces disponibles sans créer de nouvelle table.
Il manque quoi et pourquoi: Il manque un endpoint audit réel car la page dépend encore de auditMock.
Impact évaluation (critère de grille concerné): Traçabilité et auditabilité des opérations d’administration.
Périmètre impacté (au moins 1 fichier Front + 1 fichier Back): Front [frontend/healthai-admin/src/services/audit.service.ts](frontend/healthai-admin/src/services/audit.service.ts), [frontend/healthai-admin/src/features/admin/AuditPage.tsx](frontend/healthai-admin/src/features/admin/AuditPage.tsx) ; Back [backend/routes/analytics.route.js](backend/routes/analytics.route.js), [backend/controllers/analyticsController/businessKpi.controller.js](backend/controllers/analyticsController/businessKpi.controller.js), [backend/services/analyticsService/businessKpi.service.js](backend/services/analyticsService/businessKpi.service.js), [backend/app.js](backend/app.js)
Données DB concernées (tables/champs): login_history.last_login_id, login_history.user_id, login_history.last_login, etl_execution.execution_id, etl_execution.triggered_by, etl_execution.started_at, etl_execution.ended_at, data_anomaly.anomaly_id, data_anomaly.resolution_action, data_anomaly.detected_at
Critères d’acceptation (Definition of Done):
1. GET /admin/audit renvoie des événements horodatés exploitables dans AuditPage.
2. Les filtres action et date de la page fonctionnent sur les données SQL réelles.
3. Le format export CSV/PDF de la page reste intact après branchement API.
Estimation IA agent (heures): 10
Priorité: P2
Faisabilité: Moyenne
Dépendances / blocages: INT-FB-005, INT-FB-006

### INT-FB-010
ID: INT-FB-010
Titre: Finaliser la bascule globale Mock vers API réelle en Docker
**Statut: TODO**
Description: Fermer la bascule d’intégration pour que les services Front utilisent l’API réelle en exécution standard et que les nouveaux endpoints soient documentés.
Il manque quoi et pourquoi: Il manque une bascule de production explicite car USE_MOCK reste vrai par défaut et masque les écarts d’intégration.
Impact évaluation (critère de grille concerné): Démonstration bout-en-bout DB → API → UI, API documentée et exploitable.
Périmètre impacté (au moins 1 fichier Front + 1 fichier Back): Front [frontend/healthai-admin/src/lib/env.ts](frontend/healthai-admin/src/lib/env.ts), [frontend/Dockerfile](frontend/Dockerfile), [.env.example](.env.example) ; Back [backend/swagger-output.json](backend/swagger-output.json), [backend/server.js](backend/server.js), [backend/app.js](backend/app.js)
Données DB concernées (tables/champs): Toutes les tables déjà mobilisées par INT-FB-002 à INT-FB-009
Critères d’acceptation (Definition of Done):
1. Le build Docker Front n’active plus les mocks par défaut.
2. Les services Dashboard, Pipeline, Data Quality, Anomalies, Validation, Partners et Audit appellent tous des endpoints réels.
3. La documentation Swagger reflète les endpoints réellement consommés par le Front.
4. Le parcours démo principal est validé en bout-en-bout sans mock.
Estimation IA agent (heures): 8
Priorité: P2
Faisabilité: Haute
Dépendances / blocages: INT-FB-002, INT-FB-003, INT-FB-004, INT-FB-005, INT-FB-006, INT-FB-007, INT-FB-008, INT-FB-009

## Non retenu (contexte insuffisant)
- Intégration persistante de la page Configuration non retenue en ticket dédié car aucune table de configuration n’existe dans le schéma SQL actuel pour stocker règles et seuils.
- Traçabilité réglementaire exhaustive qui/quoi/quand/depuis où non retenue en ticket dédié car il n’existe pas de table d’audit applicatif dédiée dans le schéma actuel.
- Couverture fine des critères chiffrés de la grille PDF officielle non retenue au niveau mot-à-mot car les PDF de grille/sujet ne sont pas exploitables en texte dans le repo; la base d’analyse repose sur les documents markdown de cadrage déjà présents.

## Récapitulatif
Total tickets: 10
Total heures estimées: 116
Répartition priorités: P0 = 5, P1 = 3, P2 = 2, P3 = 0

---

## Ajouts Frontend-only

### FE-001
ID: FE-001
Titre: Ajouter l'export JSON dans l'interface admin
**Statut: BACKLOG**
Il manque quoi et pourquoi: Il manque l'export JSON car l'UI n'exporte actuellement que CSV/PDF alors que le sujet demande JSON/CSV.
Description: Etendre le composant d'export pour proposer JSON sur les ecrans deja exportables (Dashboard, Anomalies, Audit, Validation).
Critere sujet/grille concerne: Export des donnees nettoyees en JSON ou CSV.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (section Interface d'administration: export JSON/CSV)
- DB: database/01_initdb.sql et database/02_seed.sql (donnees deja disponibles)
- Backend: backend/controllers/* (reponses JSON natives)
- Frontend: frontend/healthai-admin/src/components/feedback/ExportButton.tsx, frontend/healthai-admin/src/lib/export.utils.ts (CSV/PDF uniquement)
Perimetre impacte: frontend/healthai-admin/src/components/feedback/ExportButton.tsx, frontend/healthai-admin/src/lib/export.utils.ts
Donnees DB concernees si applicable: N/A (consommation des payloads deja exposes)
Definition of Done:
1. Le menu Exporter propose CSV, JSON et PDF (PDF conserve).
2. Le fichier JSON telecharge est valide et conforme aux lignes affichees.
3. Aucun comportement regressif sur CSV/PDF.
Estimation IA agent (heures): 4
Priorite (P0/P1/P2/P3): P1
Faisabilite (Haute/Moyenne/Faible): Haute
Dependances: Aucune

### FE-002
ID: FE-002
Titre: Implementer les pages Front Analytics Nutrition et Biometrique
**Statut: DONE**
Il manque quoi et pourquoi: Il manque les pages et routes UI nutrition/biometrique car elles sont referencees (redirections legacy) mais non implementees.
Description: Creer les deux pages React, les brancher au routing protege, a la navigation et aux services frontend dedies.
Critere sujet/grille concerne: Analyses nutritionnelles et indicateurs biometriques visualisables dans l'interface.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (analyses nutritionnelles, donnees biometriques)
- DB: database/01_initdb.sql (meal, meal_ingredient, ingredient, user_metrics)
- Backend: backend/routes/analytics.route.js, backend/controllers/analyticsController/businessKpi.controller.js, backend/services/analyticsService/businessKpi.service.js (endpoints nutrition/biometrique exposes)
- Frontend: frontend/healthai-admin/src/routes/index.tsx (redirections /analytics/nutrition et /analytics/biometric sans pages), frontend/healthai-admin/src/features/analytics (Business/Fitness uniquement)
Perimetre impacte: frontend/healthai-admin/src/routes/index.tsx, frontend/healthai-admin/src/lib/nav.constants.ts, frontend/healthai-admin/src/services/analytics.service.ts, frontend/healthai-admin/src/features/analytics/NutritionPage.tsx, frontend/healthai-admin/src/features/analytics/BiometricPage.tsx
Donnees DB concernees si applicable: meal.*, meal_ingredient.*, ingredient.*, user_metrics.*
Definition of Done:
1. Les routes /analytics/nutrition et /analytics/biometric existent et sont protegees par role.
2. Les deux pages gerent loading/error et affichent KPIs + series + distribution.
3. Les entrees de navigation associees sont visibles pour les roles autorises.
Estimation IA agent (heures): 10
Priorite (P0/P1/P2/P3): P1
Faisabilite (Haute/Moyenne/Faible): Moyenne
Dependances: BE-004, BE-005
Date de demarrage: 2026-04-04
Date de realisation: 2026-04-04
Temps reel passe (heures): 2.7
Preuves d'execution:
- Commit source restauration: dd3817fd1aec62776e490725e10e602c81c12571 (parent utilise pour recuperer NutritionPage.tsx et BiometricPage.tsx)
- Validation lint: npm run lint -> echec sur erreurs preexistantes hors perimetre FE-002 (src/api/client.ts, src/components/layout/Sidebar.tsx, src/routes/guards.tsx, src/routes/index.tsx)
- Validation build: npm run build -> succes (tsc -b + vite build), avec warning environnement Node 22.11.0 inferieur a 22.12 recommande par Vite
- Verification navigation/routes: routes /analytics/nutrition et /analytics/biometric presentes, lazy imports actifs et entrees navigation ajoutees
- Verification loading/error: LoadingState et ErrorState verifies sur NutritionPage et BiometricPage
- Verification E2E apres livraison backend: endpoints /analytics/nutrition et /analytics/biometric valides en direct backend et via proxy frontend (/api) sur ranges 7d/30d/90d/all
Compromis et points incertains:
- Le role de section analytics dans nav.constants.ts reste ADMIN_ROLES pour eviter une regression de comportement RBAC existante, tandis que les routes nutrition/biometric utilisent ANALYTICS_ROLES comme fitness.

### FE-003
ID: FE-003
Titre: Basculer le frontend en mode API reelle par defaut
**Statut: TODO**
Il manque quoi et pourquoi: Il manque une bascule front fiable car USE_MOCK reste actif par defaut et masque les ecarts de livraison reel.
Description: Rendre le mode mock opt-in (dev) et non opt-out, avec comportement degrade explicite sur endpoint indisponible.
Critere sujet/grille concerne: Chaine reproductible API REST -> Interface web et demonstration en environnement deploiable.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (API REST exploitable par front)
- DB: database/01_initdb.sql, database/02_seed.sql (jeu de donnees demo disponible)
- Backend: backend/app.js (API active sur routes metier)
- Frontend: frontend/healthai-admin/src/lib/env.ts (USE_MOCK true par defaut)
Perimetre impacte: frontend/healthai-admin/src/lib/env.ts, frontend/Dockerfile, .env.example
Donnees DB concernees si applicable: N/A
Definition of Done:
1. En build standard, le frontend n'utilise pas les mocks par defaut.
2. Le mode mock reste activable explicitement pour developpement local.
3. En cas d'endpoint absent, l'UI affiche un etat d'indisponibilite explicite.
Estimation IA agent (heures): 3
Priorite (P0/P1/P2/P3): P0
Faisabilite (Haute/Moyenne/Faible): Haute
Dependances: Aucune

### FE-004
ID: FE-004
Titre: Completer l'accessibilite frontend des vues DataViz critiques
**Statut: TODO**
Il manque quoi et pourquoi: Il manque des alternatives textuelles et parcours clavier complets car la conformite RGAA AA est partielle sur les visualisations.
Description: Renforcer Dashboard, Data Quality, Business, Anomalies, Validation avec descriptions, focus management, labels et etats ARIA harmonises.
Critere sujet/grille concerne: Tableau de bord interactif conforme accessibilite (RGAA niveau AA).
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (exigence accessibilite RGAA AA)
- DB: N/A
- Backend: N/A
- Frontend: frontend/lighthouse/LIGHTHOUSE_A11Y_COMMANDS.md, frontend/healthai-admin/src/features/* (etat partiel)
Perimetre impacte: frontend/healthai-admin/src/features/dashboard/DashboardPage.tsx, frontend/healthai-admin/src/features/data-quality/DataQualityPage.tsx, frontend/healthai-admin/src/features/analytics/BusinessPage.tsx, frontend/healthai-admin/src/components/*
Donnees DB concernees si applicable: N/A
Definition of Done:
1. Chaque graphe critique expose un resume textuel exploitable lecteur d'ecran.
2. Les actions principales sont 100% atteignables au clavier.
3. Le run Lighthouse a11y sur routes cibles ne remonte pas de blocant critique.
Estimation IA agent (heures): 8
Priorite (P0/P1/P2/P3): P1
Faisabilite (Haute/Moyenne/Faible): Moyenne
Dependances: Aucune

### FE-005
ID: FE-005
Titre: Fiabiliser la restitution d'erreur UI sur Auth et ecrans proteges
**Statut: ON GOING**
Il manque quoi et pourquoi: Il manque une strategie front unifiee de restitution d'erreur (query, mutation, auth/session) car plusieurs flux affichent des messages generiques ou silencieux.
Description: Creer un ticket parent de convergence pour structurer le traitement des erreurs visibles utilisateur sur Login, Data et Admin. Classification constatee: Frontend-only majoritaire (messages backend presents), avec verification integration front-back sur les statuts HTTP.
Critere sujet/grille concerne: API REST securisee et exploitable cote interface d'administration (retours erreurs comprehensibles en demonstration).
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (API REST securisee, interface admin exploitable)
- DB: N/A
- Backend: backend/controllers/authController/auth.controller.js, backend/middlewares/auth.middleware.js (messages 401/403/500 exposes)
- Frontend: frontend/healthai-admin/src/features/auth/LoginPage.tsx, frontend/healthai-admin/src/api/client.ts, frontend/healthai-admin/src/features/data/ValidationPage.tsx, frontend/healthai-admin/src/components/feedback/ErrorState.tsx
Perimetre impacte: frontend/healthai-admin/src/features/auth/LoginPage.tsx, frontend/healthai-admin/src/api/client.ts, frontend/healthai-admin/src/features/data/ValidationPage.tsx, frontend/healthai-admin/src/features/admin/UsersPage.tsx, frontend/healthai-admin/src/features/admin/ConfigPage.tsx, frontend/healthai-admin/src/features/anomalies/AnomaliesPage.tsx, frontend/healthai-admin/src/components/feedback/ErrorState.tsx
Donnees DB concernees si applicable: N/A
Definition of Done:
1. Une matrice de mapping erreur HTTP -> message UI/action utilisateur est definie et appliquee sur Auth + ecrans proteges critiques.
2. Les erreurs 401/403/500/reseau/timeout sont visibles en UI avec feedback actionnable.
3. Aucun ecran ne transforme une erreur API en etat vide trompeur.
4. Un protocole de test manuel couvre les 4 scenarios obligatoires et est rattache au ticket parent.
Estimation IA agent (heures): 2
Priorite (P0/P1/P2/P3): P0
Faisabilite (Haute/Moyenne/Faible): Haute
Dependances: FE-003
Etat detaille: Regression constatee au 2026-04-04 (ticket reouvert)
Date de realisation initiale: 2026-04-02
Date de revalidation: 2026-04-04
Temps reel passe (heures): 2.4 (historique)
Preuves d'execution:
- Commits de reference: 18f1ac7, 04878de (frontend/healthai-admin)
- Resultat synthetique: strategie unifiee de normalisation d'erreurs activee sur Auth et ecrans proteges, avec messages actionnables pour 401/403/500/reseau/timeout et suppression du faux etat vide sur Validation.
- Constat de re-audit (2026-04-04): frontend/healthai-admin/src/lib/error.utils.ts est absent, frontend/healthai-admin/src/api/client.ts redirige encore silencieusement sur 401 et frontend/healthai-admin/src/features/data/ValidationPage.tsx peut toujours afficher un etat vide quand la requete records echoue.
Preuves d'investigation:
- Scenarios testes:
	- Mauvais identifiants: POST /api/auth/login -> 401 {"success":false,"message":"Email ou mot de passe incorrect"}
	- Backend indisponible: backend stoppe + POST /api/auth/login -> 502 Bad Gateway
	- Erreur serveur 500: DB stoppee + POST /api/auth/login -> 500 {"success":false,"message":"Erreur lors de la connexion"}
	- Token invalide/session expiree: GET /api/users avec bearer invalide -> 401 {"success":false,"message":"Token invalide"}
- Resultat observe:
	- Login affiche bien un retour pour 401/500 mais peut exposer un message technique brut sur indisponibilite backend (502/Failed to fetch).
	- Sur ecrans proteges, un 401 declenche une redirection /login sans message contextualise a l'utilisateur.
	- Plusieurs mutations affichent seulement des messages generiques (sans detail backend).
	- Validation detail: erreur de chargement des records potentiellement rendue comme etat vide ("Aucun enregistrement KO").

### FE-006
ID: FE-006
Titre: Rendre les erreurs Login actionnables (401/500/reseau)
**Statut: ON GOING**
Il manque quoi et pourquoi: Il manque un mapping UX explicite pour les erreurs de connexion car la page Login repose sur err.message brut, ce qui produit des retours techniques peu exploitables en cas d'indisponibilite backend.
Description: Completer la restitution d'erreur du formulaire Login avec messages clairs et orientees action utilisateur (reessayer, verifier identifiants, contacter admin).
Critere sujet/grille concerne: Authentification securisee et utilisable en demonstration (retour d'erreur compréhensible).
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (API REST securisee)
- DB: N/A
- Backend: backend/controllers/authController/auth.controller.js (401/500 metier)
- Frontend: frontend/healthai-admin/src/features/auth/LoginPage.tsx, frontend/healthai-admin/src/stores/auth.store.ts
Perimetre impacte: frontend/healthai-admin/src/features/auth/LoginPage.tsx, frontend/healthai-admin/src/stores/auth.store.ts, frontend/healthai-admin/src/api/client.ts
Donnees DB concernees si applicable: N/A
Definition of Done:
1. Mauvais identifiants: message utilisateur clair et non technique.
2. Backend indisponible/reseau: message de service indisponible avec action proposee.
3. Erreur 500: message metier stable sans fuite technique.
4. Aucun affichage direct de statut technique brut (ex: Bad Gateway, Failed to fetch) dans l'alerte Login.
Estimation IA agent (heures): 4
Priorite (P0/P1/P2/P3): P0
Faisabilite (Haute/Moyenne/Faible): Haute
Dependances: FE-005
Etat detaille: Regression constatee au 2026-04-04 (ticket reouvert)
Date de realisation initiale: 2026-04-02
Date de revalidation: 2026-04-04
Temps reel passe (heures): 2.1 (historique)
Preuves d'execution:
- Commit de reference: 18f1ac7
- Scenarios valides: 401 mauvais identifiants, indisponibilite backend/reseau, erreur 500 backend.
- Resultat synthetique: Login affiche des messages clairs et actionnables (inline + snackbar) sans exposition de messages techniques bruts.
- Constat de re-audit (2026-04-04): frontend/healthai-admin/src/features/auth/LoginPage.tsx affiche encore err.message brut et peut exposer des messages techniques reseau (ex: Failed to fetch / Bad Gateway).

### FE-007
ID: FE-007
Titre: Rendre explicite token invalide/session expiree sur parcours protege
**Statut: ON GOING**
Il manque quoi et pourquoi: Il manque un feedback utilisateur avant/apres redirection login sur 401 car le client API redirige actuellement de facon silencieuse.
Description: Introduire une restitution explicite des erreurs de session (token invalide, token expire) pour que l'utilisateur comprenne la cause de la deconnexion sur les pages protegees.
Critere sujet/grille concerne: Securite d'acces par session + experience d'administration robuste.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (API securisee)
- DB: N/A
- Backend: backend/middlewares/auth.middleware.js (messages "Token expire" / "Token invalide")
- Frontend: frontend/healthai-admin/src/api/client.ts (window.location.href='/login' sur 401), frontend/healthai-admin/src/features/auth/LoginPage.tsx
Perimetre impacte: frontend/healthai-admin/src/api/client.ts, frontend/healthai-admin/src/stores/notification.store.ts, frontend/healthai-admin/src/features/auth/LoginPage.tsx, frontend/healthai-admin/src/routes/guards.tsx
Donnees DB concernees si applicable: N/A
Definition of Done:
1. Un 401 sur page protegee declenche une redirection vers /login avec message explicite conserve au moins un affichage.
2. Les cas token invalide vs session expiree sont differenciables si l'information backend est disponible.
3. Le feedback n'est pas perdu au rechargement immediat de la route login.
4. Le comportement reste coherent avec les guards d'authentification existants.
Estimation IA agent (heures): 6
Priorite (P0/P1/P2/P3): P0
Faisabilite (Haute/Moyenne/Faible): Moyenne
Dependances: FE-005
Etat detaille: Regression constatee au 2026-04-04 (ticket reouvert)
Date de realisation initiale: 2026-04-02
Date de revalidation: 2026-04-04
Temps reel passe (heures): 2.2 (historique)
Preuves d'execution:
- Commit de reference: 18f1ac7
- Resultat synthetique: sur 401 en route protegee, redirection vers /login avec message contextualise persiste (storage key healthai-auth-feedback) puis affiche au moins une fois.
- Controle coherence: guard RedirectIfAuth durci (isAuthenticated && user) pour eviter les redirections indues dues a un etat persiste incoherent.
- Constat de re-audit (2026-04-04): frontend/healthai-admin/src/api/client.ts redirige toujours vers /login sans message contextualise persiste et sans distinction explicite token invalide/session expiree.

### FE-008
ID: FE-008
Titre: Supprimer les erreurs silencieuses ou trop generiques sur Data/Admin
**Statut: ON GOING**
Il manque quoi et pourquoi: Il manque une restitution detaillee des erreurs sur plusieurs ecrans metiers, car les handlers onError et ErrorState restent generiques, et un cas Validation peut masquer une erreur en etat vide.
Description: Harmoniser l'affichage des erreurs query/mutation sur les ecrans Data/Admin pour remonter un message utile (backend si disponible) et distinguer erreur vs absence de donnees.
Critere sujet/grille concerne: Dashboard et workflow admin interactifs relies a des APIs REST avec retours d'etat exploitables.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (interface admin exploitable)
- DB: N/A
- Backend: backend/controllers/* (messages metier deja renvoyes dans les reponses d'erreur)
- Frontend: frontend/healthai-admin/src/features/data/ValidationPage.tsx, frontend/healthai-admin/src/features/admin/UsersPage.tsx, frontend/healthai-admin/src/features/admin/ConfigPage.tsx, frontend/healthai-admin/src/features/anomalies/AnomaliesPage.tsx, frontend/healthai-admin/src/components/feedback/ErrorState.tsx
Perimetre impacte: frontend/healthai-admin/src/features/data/ValidationPage.tsx, frontend/healthai-admin/src/features/admin/UsersPage.tsx, frontend/healthai-admin/src/features/admin/ConfigPage.tsx, frontend/healthai-admin/src/features/anomalies/AnomaliesPage.tsx, frontend/healthai-admin/src/features/dashboard/DashboardPage.tsx, frontend/healthai-admin/src/features/data/PipelinePage.tsx, frontend/healthai-admin/src/features/data-quality/DataQualityPage.tsx, frontend/healthai-admin/src/features/analytics/BusinessPage.tsx, frontend/healthai-admin/src/features/analytics/FitnessPage.tsx, frontend/healthai-admin/src/features/partners/PartnersPage.tsx, frontend/healthai-admin/src/features/admin/AuditPage.tsx, frontend/healthai-admin/src/components/feedback/ErrorState.tsx
Donnees DB concernees si applicable: N/A
Definition of Done:
1. Les erreurs de query affichent un message contextualise (statut + cause) au lieu d'un texte uniforme uniquement.
2. Les erreurs de mutation exposent le message backend quand disponible, sinon fallback controle.
3. Validation detail ne peut plus afficher "Aucun enregistrement KO" lorsqu'une erreur de chargement records survient.
4. Le comportement est coherent pour 403/500/reseau/timeout sur les ecrans cibles.
Estimation IA agent (heures): 8
Priorite (P0/P1/P2/P3): P1
Faisabilite (Haute/Moyenne/Faible): Moyenne
Dependances: FE-005, FE-003
Etat detaille: Regression constatee au 2026-04-04 (ticket reouvert)
Date de realisation initiale: 2026-04-02
Date de revalidation: 2026-04-04
Temps reel passe (heures): 3.0 (historique)
Preuves d'execution:
- Commit de reference: 04878de
- Resultat synthetique: ecrans Data/Admin/Analytics/Partners/Audit utilisent un mapping d'erreur coherent (message backend prioritaire + fallback controle), et Validation detail distingue erreur de chargement vs absence de donnees.
- Constat de re-audit (2026-04-04): le mapping unifie n'est plus present (frontend/healthai-admin/src/lib/error.utils.ts absent) et frontend/healthai-admin/src/features/data/ValidationPage.tsx ne distingue pas explicitement l'erreur de chargement records d'un vrai etat vide.

### FE-009
ID: FE-009
Titre: Stabiliser la chaine npm (erreurs lint + warnings build)
**Statut: BLOCKED**
Il manque quoi et pourquoi: Il manque un assainissement outillage npm car le projet affiche des erreurs bloquantes sur npm run lint et des warnings repetes au build npm run build, ce qui fragilise les validations de livraison.
Description: Corriger les erreurs ESLint existantes et traiter les warnings npm/build prioritaires (version Node, warnings Vite/chunk, deprecations) avec une regle claire de non-regression.
Critere sujet/grille concerne: Qualite logicielle, chaine de build reproductible et demonstration sans bruit technique.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (livrable deployable, demonstrable, robuste)
- DB: N/A
- Backend: N/A
- Frontend: frontend/healthai-admin/package.json, frontend/healthai-admin/eslint.config.js, frontend/healthai-admin/vite.config.ts
Perimetre impacte: frontend/healthai-admin/src/api/client.ts, frontend/healthai-admin/src/components/layout/Sidebar.tsx, frontend/healthai-admin/src/routes/guards.tsx, frontend/healthai-admin/src/routes/index.tsx, frontend/healthai-admin/package.json, frontend/healthai-admin/eslint.config.js, frontend/healthai-admin/vite.config.ts
Donnees DB concernees si applicable: N/A
Definition of Done:
1. npm run lint passe sans erreur sur frontend/healthai-admin.
2. npm run build passe sans warning critique bloquant de la chaine de release.
3. Version Node/npm cible documentee et coherente avec les prerequis Vite.
4. Le protocole de verification npm (install, typecheck, lint, build) est consigne dans la doc frontend.
Estimation IA agent (heures): 5
Priorite (P0/P1/P2/P3): P0
Faisabilite (Haute/Moyenne/Faible): Haute
Dependances: FE-003
Date de demarrage: 2026-04-05
Date de realisation: 2026-04-05
Date de revalidation: 2026-04-05
Temps reel passe (heures): 2.0
Temps passe audit (heures): 1.0
Etat detaille: ON GOING -> DONE (historique lot FE-009) -> BLOCKED (revalidation audit 2026-04-05: runtime local Node 22.11.0 hors prerequis Vite 7.3.1)
Preuves d'execution:
- npm run typecheck (frontend/healthai-admin) -> succes.
- npm run lint (frontend/healthai-admin) -> succes sans erreur.
- npm run verify (frontend/healthai-admin) -> typecheck OK + lint OK + build OK.
- Runtime local aligne sur Node 22.12.0 (runtime portable projet), warning Vite Node supprime lors du build.
- Erreur IDE/TypeScript resolue sur tsconfig.app.json: mapping alias rendu relatif ("./src/*") et suppression de baseUrl deprecie.
- Durcissement process FE-009 livre: scripts npm typecheck/verify, prerequis documentes dans README, fichier .nvmrc ajoute.
- Verification Docker outillage et image frontend:
	- docker --version -> 28.4.0
	- docker compose version -> v2.39.2-desktop.1
	- docker run --rm node:22-alpine node -v -> v22.21.1
	- docker compose build frontend -> succes (image rebuilt)
Revalidation audit d'execution technique (2026-04-05):
- Verdict binaire: FE-009 non complete.
- Commandes executees (frontend/healthai-admin):
	1. node -v -> v22.11.0
	2. npm -v -> 11.9.0
	3. npm ci -> warnings EBADENGINE (vite@7.3.1, @vitejs/plugin-react@5.1.4, eslint-visitor-keys@5.0.1) car Node 22.11.0 non supporte.
	4. npm run typecheck -> succes.
	5. npm run lint -> succes.
	6. npm run build -> succes avec warning Vite Node: "requires Node.js version 20.19+ or 22.12+".
	7. npm run verify -> succes fonctionnel mais warning Vite Node identique.
	8. npm run dev -- --host 127.0.0.1 --port 5173 -> serveur demarre, warning Vite Node identique, port 5173 deja occupe (fallback 5174).
	9. npm run test -> echec (script test absent), hors DoD FE-009.
	10. git -C frontend show --name-only cccfc6a -> confirme le lot FE-009.
	11. git -C frontend diff --name-status cccfc6a..HEAD -> aucun ecart (fichiers FE-009 inchanges).
- Resultats observes:
	- Lint/typecheck/build restent executables, mais la chaine npm n'est pas "sans warning" sur ce poste.
	- L'erreur Node persistante est reproductible sur install/build/verify/dev.
- Cause racine de l'erreur Node:
	- Runtime local = Node 22.11.0, inferieur au prerequis outillage (Vite/plugin React: >=22.12.0 ou >=20.19.0).
	- Le ticket FE-009 documente bien le prerequis (.nvmrc=22.12.0 + README), mais l'environnement local n'est pas aligne.
- Decision de perimetre:
	- IN-SCOPE FE-009 (le ticket couvre explicitement stabilisation npm + prerequis Node/npm).
	- Nature du blocage: environnement d'execution local non conforme, pas regression du code FE-009.
- Impact DoD:
	- DoD #1: OK.
	- DoD #2: NOK sur ce poste (warning Node persistant durant build/verify).
	- DoD #3: Partiel (documentation OK, runtime local non coherent).
	- DoD #4: OK.
- Prochaine action recommandee:
	- Correctif immediat: aligner le runtime local sur Node 22.12.0+ (ou 22.13+) puis relancer npm ci et npm run verify.
	- Ticket dedie recommande: ajouter une garde d'environnement (package.json engines + script de controle preflight) pour prevenir la recurrence multi-postes.
Fichiers modifies (lot FE-009):
- frontend/healthai-admin/src/api/client.ts
- frontend/healthai-admin/src/components/layout/Sidebar.tsx
- frontend/healthai-admin/src/features/auth/LoginPage.tsx
- frontend/healthai-admin/src/routes/guards.tsx
- frontend/healthai-admin/src/routes/index.tsx
- frontend/healthai-admin/src/components/analytics/AnalyticsPageLayout.tsx
- frontend/healthai-admin/vite.config.ts
- frontend/healthai-admin/package.json
- frontend/healthai-admin/README.md
- frontend/healthai-admin/.nvmrc
- frontend/healthai-admin/tsconfig.app.json

## Ajouts Backend-only

### BE-001
ID: BE-001
Titre: Corriger le mapping des variables DB du backend
**Statut: DONE**
Il manque quoi et pourquoi: Il manque la compatibilite DB_* car le backend lit POSTGRES_* alors que le compose backend injecte DB_*.
Description: Mettre a jour l'initialisation PG pour accepter DB_* et fallback POSTGRES_* sans changer le schema SQL.
Critere sujet/grille concerne: Deploiement reproductible et API backend operationnelle.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (solution automatisable, deployable)
- DB: database/01_initdb.sql (schema pret)
- Backend: backend/db.js (POSTGRES_* uniquement)
- Frontend: N/A
Perimetre impacte: backend/db.js, backend/README.md
Donnees DB concernees si applicable: Connexion globale a la base (toutes tables)
Definition of Done:
1. Le backend se connecte a PostgreSQL en docker compose sans variable additionnelle.
2. GET /health retourne database=up.
3. Aucun changement de schema SQL.
Estimation IA agent (heures): 3
Priorite (P0/P1/P2/P3): P0
Faisabilite (Haute/Moyenne/Faible): Haute
Dependances: Aucune
Date de realisation: 2026-03-29
Temps reel passe (heures): 1.2
Preuves d'execution:
- Endpoints testes: GET /health ; POST /auth/login ; GET /users (admin)
- Resultat synthetique: backend demarre en docker compose avec variables DB_* existantes, health retourne data.database=up, authentification et endpoints users restent operationnels.

### BE-002
ID: BE-002
Titre: Corriger la route de changement de mot de passe
**Statut: DONE**
Il manque quoi et pourquoi: Il manque SALT_ROUNDS dans auth.service car la fonction changePassword crash runtime.
Description: Rendre la route /users/:id/password fonctionnelle et testable avec hash bcrypt conforme.
Critere sujet/grille concerne: API securisee (authentification et gestion des comptes).
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (API REST securisee)
- DB: database/01_initdb.sql (user_.password_hash)
- Backend: backend/services/authService/auth.service.js (SALT_ROUNDS indefini)
- Frontend: N/A
Perimetre impacte: backend/services/authService/auth.service.js, backend/controllers/userController/user.controller.js
Donnees DB concernees si applicable: user_.user_id, user_.password_hash
Definition of Done:
1. PUT /users/:id/password retourne 200 sur mot de passe valide.
2. Les cas invalides retournent les statuts metier attendus (400/404).
3. Le hash en base est mis a jour et verifiable via login.
Estimation IA agent (heures): 2
Priorite (P0/P1/P2/P3): P0
Faisabilite (Haute/Moyenne/Faible): Haute
Dependances: Aucune
Date de realisation: 2026-04-02
Temps reel passe (heures): 1.4
Preuves d'execution (actualisation 2026-04-02):
- Endpoints testes: PUT /users/USR_001/password (200), PUT /users/USR_001/password avec mauvais current_password (400), PUT /users/USR_999/password (404), PUT /users/USR_001/password payload invalide (400), POST /auth/login (apres changement + apres restauration)
- Resultat synthetique: durcissement du resolveur SALT_ROUNDS (fallback borne 4..31) pour eviter tout crash runtime, hash bcrypt valide sur mise a jour, mapping d'erreurs confirme (400/404), login verifie apres changement et mot de passe seed restaure.

### BE-003
ID: BE-003
Titre: Realigner l'API user-profiles avec le schema SQL reel
**Statut: DONE**
Il manque quoi et pourquoi: Il manque une implementation compatible schema car l'API cible user_profile, table absente du SQL courant.
Description: Refaire le service profile sur user_ + user_health_goal sans refonte de modele.
Critere sujet/grille concerne: API de gestion des profils utilisateurs exploitable.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (CRUD utilisateurs/profils)
- DB: database/01_initdb.sql (absence user_profile, presence user_ et user_health_goal)
- Backend: backend/services/userService/userProfile.service.js (requetes sur user_profile)
- Frontend: N/A
Perimetre impacte: backend/services/userService/userProfile.service.js, backend/controllers/userController/userProfile.controller.js, backend/routes/userProfile.route.js, backend/schemas/userProfile.schema.js
Donnees DB concernees si applicable: user_.height_cm, user_.current_weight_kg, user_.allergies, user_.diet_type, user_health_goal.user_id, user_health_goal.goal_id
Definition of Done:
1. Les endpoints user-profiles ne font plus reference a une table inexistante.
2. GET/PUT profile renvoient des reponses coherentes avec le schema reel.
3. Les erreurs metier sont retournees en 4xx et non en 500 SQL.
Estimation IA agent (heures): 10
Priorite (P0/P1/P2/P3): P1
Faisabilite (Haute/Moyenne/Faible): Moyenne
Dependances: Aucune
Date de realisation: 2026-03-29
Temps reel passe (heures): 3.2
Preuves d'execution:
- Endpoints testes: GET /user-profiles/USR_001 (200), PUT /user-profiles/USR_001 (200), PUT /user-profiles/USR_001 avec goal_id invalide (400), GET /user-profiles/USR_999 (404), POST /user-profiles/USR_001 (201)
- Resultat synthetique: plus aucune requete vers user_profile, mapping actif sur user_ + user_health_goal, persistance verifiee apres mise a jour, retour en 4xx sur cas metier, profil seed restaure apres test.

### BE-004
ID: BE-004
Titre: Exposer un endpoint backend Analytics Nutrition
**Statut: DONE**
Il manque quoi et pourquoi: Il manque l'endpoint nutrition car le sujet demande cette analyse et la base contient deja les tables necessaires.
Description: Ajouter une route backend nutrition avec agrégats compatibles dashboard (kpis, series, repartition).
Critere sujet/grille concerne: Analyses nutritionnelles exploitables via API REST.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (analyses nutritionnelles)
- DB: database/01_initdb.sql (meal, meal_ingredient, ingredient)
- Backend: backend/routes/analytics.route.js, backend/controllers/analyticsController/businessKpi.controller.js, backend/services/analyticsService/businessKpi.service.js
- Frontend: frontend/healthai-admin/src/services/analytics.service.ts (consommation endpoint /analytics/nutrition)
Perimetre impacte: backend/routes/analytics.route.js, backend/controllers/analyticsController/businessKpi.controller.js, backend/services/analyticsService/businessKpi.service.js
Donnees DB concernees si applicable: meal.*, meal_ingredient.*, ingredient.*
Definition of Done:
1. Endpoint nutrition disponible avec filtre range (7d/30d/90d/all).
2. Payload aligne sur structure AnalyticsPageData.
3. Role-based access applique et documente.
Estimation IA agent (heures): 12
Priorite (P0/P1/P2/P3): P1
Faisabilite (Haute/Moyenne/Faible): Moyenne
Dependances: BE-001
Date de realisation: 2026-04-04
Temps reel passe (heures): 3.4
Preuves d'execution:
- Commits de reference: ab237ae, 2fa1964
- Endpoints testes: GET /analytics/nutrition?range=7d|30d|90d|all (200), GET /api/analytics/nutrition?range=7d|30d|90d|all (200)
- Resultat synthetique: endpoint nutrition livre avec RBAC coherent analytics, payload kpis/timeSeries/breakdown/distribution compatible frontend

### BE-005
ID: BE-005
Titre: Exposer un endpoint backend Analytics Biometrique
**Statut: DONE**
Il manque quoi et pourquoi: Il manque l'endpoint biometrique car les metriques existent en base mais ne sont pas exposees en API.
Description: Ajouter une route backend biometrique dans analytics.route basee sur user_metrics pour fournir les vues temporelles et de distribution.
Critere sujet/grille concerne: Statistiques biometriques et exploitation des donnees de performance.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (donnees biometriques: poids, sommeil, frequence cardiaque)
- DB: database/01_initdb.sql (user_metrics)
- Backend: backend/routes/analytics.route.js, backend/controllers/analyticsController/businessKpi.controller.js, backend/services/analyticsService/businessKpi.service.js
- Frontend: frontend/healthai-admin/src/services/analytics.service.ts (consommation endpoint /analytics/biometric)
Perimetre impacte: backend/routes/analytics.route.js, backend/controllers/analyticsController/businessKpi.controller.js, backend/services/analyticsService/businessKpi.service.js
Donnees DB concernees si applicable: user_metrics.recorded_date, user_metrics.weight_kg, user_metrics.heart_rate_avg, user_metrics.heart_rate_max, user_metrics.sleep_hours
Definition of Done:
1. Endpoint biometrique disponible avec filtre range.
2. Payload exploitable sans transformation metier frontend complexe.
3. Controle d'acces role applique de facon coherente.
Estimation IA agent (heures): 10
Priorite (P0/P1/P2/P3): P1
Faisabilite (Haute/Moyenne/Faible): Moyenne
Dependances: BE-001
Date de realisation: 2026-04-04
Temps reel passe (heures): 3.1
Preuves d'execution:
- Commits de reference: ab237ae, 2fa1964
- Endpoints testes: GET /analytics/biometric?range=7d|30d|90d|all (200), GET /api/analytics/biometric?range=7d|30d|90d|all (200)
- Resultat synthetique: endpoint biometrique livre avec RBAC coherent analytics, payload kpis/timeSeries/breakdown/distribution compatible frontend

### BE-006
ID: BE-006
Titre: Exposer un endpoint Audit admin consolide
**Statut: BACKLOG**
Il manque quoi et pourquoi: Il manque /admin/audit car l'ecran audit frontend existe mais l'API est absente.
Description: Construire un flux audit minimal depuis les traces SQL existantes sans creer de nouvelle table.
Critere sujet/grille concerne: Tracabilite des actions et auditabilite.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (interface admin + suivi/controle)
- DB: database/01_initdb.sql (login_history, etl_execution, data_anomaly)
- Backend: backend/routes/*.js (pas de /admin/audit)
- Frontend: frontend/healthai-admin/src/services/audit.service.ts (attend /admin/audit)
Perimetre impacte: backend/routes/analytics.route.js, backend/controllers/analyticsController/businessKpi.controller.js, backend/services/analyticsService/businessKpi.service.js
Donnees DB concernees si applicable: login_history.*, etl_execution.*, data_anomaly.*
Definition of Done:
1. GET /admin/audit retourne des lignes horodatees et filtrables.
2. Le payload correspond au type AuditLog attendu.
3. Endpoint securise (role admin).
Estimation IA agent (heures): 8
Priorite (P0/P1/P2/P3): P2
Faisabilite (Haute/Moyenne/Faible): Moyenne
Dependances: BE-001

### BE-007
ID: BE-007
Titre: Completer la documentation OpenAPI des routes reelles
**Statut: TODO**
Il manque quoi et pourquoi: Il manque une documentation OpenAPI fiable car la spec actuelle est partielle et peu exploitable pour les contrats.
Description: Mettre a jour la generation Swagger pour couvrir routes, params, schemas reponse et statuts des endpoints livres.
Critere sujet/grille concerne: API REST documentee via OpenAPI.
Preuves utilisees (Sujet, DB, Backend, Frontend):
- Sujet: etl/context.md (API documentee OpenAPI)
- DB: N/A
- Backend: backend/swagger.cjs, backend/swagger-output.json
- Frontend: services frontend consommant des contrats multiples
Perimetre impacte: backend/swagger.cjs, backend/swagger-output.json, annotations routes/controllers
Donnees DB concernees si applicable: N/A
Definition of Done:
1. Les endpoints livres apparaissent tous dans Swagger.
2. Les schemas request/response sont explicitement documentes.
3. La spec est alignable avec les services frontend sans ambiguite.
Estimation IA agent (heures): 5
Priorite (P0/P1/P2/P3): P2
Faisabilite (Haute/Moyenne/Faible): Haute
Dependances: BE-004, BE-005, BE-006

## Hors Scope a geler ( BACKLOG )

### HS-001
ID: HS-001
Element: Export PDF des ecrans admin
**Statut: TODO**
Pourquoi hors scope (preuve d'absence dans sujet + backend + DB):
- Sujet: etl/context.md exige explicitement JSON/CSV, pas PDF
- Backend/DB: aucun contrat ni besoin de format PDF cote API ou schema
- Frontend: frontend/healthai-admin/src/lib/export.utils.ts propose PDF
Decision recommandee (geler/ignorer): Geler
Action prudente (pas de hard delete): Conserver le code PDF, ne plus le faire evoluer et le sortir des parcours demo prioritaires.
Risque si conserve tel quel: Dilution du perimetre jury et confusion sur les livrables demandes.

### HS-002
ID: HS-002
Element: KPI Dashboard "avg-response" (metrique technique mock)
**Statut: TODO**
Pourquoi hors scope (preuve d'absence dans sujet + backend + DB):
- Sujet: pas d'exigence explicite de KPI latence API dans les livrables metier
- DB: aucune table de metriques de latence applicative
- Backend: aucun endpoint renvoyant un KPI avg-response
- Frontend: frontend/healthai-admin/src/features/dashboard/DashboardPage.tsx mappe un drilldown sur avg-response
Decision recommandee (geler/ignorer): Geler
Action prudente (pas de hard delete): Masquer ce KPI si absent du payload backend, conserver la structure de composant.
Risque si conserve tel quel: Affichage de donnees fictives non defendables en soutenance.

### HS-003
ID: HS-003
Element: Champ partenaire apiCallsMonth
**Statut: TODO**
Pourquoi hors scope (preuve d'absence dans sujet + backend + DB):
- Sujet: besoin B2B exprime, mais pas d'exigence explicite sur volume d'appels API par partenaire
- DB: aucune table de journal API permettant ce calcul
- Backend: aucun endpoint partners actif fournissant ce champ aujourd'hui
- Frontend: frontend/healthai-admin/src/types/index.ts et frontend/healthai-admin/src/features/partners/PartnersPage.tsx dependent de apiCallsMonth
Decision recommandee (geler/ignorer): Geler
Action prudente (pas de hard delete): Conserver le champ dans le type, mais ne plus l'utiliser comme KPI prioritaire tant que source fiable absente.
Risque si conserve tel quel: KPI invente, perte de credibilite metier.

## Matrice de couverture Sujet -> DB -> Backend -> Frontend (exigences ajoutees)

| Exigence ajoutee | Sujet | DB | Backend | Frontend | Gap constate | Tickets |
|---|---|---|---|---|---|---|
| Export JSON/CSV en UI admin | Oui | Suffisant | JSON deja expose | Partiel (JSON absent en export UI) | Front only | FE-001 |
| Analytics Nutrition | Oui | Suffisant (meal/ingredient) | Disponible (DONE BE-004) | Disponible (DONE FE-002) | Gap traite | BE-004, FE-002 |
| Analytics Biometrique | Oui | Suffisant (user_metrics) | Disponible (DONE BE-005) | Disponible (DONE FE-002) | Gap traite | BE-005, FE-002 |
| Accessibilite RGAA AA des vues data | Oui | N/A | N/A | Partiel | Front only | FE-004 |
| API securisee changement mot de passe | Oui | Suffisant | Corrige (DONE BE-002) | N/A | Gap traite | BE-002 |
| API profils utilisateurs operationnelle | Oui | Suffisant (user_ + user_health_goal) | Corrige (DONE BE-003) | N/A | Gap traite | BE-003 |
| Deploiement backend reproductible | Oui | Suffisant | Corrige (DONE BE-001) | N/A | Gap traite | BE-001 |
| Hygiene npm frontend (lint/build) | Oui | N/A | N/A | BLOCKED (revalidation 2026-04-05: Node local 22.11.0 < prerequis outillage) | Front only | FE-009 |
| Audit des actions admin | Oui | Partiel mais exploitable | Absent | Pret | Back only | BE-006 |
| OpenAPI exploitable | Oui | N/A | Partiel | N/A | Back only | BE-007 |
| Restitution d'erreurs UI (Login + ecrans proteges) | Oui | N/A | Suffisant (messages metier presents) | ON GOING (regression constatee au 2026-04-04) | Front only | FE-005, FE-006, FE-007, FE-008 |

## Non retenu (contexte insuffisant)
- Persistage backend des regles de configuration (ConfigPage): non retenu en ticket dedie car le schema SQL courant ne contient pas de tables de configuration explicites.
- KPI "conversion premium" strict sujet->SQL: non retenu en ticket dedie car la methode de calcul attendue n'est pas definie de facon non ambigue dans les preuves texte accessibles.
- Hypothese "non-retour total des erreurs Login": partiellement non retenue (401/500 ont toujours un message), mais le gap sur la qualite/actionnabilite reseau et la redirection 401 silencieuse est de nouveau ouvert (FE-005 a FE-008 revalides en regression le 2026-04-04).

## Synthese chiffree (ajouts FE/BE/HS)
- Nombre total de tickets FE: 9
- Tickets FE DONE: 1 (FE-002)
- Tickets FE ON GOING: 4 (FE-005 a FE-008)
- Tickets FE BLOCKED: 1 (FE-009)
- Tickets FE TODO: 3 (FE-001, FE-003, FE-004)
- Nombre total de tickets BE: 7
- Tickets BE DONE: 5 (BE-001 a BE-005)
- Tickets BE ON GOING: 0
- Tickets BE TODO: 2 (BE-006, BE-007)
- Nombre total Hors Scope: 3
- Tickets HS TODO: 3 (HS-001, HS-002, HS-003)
- Charge totale estimee (heures): 100
- Repartition par priorite (FE+BE): P0 = 7, P1 = 7, P2 = 2, P3 = 0