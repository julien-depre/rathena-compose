#!/usr/bin/env bash
set -euo pipefail

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

ENV_FILE=".env"
OVERRIDE_FILE="sql-init/50-override.sql"

if [ ! -f "$ENV_FILE" ]; then
  echo "[SQL Override] .env not found. Run 'make init-env' first."
  exit 1
fi

# shellcheck disable=SC2046
export $(grep -E '^(RATHENA_USR|RATHENA_PWD)=' "$ENV_FILE" | xargs)

mkdir -p sql-init

if [ -f "$OVERRIDE_FILE" ]; then
  echo "[SQL Override] $OVERRIDE_FILE already exists, skipping."
  exit 0
fi

cat > "$OVERRIDE_FILE" <<SQL
-- Override default admin account created by rAthena main.sql
UPDATE login
SET
  userid    = '${RATHENA_USR}',
  user_pass = '${RATHENA_PWD}',
  sex       = 'S',
  email     = 'athena@athena.com'
WHERE account_id = 1;
SQL

echo "[SQL Override] Wrote $OVERRIDE_FILE using credentials from .env"
