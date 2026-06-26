#!/bin/sh
set -e

MARKER=/home/node/.n8n/.imported

if [ ! -f "$MARKER" ]; then
    if ls /n8n-workflows/*.json 2>/dev/null | grep -v credentials.json > /dev/null; then
        echo "[n8n] Import des workflows..."
        n8n import:workflow --separate --input=/n8n-workflows/ || true
    fi

    if [ -n "$N8N_CREDENTIALS_B64" ]; then
        echo "[n8n] Import des credentials (depuis .env)..."
        echo "$N8N_CREDENTIALS_B64" | base64 -d > /tmp/credentials.json
        n8n import:credentials --input=/tmp/credentials.json || true
        rm -f /tmp/credentials.json
    elif [ -f /n8n-workflows/credentials.json ]; then
        echo "[n8n] Import des credentials (depuis fichier)..."
        n8n import:credentials --input=/n8n-workflows/credentials.json || true
    fi

    touch "$MARKER"
fi

exec /docker-entrypoint.sh "$@"
