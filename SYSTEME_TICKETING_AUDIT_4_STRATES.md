# SYSTEME TICKETING TECHNIQUE - MSPR HEALTHAI (audit 4 strates)

Date de reference: 2026-04-11
Source: audit technique code-first (ETL + Database + Backend + Frontend)

---

## 1) Objectif

Mettre en place un systeme de ticketing unique, actionnable et orientee livraison jury, en reprenant la structure du backlog existant, mais avec:
- une gouvernance claire,
- une priorisation P0->P3 unifiee,
- des tickets relies aux preuves code,
- des criteres d'acceptation testables.

---

## 2) Regles du systeme

### 2.1 Nommage des tickets

Format ID:
- MSPR-SEC-XXX (securite)
- MSPR-DB-XXX (database)
- MSPR-ETL-XXX (etl)
- MSPR-BE-XXX (backend)
- MSPR-FE-XXX (frontend)
- MSPR-INT-XXX (integration front-back-etl)
- MSPR-DOC-XXX (documentation)
- MSPR-QA-XXX (tests/qualite)

### 2.2 Statuts autorises

- BACKLOG: idee qualifiee mais non planifiee
- TODO: planifiee sprint courant
- ON GOING: en cours
- BLOCKED: bloquee (dependance, env, acces)
- DONE: livree + verifiee + preuve archivee

### 2.3 Priorites

- P0: bloque la demo ou la conformite de securite/production
- P1: fonctionnalite majeure du sujet, non bloquante immediate
- P2: durcissement qualite/industrialisation
- P3: optimisation/amelioration non critique

### 2.4 SLA de traitement

- P0: prise en charge < 24h
- P1: prise en charge < 72h
- P2: prise en charge < 7 jours
- P3: prise en charge selon capacite

### 2.5 Definition of Ready (DoR)

Un ticket peut passer en TODO si:
1. Le probleme est decrit clairement.
2. Le perimetre impacte est nomme (fichiers/couches).
3. Les donnees DB concernees sont identifiees.
4. Les criteres d'acceptation sont testables.
5. La dependance eventuelle est explicite.

### 2.6 Definition of Done (DoD)

Un ticket est DONE uniquement si:
1. Build/lint/typecheck passent sur le perimetre touche.
2. Le comportement est teste (manuel ou automatisable) avec cas nominal + erreur.
3. Les preuves sont archivees (commande + resultat synthetique).
4. Le contrat front/back est coherent (route, payload, RBAC).
5. Le ticket est trace dans ce backlog (date + temps + preuve).

---

## 3) Template ticket standard

ID:
Titre:
Statut: BACKLOG | TODO | ON GOING | BLOCKED | DONE
Priorite: P0 | P1 | P2 | P3
Faisabilite: Haute | Moyenne | Faible

Description:
Il manque quoi et pourquoi:
Impact evaluation (critere jury):
Perimetre impacte (front/back/etl/db):
Donnees DB concernees:
Dependances:

Definition of Done:
1.
2.
3.

Preuves d'execution (a renseigner en cloture):
- Commandes executees:
- Resultat synthetique:
- Risques residuels:

---

## 4) Backlog initialise suite audit profond

## 4.1 P0 - Critique (a traiter en premier)

### MSPR-SEC-001
ID: MSPR-SEC-001
Titre: Revoquer la cle Kaggle exposee dans le repo
Statut: DONE
Priorite: P0
Faisabilite: Haute
Description: Une cle Kaggle est commitee dans etl/$HOME/.kaggle/kaggle.json.
Il manque quoi et pourquoi: La rotation/revocation des secrets n'a pas ete faite; risque de compromission immediate.
Impact evaluation (critere jury): Securite et professionnalisme de la chaine de traitement.
Perimetre impacte: etl/$HOME/.kaggle/kaggle.json, politique secrets.
Donnees DB concernees: N/A
Dependances: Aucune
Definition of Done:
1. Cle Kaggle revoquee et regeneree.
2. Secret supprime du repo + prevention de recurrence (.gitignore + variable env).
3. Verification qu'aucun secret actif n'est versionne.

### MSPR-INT-001
ID: MSPR-INT-001
Titre: Basculer le frontend en API reelle par defaut (mock opt-in)
Statut: DONE
Priorite: P0
Faisabilite: Haute
Description: USE_MOCK est vrai par defaut si VITE_USE_MOCKS n'est pas force a false.
Il manque quoi et pourquoi: En Docker standard, les mocks peuvent masquer des regressions d'integration.
Impact evaluation (critere jury): Demo bout-en-bout DB -> API -> UI.
Perimetre impacte: frontend/healthai-admin/src/lib/env.ts, frontend/Dockerfile, .env.example.
Donnees DB concernees: N/A
Dependances: MSPR-BE-001, MSPR-BE-002, MSPR-BE-003
Definition of Done:
1. Build front n'active plus les mocks par defaut.
2. Un mode mock explicite reste possible en local dev.
3. Les ecrans critiques affichent un etat indisponible clair si endpoint absent.
Execution 2026-04-11:
- Temps reel: 3.3h (mutualise avec MSPR-BE-001 sur le flux Dashboard).
- Preuves: env.ts passe en mock opt-in (VITE_USE_MOCKS=true uniquement), Docker frontend parametre VITE_USE_MOCKS=false par defaut, DashboardPage affiche un message explicite si /dashboard est indisponible.
- Commandes: npm run typecheck, npm run lint, npm run build (frontend) -> succes.

Execution complementaire 2026-04-11 (branche feat/dashboard):
- Temps reel: 1.4h.
- Decision metrique non calculable: la serie "Sommeil" etait forcee a 0 dans le dashboard (aucune source SQL exploitable dans 01_initdb.sql/02_seed.sql) ; suppression de la valeur fictive et fallback UI explicite "Series non disponibles".
- Fichiers modifies: backend/services/analyticsService/businessKpi.service.js ; frontend/healthai-admin/src/components/dashboard/DataIngestionAreaChart.tsx ; frontend/healthai-admin/src/features/dashboard/DashboardPage.tsx ; SYSTEME_TICKETING_AUDIT_4_STRATES.md.
- Build front (sans mock par defaut): npm run typecheck ; npm run lint ; npm run build -> succes.
- Runtime API reelle: docker compose up -d --build db backend -> db healthy + backend started.
- Extrait preuve auth/dashboard (ADMIN): {"adminLoginSuccess":true,"adminRole":"ADMIN","dashboardSuccess":true,"kpiCount":6,"userActivityPoints":30,"dataIngestionKeys":"Biométrique,date,Fitness,Nutrition"}.
- Extrait preuve RBAC (FREEMIUM): GET /dashboard -> 403.
- Extrait preuve ranges: /dashboard?range=all|7d|30d|90d -> success=true, kpis=6.
- Capture UI (instruction): lancer frontend, ouvrir Dashboard connecte ADMIN, capturer la vue et enregistrer dans audit/logs/ui/dashboard-real-api-2026-04-11.png.

### MSPR-BE-001
ID: MSPR-BE-001
Titre: Implementer endpoint GET /dashboard aligne DashboardPage
Statut: DONE
Priorite: P0
Faisabilite: Haute
Description: Le front appelle /dashboard hors mock, endpoint absent en backend.
Il manque quoi et pourquoi: Le dashboard principal reste factice sans agragation backend.
Impact evaluation (critere jury): Interface web + dashboard interactif.
Perimetre impacte: backend/app.js, backend/routes/analytics.route.js, backend/controllers/analyticsController/businessKpi.controller.js, backend/services/analyticsService/businessKpi.service.js, frontend/healthai-admin/src/services/dashboard.service.ts.
Donnees DB concernees: login_history, etl_execution, data_quality_check_, data_anomaly (+ tables disponibles reelles).
Dependances: MSPR-DB-001
Definition of Done:
1. GET /dashboard retourne un contrat compatible DashboardData.
2. DashboardPage fonctionne sans mock.
3. Payload valide sur seed SQL.
Execution 2026-04-11:
- Temps reel: 3.3h (mutualise avec MSPR-INT-001 sur le flux Dashboard).
- Preuves: endpoint GET /dashboard implemente avec RBAC (ANALYTICS), payload valide (kpis + series + breakdowns), aucune metrique inventee.
- Commandes: docker compose up -d --build db backend ; curl /dashboard role PREMIUM -> 200 ; curl /dashboard role FREEMIUM -> 403.
- Finalisation production: ajout du filtre datetime `all|7d|30d|90d` aligne sur les autres controleurs/services analytics.
- Validation multi-ranges: /dashboard?range=all|7d|30d|90d -> 200, payload coherent et series non vides.
- Jeu de donnees seed renforce (database/02_seed.sql) pour couvrir les fenetres courtes sur login/workout/anomaly.

### MSPR-BE-002
ID: MSPR-BE-002
Titre: Implementer endpoints Anomalies reels
Statut: DONE
Priorite: P0
Faisabilite: Haute
Description: Le front cible /anomalies et /anomalies/:id/correct, routes absentes.
Il manque quoi et pourquoi: Workflow correction encore simule en front.
Impact evaluation (critere jury): Outils de nettoyage interactifs.
Perimetre impacte: backend/app.js, backend/routes/*, backend/controllers/*, backend/services/*, frontend/healthai-admin/src/services/anomalies.service.ts.
Donnees DB concernees: data_anomaly, data_quality_check_, etl_execution.
Dependances: Aucune
Definition of Done:
1. GET /anomalies retourne une liste typed compatible front.
2. PATCH /anomalies/:id/correct persiste is_resolved + resolution_action.
3. Rechargement UI montre la correction persistante.
Execution demarree 2026-04-11:
- Date de debut: 2026-04-11.
Execution 2026-04-11:
- Date de fin: 2026-04-11.
- Temps reel: 4.6h.
- Preuves implementation: endpoints reels livres (`GET /anomalies`, `PATCH /anomalies/:id/correct`) avec separation controller/service/repository + SQL centralise dans `backend/repositories/dataAnomaly.repository.js`.
- RBAC aligne front/back: acces anomalies reserve a `ADMIN` et `PREMIUM_PLUS` (frontend `DATA_ROLES`, backend `ROLE_GROUPS.DATA_QUALITY`).
- Filtre optionnel `organization_id`: applique uniquement aux anomalies `source_table=user_metrics` via jointure `user_metrics -> user_organization` (pas de mapping organisation fiable pour les autres sources dans le schema actuel).
- Journalisation correction: action loggee via `login_history` dans la meme transaction SQL que l'update anomalie (pas de table audit dediee disponible).
- Recommandation DB: ajouter une table d'audit dediee corrections anomalies (`anomaly_id`, `resolved_by`, `resolved_at`, `resolution_action`) pour tracabilite complete.
- Fichiers modifies: `backend/app.js`; `backend/routes/analytics.route.js`; `backend/controllers/analyticsController/dataAnomaly.controller.js`; `backend/services/analyticsService/dataAnomaly.service.js`; `backend/repositories/dataAnomaly.repository.js`; `frontend/healthai-admin/src/services/anomalies.service.ts`; `frontend/healthai-admin/src/features/anomalies/AnomaliesPage.tsx`; `frontend/healthai-admin/src/components/anomalies/CorrectionDialog.tsx`; `audit/logs/mspr-be-002-anomalies-2026-04-11.md`; `SYSTEME_TICKETING_AUDIT_4_STRATES.md`.
- Commandes: `cd backend && npm ci && npm run swagger`; `cd frontend/healthai-admin && npm ci && npm run typecheck && npm run lint && npm run build`; `docker compose up -d --build db backend`; tests API via `Invoke-RestMethod`.
- Extrait preuve auth + correction (ADMIN): {"adminLoginSuccess":true,"adminRole":"ADMIN","openCount":1,"correctedAnomalyId":"ANO_002","patchResolved":true,"patchAction":"Confirmed data issue","resolvedCount":3}.
- Extrait preuve persistance post-correction: {"openIds":[],"openTotal":0,"resolvedIds":["ANO_003","ANO_002","ANO_001"],"resolvedTotal":3}.
- Extrait preuve RBAC: FREEMIUM -> `GET /anomalies` => 403 ; PREMIUM_PLUS -> `GET /anomalies` => 200.
- Log d'execution detaille: `audit/logs/mspr-be-002-anomalies-2026-04-11.md`.

### MSPR-BE-003
ID: MSPR-BE-003
Titre: Implementer endpoint Audit admin consolide
Statut: BACKLOG
Priorite: P0
Faisabilite: Moyenne
Description: Le front appelle /admin/audit hors mock, endpoint absent.
Il manque quoi et pourquoi: Absence de journal admin exploitable cote UI.
Impact evaluation (critere jury): Tracabilite et auditabilite.
Perimetre impacte: backend/app.js, backend/routes/*, backend/controllers/*, backend/services/*, frontend/healthai-admin/src/services/audit.service.ts.
Donnees DB concernees: login_history, etl_execution, data_anomaly.
Dependances: MSPR-BE-002
Definition of Done:
1. GET /admin/audit retourne des evenements horodates et filtrables.
2. Payload aligne type AuditLog.
3. RBAC admin applique.

### MSPR-ETL-001
ID: MSPR-ETL-001
Titre: Brancher ETL_API_URL dans backend compose
Statut: TODO
Priorite: P0
Faisabilite: Haute
Description: etl.service.js depend de ETL_API_URL non fourni dans docker-compose backend.
Il manque quoi et pourquoi: Lancement/validation ETL backend peut echouer en runtime.
Impact evaluation (critere jury): Supervision pipeline exploitable en demo.
Perimetre impacte: docker-compose.yml, backend/services/etlService/etl.service.js, .env.example.
Donnees DB concernees: etl_execution.
Dependances: Aucune
Definition of Done:
1. ETL_API_URL est injecte en runtime backend.
2. POST /etl/:pipeline fonctionne en docker.
3. POST /etl/validate/:id fonctionne sans variable manquante.

### MSPR-ETL-002
ID: MSPR-ETL-002
Titre: Supprimer TRUNCATE CASCADE destructif du load ETL
Statut: TODO
Priorite: P0
Faisabilite: Moyenne
Description: load.py truncate exercise/ingredient avec CASCADE, impactant les tables de liaison.
Il manque quoi et pourquoi: Risque de purge de donnees metier (meal_ingredient, workout_session_exercise).
Impact evaluation (critere jury): Fiabilite de la chaine data et non regression.
Perimetre impacte: etl/utils/load.py, strategie de chargement.
Donnees DB concernees: ingredient, exercise, meal_ingredient, recipe_ingredients, workout_session_exercise.
Dependances: MSPR-DB-002
Definition of Done:
1. Le load ETL devient non destructif (staging + merge/upsert).
2. Les tables de liaison ne sont plus purgees.
3. Test de non-regression sur exports/analytics apres load.

### MSPR-INT-002
ID: MSPR-INT-002
Titre: Reparer export CSV pipeline bout-en-bout
Statut: TODO
Priorite: P0
Faisabilite: Moyenne
Description: Le front genere /api/files/... mais les chemins/volumes ETL-back ne sont pas alignes.
Il manque quoi et pourquoi: L'export CSV peut pointer vers des fichiers inexistants en prod compose.
Impact evaluation (critere jury): Livraison de donnees exploitable (CSV).
Perimetre impacte: frontend/healthai-admin/src/features/data/PipelinePage.tsx, frontend/healthai-admin/src/services/pipeline.service.ts, backend/routes/files.routes.js, backend/services/filesService/files.service.js, docker-compose.yml.
Donnees DB concernees: N/A
Dependances: MSPR-ETL-002
Definition of Done:
1. Un run ETL genere un CSV telechargeable depuis UI.
2. Le nommage fichier/type est coherent front/back/etl.
3. Test manuel valide sur nutrition + exercises.

### MSPR-BE-004
ID: MSPR-BE-004
Titre: Proteger GET /etl/etlExecutions (auth + role)
Statut: TODO
Priorite: P0
Faisabilite: Haute
Description: La liste ETL est publique alors que les actions ETL sont admin.
Il manque quoi et pourquoi: Incoherence de securite sur metadonnees pipeline.
Impact evaluation (critere jury): Securite API et controle d'acces coherent.
Perimetre impacte: backend/routes/etl.routes.js, frontend guards si necessaire.
Donnees DB concernees: etl_execution.
Dependances: Aucune
Definition of Done:
1. GET /etl/etlExecutions requiert auth + role coherent.
2. Le front gere proprement 401/403.
3. Aucun endpoint ETL sensible non protege.

### MSPR-INT-005
ID: MSPR-INT-005
Titre: Remediation profonde vs Isolation des anomalies actives
Statut: TODO
Priorite: P0
Faisabilite: Moyenne
Description: Actuellement, une ligne en etat d'anomalie (ouverte ou faussement "resolue" par un simple clic) reste presente en l'etat dans sa source (ex: user_metrics avec une valeur negative) et pollue silencieusement tous les calculs analytiques et KPIs du dashboard.
Il manque quoi et pourquoi: La correction d'une anomalie en l'etat est cosmetique. Il faut une veritable remediation pereine : le dashboard NE DOIT PAS utiliser des donnees avec une anomalie ouverte, et la "resolution" doit permettre de corriger physiquement la valeur en base (ou confirmer qu'elle est ignoree).
Impact evaluation (critere jury): Fiabilite absolue des calculs BI (Data Engineering & Trust).
Perimetre impacte: 
- Base de donnees: creation de SQL Views (ex: `vw_qualified_user_metrics`) excluant les lignes liees a une `data_anomaly` ouverte.
- Backend KPI: migration des requetes `.service` vers ces Vues qualifiees au lieu des tables brutes.
- Backend Anomalies: le PATCH de resolution doit accepter la nouvelle valeur corrigee et l'UPDATE dynamiquement dans la `source_table`.
Donnees DB concernees: Toutes requetes analytiques (utiliser une jointure `LEFT JOIN data_anomaly ... WHERE ... is null`).
Dependances: MSPR-BE-001, MSPR-BE-002
Definition of Done:
1. Les KPIs (dashboard) calculent uniquement sur la donnee "propre" (vues filtrees des anomalies ouvertes).
2. Le backend expose un endpoint permettant de soumettre une valeur de remplacement `{"correctedValues": { "heart_rate": 80 }}` lors de la resolution de l'anomalie.
3. Le patch met a jour physiquement (UPDATE) la table source (ex: `user_metrics`) en plus de cloturer l'anomalie.

---

## 4.2 P1 - Majeur

### MSPR-DB-001
ID: MSPR-DB-001
Titre: Aligner besoins dashboard avec schema SQL reel
Statut: TODO
Priorite: P1
Faisabilite: Moyenne
Description: Le backlog mentionne data_source/source_id/triggered_by absents du schema actuel.
Il manque quoi et pourquoi: Contrat fonctionnel et schema divergeants, risque de faux KPI.
Impact evaluation (critere jury): Cohesion modele data <-> API <-> UI.
Perimetre impacte: database/01_initdb.sql, database/02_seed.sql, services analytics.
Donnees DB concernees: etl_execution, data_quality_check_, data_anomaly (+ eventuelles nouvelles structures).
Dependances: Aucune
Definition of Done:
1. Soit schema complete, soit backlog/API adaptes au schema existant.
2. Tous les champs utilises par KPI existent reellement.
3. Mapping documente sans ambiguite.

### MSPR-DB-002
ID: MSPR-DB-002
Titre: Definir strategie d'identite stable ETL vs seed
Statut: TODO
Priorite: P1
Faisabilite: Moyenne
Description: ETL genere UUID deterministes alors que seed utilise IDs metier (ING_001, EXC_001).
Il manque quoi et pourquoi: Risque de rupture des references FK lors des loads.
Impact evaluation (critere jury): Integrite referentielle et fiabilite de la demo.
Perimetre impacte: etl/utils/uuid_utils.py, transform nutrition/exercises, schema/seed si besoin.
Donnees DB concernees: ingredient, exercise, tables de liaison.
Dependances: Aucune
Definition of Done:
1. Identifiants cibles harmonises (strategie unique).
2. FK restent valides apres un load ETL.
3. Regles de generation id documentees.

### MSPR-BE-005
ID: MSPR-BE-005
Titre: Synchroniser Swagger avec routes reelles
Statut: TODO
Priorite: P1
Faisabilite: Haute
Description: swagger-output contient endpoints fantomes et manque endpoints reels.
Il manque quoi et pourquoi: Contrat API non fiable pour integration/tests.
Impact evaluation (critere jury): API REST documentee OpenAPI exploitable.
Perimetre impacte: backend/swagger.cjs, backend/swagger-output.json, annotations routes/controllers.
Donnees DB concernees: N/A
Dependances: MSPR-BE-001, MSPR-BE-002, MSPR-BE-003
Definition of Done:
1. Swagger ne contient que des endpoints implementes.
2. Endpoints reels critiques y figurent (data-quality, etl, files, dashboard, anomalies, audit si livre).
3. Verification automatisee de non-drift (script CI).

### MSPR-FE-001
ID: MSPR-FE-001
Titre: Finaliser gestion d'erreurs unifiee ecrans proteges
Statut: TODO
Priorite: P1
Faisabilite: Haute
Description: Progression deja faite, mais maintenir coherence 401/403/500/reseau dans tous les ecrans reels.
Il manque quoi et pourquoi: Risque d'etat vide trompeur ou message technique brut.
Impact evaluation (critere jury): Qualite UX de l'interface admin.
Perimetre impacte: frontend/healthai-admin/src/features/*, src/lib/error.utils.ts, src/api/client.ts.
Donnees DB concernees: N/A
Dependances: MSPR-INT-001
Definition of Done:
1. Mapping erreur unifie applique partout.
2. Aucun ecran ne confond erreur et no-data.
3. Message session expiree persiste apres redirection login.

### MSPR-INT-003
ID: MSPR-INT-003
Titre: Aligner RBAC ETL front/back
Statut: TODO
Priorite: P1
Faisabilite: Haute
Description: Front Pipeline est ouvre DATA_ROLES (ADMIN, PREMIUM_PLUS), mais actions backend ETL sont ADMIN only.
Il manque quoi et pourquoi: Incoherence fonctionnelle et risque de 403 repetes.
Impact evaluation (critere jury): Securite et coherence de navigation.
Perimetre impacte: frontend routes/nav + backend routes ETL.
Donnees DB concernees: role, user_.
Dependances: MSPR-BE-004
Definition of Done:
1. Les roles front autorises correspondent aux roles backend effectifs.
2. Aucun user autorise UI ne subit un 403 inattendu sur parcours nominal.
3. Comportement 403 reste explicite pour roles non autorises.

### MSPR-INT-004
ID: MSPR-INT-004
Titre: Enrichir le cycle de vie des anomalies (Statuts complets et Assignation)
Statut: TODO
Priorite: P1
Faisabilite: Moyenne
Description: Le workflow d'anomalies actuel est binaire (Ouvert / Résolu). Il faut un cycle plus riche (En cours, Investigation, Faux positif) et pouvoir assigner un membre de l'équipe Data.
Il manque quoi et pourquoi: Un cas fonctionnel concret pour distribuer le travail de remédiation, indispensable pour une vraie équipe Data Quality.
Impact evaluation (critere jury): Richesse fonctionnelle et adherence a un workflow ITSM realiste.
Perimetre impacte: database (alter table), backend/services/analyticsService (logique statuts), frontend/healthai-admin (UI de modification).
Donnees DB concernees: data_anomaly (ajout champs status, assignee_id).
Dependances: MSPR-BE-002
Definition of Done:
1. Enum de statuts (OPEN, INVESTIGATING, BLOCKED, FALSE_POSITIVE, RESOLVED) implemente.
2. Possibilite d'assigner un utilisateur (assignee_id) a l'anomalie.
3. Frontend UI mis a jour pour afficher et gerer ces nouveaux etats.

---

## 4.3 P2 - Industrialisation

### MSPR-ETL-003
ID: MSPR-ETL-003
Titre: Raffiner data quality ETL (checks atomiques)
Statut: BACKLOG
Priorite: P2
Faisabilite: Moyenne
Description: check_dataframe journalise COMPOSITE_CHECK tronque et anomalies limitees a 1000.
Il manque quoi et pourquoi: Traçabilite insuffisante des regles et pertes d'anomalies massives.
Impact evaluation (critere jury): Controle qualite data defendable.
Perimetre impacte: etl/utils/data_quality.py.
Donnees DB concernees: data_quality_check_, data_anomaly.
Dependances: Aucune
Definition of Done:
1. Un check par regle/colonne est persiste.
2. Plus de troncature ambigue de check_rule.
3. Strategie de pagination/stream anomalies au-dela de 1000.

### MSPR-QA-001
ID: MSPR-QA-001
Titre: Ajouter tests de contrats API critiques
Statut: BACKLOG
Priorite: P2
Faisabilite: Moyenne
Description: Couvrir automatiquement les contrats utilises par le front pour eviter regressions silencieuses.
Il manque quoi et pourquoi: Les drifts endpoint/payload ne sont pas prevenus.
Impact evaluation (critere jury): Fiabilite de livraison.
Perimetre impacte: backend (tests API), frontend (smoke integration).
Donnees DB concernees: seed demo.
Dependances: MSPR-BE-005
Definition of Done:
1. Tests sur /auth/login, /metrics/fitness, /analytics/*, /data-quality/score, /partners*.
2. Tests echec 401/403/500 minimaux.
3. Pipeline CI execute ces tests.

### MSPR-DOC-001
ID: MSPR-DOC-001
Titre: Aligner documentation deploiement avec runtime reel
Statut: BACKLOG
Priorite: P2
Faisabilite: Haute
Description: Certaines docs (ex database/README.md) decrivent des tables absentes du schema execute.
Il manque quoi et pourquoi: Risque de confusion jury et equipe.
Impact evaluation (critere jury): Rigueur documentaire et reproductibilite.
Perimetre impacte: README racine + README strates + guides techniques.
Donnees DB concernees: schema officiel uniquement.
Dependances: MSPR-DB-001
Definition of Done:
1. Documentation strictement alignee avec le code execute.
2. Runbook docker valide en temps contraint.
3. Matrice exigence -> preuve mise a jour.

### MSPR-ETL-004
ID: MSPR-ETL-004
Titre: Mise en quarantaine (DLQ) et rejeu des donnees en erreur
Statut: BACKLOG
Priorite: P2
Faisabilite: Faible
Description: Actuellement, on flag une anomalie, mais la donnee brute concernee n'est pas stockee de maniere isolee pour etre corrigee puis rejouee (pattern Dead Letter Queue).
Il manque quoi et pourquoi: La veritable remediation de donnees, standard de l'industrie pour ne pas perdre la donnee lors des echecs de validation ETL.
Impact evaluation (critere jury): Industrialisation avancee et integrite totale des flux.
Perimetre impacte: etl (route rejets vers DLQ), backend (endpoint de rejeu).
Donnees DB concernees: creation schema/table dedie dlq_records.
Dependances: Aucune
Definition of Done:
1. L'ETL pousse les lignes non conformes dans une table DLQ specifique avec leur motif de rejet.
2. Un endpoint backend permet de re-soumettre/rejouer un batch de la DLQ dans l'ETL.
3. Documentation de l'architecture de remediation ajoutee.

---

## 4.4 P3 - Optimisation Architecturale

### MSPR-ARCH-001
ID: MSPR-ARCH-001
Titre: Decouplage evenementiel de l'ingestion des anomalies
Statut: BACKLOG
Priorite: P3
Faisabilite: Faible
Description: L'ETL insere en SQL principal (OLTP) de maniere synchrone lors des controles, risquant de saturer la base de donnees transactionnelle lors de gros batchs en erreur.
Il manque quoi et pourquoi: Une architecture asynchrone (Broker de messages / Pub-Sub) pour proteger la performance du backend metier face aux pics d'anomalies.
Impact evaluation (critere jury): Capacite de montee en charge massive (Scalability) et resilience.
Perimetre impacte: etl (publisher), backend (worker/consumer), architecture docker (broker).
Donnees DB concernees: data_anomaly.
Dependances: Aucune
Definition of Done:
1. Ajout d'un broker leger (ex: redis streams ou RabbitMQ) dans docker-compose.
2. L'ETL delegue la tracabilite en publiant des evenements.
3. Un worker (microservice ou backend task) batch et integre ces messages en asynchrone.

---

## 5) Gouvernance execution (cadence)

- Daily 15 min: triage P0/P1 + blocages.
- Point integration 1 jour sur 2: verification front-back-etl en Docker.
- Gate hebdomadaire: demo bout-en-bout obligatoire sans mock cache.
- Regle merge: pas de DONE sans preuve d'execution.

---

## 6) Ordre d'execution recommande (roadmap courte)

Sprint 1 (stabilisation critique):
1. MSPR-SEC-001
2. MSPR-ETL-001
3. MSPR-BE-004
4. MSPR-INT-001
5. MSPR-BE-001
6. MSPR-BE-002
7. MSPR-INT-002

Sprint 2 (couverture metier):
1. MSPR-BE-003
2. MSPR-DB-001
3. MSPR-DB-002
4. MSPR-BE-005
5. MSPR-FE-001
6. MSPR-INT-003

Sprint 3 (industrialisation):
1. MSPR-ETL-003
2. MSPR-QA-001
3. MSPR-DOC-001

---

## 7) Note importante sur la conformite sujet/grille

Les pieces officielles sujet/grille n'etant pas exploitables en texte dans le workspace au moment de l'audit, ce systeme est base sur:
- le code execute,
- les contrats reels front-back-etl-db,
- les ecarts verifies en runtime/documentation technique.

Des reception des pieces officielles, ajouter une colonne "Critere grille exact" par ticket pour verrouiller la tracabilite jury.
