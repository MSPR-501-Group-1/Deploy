#!/bin/sh
set -o pipefail
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DIR=/backups/backup-data-main
mkdir -p "$DIR"

find "$DIR" -name "*.sql.gz" -mtime +7 -delete 2>/dev/null || true

if docker exec database-main sh -c 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" --clean --if-exists' \
    | gzip > "$DIR/backup_${TIMESTAMP}.sql.gz"; then
    STATUS="ok"
else
    STATUS="error"
    rm -f "$DIR/backup_${TIMESTAMP}.sql.gz"
fi

curl -sf "http://n8n:5678/webhook/backup-status" \
    -H "Content-Type: application/json" \
    -d "{\"type\":\"postgres\",\"status\":\"${STATUS}\",\"file\":\"backup_${TIMESTAMP}.sql.gz\"}" \
    2>/dev/null || true

echo "[$(date)] PostgreSQL ${STATUS} → backup_${TIMESTAMP}.sql.gz"
