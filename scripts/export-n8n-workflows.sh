#!/bin/sh
# Exporte les workflows n8n vers n8n/workflows/
# Usage : sh scripts/export-n8n-workflows.sh

N8N_URL="http://localhost:5678"
OUT_DIR="n8n/workflows"

if [ -z "$N8N_API_KEY" ]; then
    echo "Erreur : N8N_API_KEY non défini dans l'environnement"
    exit 1
fi

mkdir -p "$OUT_DIR"

curl -sf \
    -H "X-N8N-API-KEY: $N8N_API_KEY" \
    "$N8N_URL/api/v1/workflows?limit=50" \
    | tr ',' '\n' \
    | grep -o '"id":"[^"]*"' \
    | grep -o '[0-9a-z-]*"$' \
    | tr -d '"' \
    | while read -r id; do
        workflow=$(curl -sf \
            -H "X-N8N-API-KEY: $N8N_API_KEY" \
            "$N8N_URL/api/v1/workflows/$id")
        name=$(echo "$workflow" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4 \
            | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr 'éèêëàâùûüôîïœç' 'eeeaaouuuoiioc')
        echo "$workflow" > "$OUT_DIR/${name}.json"
        echo "Exporté : ${name}.json"
    done

echo "Terminé → $OUT_DIR/"
