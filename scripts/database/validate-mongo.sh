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

echo "Validating MongoDB..."
"${COMPOSE[@]}" exec -T db-nut-reco mongosh --quiet -u "$MONGO_USER" -p "$MONGO_PASSWORD" --authenticationDatabase "$MONGO_AUTH_DB" --eval "db.adminCommand('ping')" >/dev/null

"${COMPOSE[@]}" exec -T db-nut-reco mongosh --quiet -u "$MONGO_USER" -p "$MONGO_PASSWORD" --authenticationDatabase "$MONGO_AUTH_DB" "$MONGO_DB" --eval "
  const required = ['meal_plans', 'workout_programs', 'image_analyses'];
  const names = db.getCollectionNames();
  const missing = required.filter(name => names.indexOf(name) === -1);
  if (missing.length) {
    print('Missing collections: ' + missing.join(', '));
    quit(1);
  }
  print('MongoDB collections OK: ' + required.join(', '));
"

echo "MongoDB validation OK"
