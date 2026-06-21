#!/bin/sh
# Usage : docker exec backup-cron sh /scripts/restore-mongo.sh backup_20260616_222011.archive.gz

FILE="$1"

if [ -z "$FILE" ]; then
    echo "Usage : sh /scripts/restore-mongo.sh <fichier.archive.gz>"
    echo "Fichiers disponibles :"
    ls /backups/backup-recommendation/*.archive.gz 2>/dev/null || echo "  (aucun)"
    exit 1
fi

FILEPATH="/backups/backup-recommendation/$FILE"

if [ ! -f "$FILEPATH" ]; then
    echo "Erreur : fichier introuvable → $FILEPATH"
    exit 1
fi

echo "Restauration MongoDB depuis : $FILE"
echo "ATTENTION : les collections existantes seront supprimées (--drop)."
echo ""

gunzip -c "$FILEPATH" \
    | docker exec -i database-nutrition-recommendation sh -c \
        'mongorestore \
            --username "$MONGO_INITDB_ROOT_USERNAME" \
            --password "$MONGO_INITDB_ROOT_PASSWORD" \
            --authenticationDatabase admin \
            --archive \
            --drop'

if [ $? -eq 0 ]; then
    echo "[$(date)] MongoDB restauré depuis $FILE"
else
    echo "[$(date)] Erreur lors de la restauration MongoDB"
    exit 1
fi
