# MSPR - Main

Depot d'orchestration du projet MSPR. Ce repository reference les sous-projets via submodules Git:

- backend
- frontend
- etl
- database

## Prerequis

- Git
- Docker + Docker Compose

## Demarrage rapide (stack complete)

1. Cloner le projet avec les submodules.
2. Se placer a la racine du projet.
3. Creer le fichier .env a partir de .env.example.
4. Lancer les services.

```bash
git clone --recurse-submodules https://github.com/MSPR-501-Group-1/main.git
cd main

# Bash
cp .env.example .env

# PowerShell
Copy-Item .env.example .env

docker compose up --build
```

## Services exposes

- Frontend: http://localhost:5173
- Backend API: http://localhost:3000
- Backend healthcheck: http://localhost:3000/health
- ETL API: http://localhost:8000
- ETL Swagger: http://localhost:8000/docs
- PostgreSQL: localhost:5432

## Variables d'environnement principales

Le fichier .env pilote la stack. Variables principales:

- POSTGRES_DB
- POSTGRES_USER
- POSTGRES_PASSWORD
- JWT_SECRET
- ETL_API_URL
- VITE_API_BASE_URL
- VITE_USE_MOCKS

## Workflow feature (submodules)

Exemple pour une feature qui touche backend + frontend.

1. Creer une branche dans chaque submodule.

```bash
cd backend
git checkout -b feature/login

cd ../frontend
git checkout -b feature/login
```

2. Developper, commit et push dans chaque submodule.

```bash
git push origin feature/login
```

3. Revenir a la racine main et mettre a jour les pointeurs de submodules.

```bash
cd ..
git checkout -b feature/login
git add backend frontend
git commit -m "update submodules for feature/login"
git push origin feature/login
```

## Documentation par composant

- backend/README.md
- frontend/README.md
- etl/README.md
- database/README.md