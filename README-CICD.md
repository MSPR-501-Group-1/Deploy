# CI/CD MSPR — Guide d'installation et de dépannage

Stack : **Jenkins** (port 8090) + **SonarQube** (port 9002) + **PostgreSQL** (interne)

---

## 1. Prérequis

- Docker Desktop installé et démarré
- Docker Compose v2 disponible (`docker compose version`)
- Les 6 repos GitHub clonés localement sous `C:\Travail\MSPR\`
- Accès à l'organisation GitHub `MSPR-501-Group-1`

---

## 2. Démarrage de l'infra CI/CD

Depuis le dossier `Main/` :

```bash
docker compose -f docker-compose.cicd-MSPR.yml up -d
```

Attendre ~2 minutes que SonarQube démarre complètement.

- Jenkins  → http://localhost:8090
- SonarQube → http://localhost:9002

---

## 3. Configuration initiale Jenkins

### 3.1 Plugins à installer

Aller dans **Manage Jenkins → Plugins → Available plugins** et installer :

| Plugin | Utilité |
|---|---|
| Pipeline | Support des Jenkinsfiles |
| Git | Checkout depuis GitHub |
| SonarQube Scanner | Analyse de code |
| JUnit | Publication des rapports de tests |
| Docker Pipeline | Commandes Docker dans les pipelines |

Après installation → **Restart Jenkins**.

### 3.2 Outils à configurer

**Manage Jenkins → Tools → SonarQube Scanner** :
- Nom : `SonarQube Scanner` *(exact, sensible à la casse)*
- Cocher "Install automatically" → version la plus récente

### 3.3 Connecter SonarQube à Jenkins

**SonarQube (http://localhost:9002)** :
1. Se connecter (admin / admin → changer le mot de passe)
2. **Administration → Security → Global Analysis Token** → générer un token
3. Copier le token

**Jenkins (http://localhost:8090)** :
1. **Manage Jenkins → Credentials → System → Global → Add Credentials**
   - Kind : `Secret text`
   - Secret : *coller le token SonarQube*
   - ID : `sonarqube-token-mspr`
2. **Manage Jenkins → System → SonarQube servers** :
   - Cocher "Environment variables"
   - Nom : `SonarQube` *(exact)*
   - URL : `http://mspr-sonarqube:9000`
   - Token : sélectionner `sonarqube-token-mspr`

### 3.4 Webhook SonarQube → Jenkins

**SonarQube → Administration → Configuration → Webhooks → Create** :
- Nom : `Jenkins`
- URL : `http://mspr-jenkins:8080/sonarqube-webhook/`

> ⚠️ L'URL utilise le port **interne** Docker (8080), pas le port exposé (8090).

---

## 4. Dépendances à installer dans le conteneur Jenkins

Ces commandes sont à exécuter **une seule fois** après le démarrage du conteneur.

### Python 3 + venv
```bash
docker exec -u root mspr-jenkins bash -c "apt-get update && apt-get install -y python3 python3-pip python3-venv"
```

### Docker CLI
```bash
docker exec -u root mspr-jenkins bash -c "apt-get update && apt-get install -y docker.io"
```

### Docker Compose v2 (plugin)
```bash
docker exec -u root mspr-jenkins bash -c "mkdir -p /usr/local/lib/docker/cli-plugins && curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose"
```

### Node.js + npm
```bash
docker exec -u root mspr-jenkins bash -c "apt-get update && apt-get install -y nodejs npm"
```

### Vérifications
```bash
docker exec mspr-jenkins python3 --version
docker exec mspr-jenkins docker --version
docker exec mspr-jenkins docker compose version
docker exec mspr-jenkins node --version
docker exec mspr-jenkins npm --version
```

---

## 5. Créer les pipelines Jenkins

Pour chaque repo, aller dans **Jenkins → Nouveau Item** :

| Nom pipeline | Repository URL | Branch |
|---|---|---|
| `mspr-ia-workout-recommendation` | `https://github.com/MSPR-501-Group-1/ia-workout-recommendation` | `*/feature/cicd` puis `*/main` |
| `mspr-backend-main` | `https://github.com/MSPR-501-Group-1/backend-main` | idem |
| `mspr-frontend-admin-dashboard` | `https://github.com/MSPR-501-Group-1/frontend-admin-dashboard` | idem |
| `mspr-data-etl` | `https://github.com/MSPR-501-Group-1/data-etl` | idem |
| `mspr-database-main` | `https://github.com/MSPR-501-Group-1/database-main` | idem |
| `mspr-main` | `https://github.com/MSPR-501-Group-1/Main` | idem |

Configuration commune :
- Type : **Pipeline**
- Definition : `Pipeline script from SCM`
- SCM : `Git`
- Script Path : `Jenkinsfile`

---

## 6. Résolution des problèmes courants

### `cleanWs` not found
Le plugin **Workspace Cleanup** n'est pas installé. Tous les Jenkinsfiles utilisent `deleteDir()` à la place (built-in, pas de plugin requis).

---

### `sonar-scanner: not found`
Le scanner doit être invoqué via l'outil Jenkins, pas depuis le PATH système :
```groovy
// ❌ Ne pas faire
sh 'sonar-scanner ...'

// ✅ Correct
script {
    def scannerHome = tool 'SonarQube Scanner'
    sh "${scannerHome}/bin/sonar-scanner ..."
}
```

---

### Quality Gate bloqué indéfiniment
Le webhook SonarQube pointe vers le mauvais port. Vérifier que l'URL est :
```
http://mspr-jenkins:8080/sonarqube-webhook/
```
Et **non** `http://mspr-jenkins:8090/...` (8090 est le port hôte, pas le port interne Docker).

---

### `python3: not found`
```bash
docker exec -u root mspr-jenkins bash -c "apt-get update && apt-get install -y python3 python3-pip python3-venv"
```

---

### `docker: not found` dans les pipelines
```bash
docker exec -u root mspr-jenkins bash -c "apt-get update && apt-get install -y docker.io"
```

---

### `docker compose` non reconnu (`unknown shorthand flag: 'f'`)
Le plugin Compose v2 n'est pas installé. Voir section 4 — **Docker Compose v2**.

---

### `npm: not found`
```bash
docker exec -u root mspr-jenkins bash -c "apt-get update && apt-get install -y nodejs npm"
```

---

### Erreur pandas / pyarrow / psycopg2 (Python 3.13, pas de wheel)
Le conteneur Jenkins (Debian Trixie) utilise Python 3.13. Certains packages n'ont pas de wheel pour cette version. Le Jenkinsfile de `data-etl` patche les versions à la volée via `sed` :
```bash
sed -e 's/pandas==2.2.0/pandas>=2.2.3/' \
    -e 's/psycopg2-binary==2.9.9/psycopg2-binary>=2.9.10/' \
    -e 's/pyarrow==15.0.0/pyarrow>=17.0.0/' \
    requirements.txt > /tmp/requirements-ci.txt
pip install --only-binary=pandas,numpy,psycopg2_binary,pyarrow --prefer-binary -r /tmp/requirements-ci.txt
```

---

### `ModuleNotFoundError: No module named 'services'`
Ajouter `PYTHONPATH=.` avant la commande pytest :
```bash
PYTHONPATH=. pytest tests/ ...
```

---

### `.env not found` lors de la validation docker-compose
Le fichier `.env` est gitignored (il contient des secrets). En CI, créer un fichier vide avant la validation :
```bash
touch .env
docker compose -f docker-compose.yml config --quiet
```

---

### Dockerfile trop long (10-15 min pour `ia-workout-recommendation`)
Normal au premier build — Orange3 + xgboost + scipy représentent ~800 MB de dépendances. Les builds suivants seront plus rapides grâce au cache Docker (si les layers `COPY requirements.txt` et `RUN pip install` n'ont pas changé).

---

## 7. Commandes utiles

```bash
# Voir les logs Jenkins
docker logs mspr-jenkins -f

# Voir les logs SonarQube
docker logs mspr-sonarqube -f

# Redémarrer Jenkins uniquement
docker restart mspr-jenkins

# Arrêter toute l'infra CI/CD (données conservées)
docker compose -f docker-compose.cicd-MSPR.yml down

# Reset complet (supprime tous les volumes)
docker compose -f docker-compose.cicd-MSPR.yml down -v

# Vérifier l'état des conteneurs
docker compose -f docker-compose.cicd-MSPR.yml ps

# Accéder au shell Jenkins
docker exec -it mspr-jenkins bash

# Lister les images Docker buildées par les pipelines
docker images | grep mspr/
```

---

## 8. Déploiement automatique

Le stage **Deploy** du repo `Main` s'exécute **uniquement sur la branche `main`**. Il :
1. Arrête les conteneurs applicatifs existants
2. Supprime les anciennes images `mspr/*`
3. Relance l'application via `docker compose up -d --build`

Pour déclencher le déploiement : merger une PR `feature/cicd` → `main` sur le repo `Main`.

---

## 9. Architecture des branches

```
feature/cicd  →  tests CI (SonarQube + Quality Gate + Docker Build)
     ↓ PR merge
main          →  tests CI + Deploy automatique de l'application
```
