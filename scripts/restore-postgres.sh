#!/bin/sh
# Usage : docker exec backup-cron sh /scripts/restore-postgres.sh backup_20260616_222011.sql.gz

FILE="$1"

if [ -z "$FILE" ]; then
    echo "Usage : sh /scripts/restore-postgres.sh <fichier.sql.gz>"
    echo "Fichiers disponibles :"
    ls /backups/backup-data-main/*.sql.gz 2>/dev/null || echo "  (aucun)"
    exit 1
fi

FILEPATH="/backups/backup-data-main/$FILE"

if [ ! -f "$FILEPATH" ]; then
    echo "Erreur : fichier introuvable → $FILEPATH"
    exit 1
fi

echo "Restauration PostgreSQL depuis : $FILE"
echo "ATTENTION : les données actuelles seront écrasées."
echo ""

gunzip -c "$FILEPATH" \
    | docker exec -i database-main sh -c 'psql -U "$POSTGRES_USER" "$POSTGRES_DB"'

if [ $? -eq 0 ]; then
    echo "[$(date)] PostgreSQL restauré depuis $FILE"
else
    echo "[$(date)] Erreur lors de la restauration PostgreSQL"
    exit 1
fi
