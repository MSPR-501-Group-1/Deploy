#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing .env at $ENV_FILE"
  exit 1
fi

set -a
# shellcheck disable=SC1090
source <(tr -d '\r' < "$ENV_FILE")
set +a

require_env() {
  local name="$1"
  if [ -z "${!name:-}" ]; then
    echo "Missing env var: $name"
    exit 1
  fi
}

required_vars=(
  POSTGRES_HOST
  POSTGRES_PORT
  POSTGRES_DB
  POSTGRES_USER
  POSTGRES_PASSWORD
)

for var in "${required_vars[@]}"; do
  require_env "$var"
done

COMPOSE=(docker compose --project-directory "$ROOT_DIR")

echo "Validating PostgreSQL..."
"${COMPOSE[@]}" exec -T db-main pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"

required_tables=(
  "user_"
  "ingredient"
  "recipe"
  "exercise"
  "meal"
  "workout_session"
)

missing_tables=()
for table_name in "${required_tables[@]}"; do
  exists=$("${COMPOSE[@]}" exec -T db-main psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='${table_name}';")
  if [ "$exists" != "1" ]; then
    missing_tables+=("$table_name")
  fi
done

if [ ${#missing_tables[@]} -gt 0 ]; then
  echo "Missing tables: ${missing_tables[*]}"
  exit 1
fi

"${COMPOSE[@]}" exec -T db-main psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
  SELECT table_name,
         (SELECT COUNT(*) FROM information_schema.columns c WHERE c.table_name = t.table_name) AS column_count
  FROM information_schema.tables t
  WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  ORDER BY table_name;
"

echo "PostgreSQL validation OK"
