# Scripts

Scripts de backup des bases de données, exécutés automatiquement chaque nuit à 2h via le conteneur `backup-cron`.

Les fichiers sont sauvegardés dans `.backup/` à la racine du projet (7 jours de rétention).

## Lancer un backup manuellement

```bash
docker exec backup-cron sh /scripts/backup-postgres.sh
docker exec backup-cron sh /scripts/backup-mongo.sh
```

## Voir les logs

```bash
docker exec backup-cron cat /backups/backup.log
```

## Rebuild du conteneur (après modif des scripts)

```bash
docker compose up -d --build backup-cron
```

## Trouver les fichiers de backup

Les fichiers sont dans `.backup/` à la racine du projet :

```
.backup/
├── backup-data-main/        # dumps PostgreSQL (.sql.gz)
├── backup-recommendation/   # dumps MongoDB (.archive.gz)
└── backup.log               # logs des exécutions
```

```bash
# Lister les backups PostgreSQL disponibles
ls .backup/backup-data-main/
```

## Restaurer les bases de données

La restauration est toujours **manuelle et intentionnelle**. Les scripts listent les fichiers disponibles si tu ne passes pas d'argument.

**PostgreSQL :**
```bash
# Lister les backups disponibles
docker exec backup-cron sh /scripts/restore-postgres.sh

# Restaurer un fichier précis
docker exec backup-cron sh /scripts/restore-postgres.sh backup_20260616_222011.sql.gz
```

**MongoDB :**
```bash
# Lister les backups disponibles
docker exec backup-cron sh /scripts/restore-mongo.sh

# Restaurer un fichier précis (supprime les collections existantes)
docker exec backup-cron sh /scripts/restore-mongo.sh backup_20260616_222011.archive.gz
```

> n8n monitore que les backups sont bien créés chaque nuit et alerte par email en cas d'échec.

## Exporter les workflows n8n

Après avoir modifié un workflow dans l'UI (`localhost:5678`), exporte-le dans git :

```bash
# PowerShell
$env:N8N_API_KEY="ta_cle"; sh scripts/export-n8n-workflows.sh
```

La clé API se crée dans n8n → Settings → n8n API → Create API Key, et se met dans le `.env` sous `N8N_API_KEY`.

## Contenu du dossier

| Fichier | Rôle |
|---|---|
| `backup-postgres.sh` | Dump PostgreSQL compressé |
| `backup-mongo.sh` | Dump MongoDB compressé |
| `restore-postgres.sh` | Restaure PostgreSQL depuis un fichier .sql.gz |
| `restore-mongo.sh` | Restaure MongoDB depuis un fichier .archive.gz |
| `crontab` | Schedule du conteneur backup-cron (2h chaque nuit) |
| `n8n-entrypoint.sh` | Entrypoint custom n8n : importe workflows et credentials au premier démarrage |
| `export-n8n-workflows.sh` | Exporte les workflows n8n vers `n8n/workflows/` |
