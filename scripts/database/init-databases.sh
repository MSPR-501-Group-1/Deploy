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
  MONGO_HOST
  MONGO_PORT
  MONGO_DB
  MONGO_AUTH_DB
  MONGO_USER
  MONGO_PASSWORD
)

for var in "${required_vars[@]}"; do
  require_env "$var"
done

COMPOSE=(docker compose --project-directory "$ROOT_DIR")

echo "HealthAI - Database initialization"
echo "================================="

# Wait for PostgreSQL
until "${COMPOSE[@]}" exec -T db-main pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; do
  echo "  -> PostgreSQL not ready, waiting..."
  sleep 2
done

echo "PostgreSQL is ready"

# Wait for MongoDB
until "${COMPOSE[@]}" exec -T db-nut-reco mongosh --quiet -u "$MONGO_USER" -p "$MONGO_PASSWORD" --authenticationDatabase "$MONGO_AUTH_DB" --eval "db.adminCommand('ping')" >/dev/null 2>&1; do
  echo "  -> MongoDB not ready, waiting..."
  sleep 2
done

echo "MongoDB is ready"

# Apply Mongo init script (validators + indexes)
"${COMPOSE[@]}" exec -T db-nut-reco mongosh --quiet -u "$MONGO_USER" -p "$MONGO_PASSWORD" --authenticationDatabase "$MONGO_AUTH_DB" "$MONGO_DB" /docker-entrypoint-initdb.d/01_init.js

# Seed data (optional)
if [ "${SEED_DATA:-false}" = "true" ]; then
  echo "Seeding test data..."
  has_pg_data=$("${COMPOSE[@]}" exec -T db-main psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT 1 FROM health_goal LIMIT 1;")
  if [ "$has_pg_data" = "1" ]; then
    echo "PostgreSQL seed skipped (data already present)"
  else
    "${COMPOSE[@]}" exec -T db-main psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/02_seed.sql
  fi
  "${COMPOSE[@]}" exec -T db-nut-reco mongosh --quiet -u "$MONGO_USER" -p "$MONGO_PASSWORD" --authenticationDatabase "$MONGO_AUTH_DB" "$MONGO_DB" /seed/seed_v0.js
  echo "Seed data inserted"
fi

# Validations
"$SCRIPT_DIR/validate-pg.sh"
"$SCRIPT_DIR/validate-mongo.sh"

echo "Initialization complete"
echo "PostgreSQL: ${POSTGRES_DB} on ${POSTGRES_HOST}:${POSTGRES_PORT}"
echo "MongoDB: ${MONGO_DB} on ${MONGO_HOST}:${MONGO_PORT}"
echo "Compass: mongodb://${MONGO_USER}:${MONGO_PASSWORD}@localhost:${MONGO_PORT}/${MONGO_DB}?authSource=${MONGO_AUTH_DB}"
