#!/bin/sh
set -o pipefail
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DIR=/backups/backup-recommendation
mkdir -p "$DIR"

find "$DIR" -name "*.archive.gz" -mtime +7 -delete 2>/dev/null || true

if docker exec database-nutrition-recommendation sh -c \
    'mongodump \
        --username "$MONGO_INITDB_ROOT_USERNAME" \
        --password "$MONGO_INITDB_ROOT_PASSWORD" \
        --authenticationDatabase admin \
        --archive' \
    | gzip > "$DIR/backup_${TIMESTAMP}.archive.gz"; then
    STATUS="ok"
else
    STATUS="error"
    rm -f "$DIR/backup_${TIMESTAMP}.archive.gz"
fi

curl -sf "http://n8n:5678/webhook/backup-status" \
    -H "Content-Type: application/json" \
    -d "{\"type\":\"mongodb\",\"status\":\"${STATUS}\",\"file\":\"backup_${TIMESTAMP}.archive.gz\"}" \
    2>/dev/null || true

echo "[$(date)] MongoDB ${STATUS} → backup_${TIMESTAMP}.archive.gz"
