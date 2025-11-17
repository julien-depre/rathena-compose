#!/bin/bash
set -euo pipefail

# Get the project root directory (parent of scripts dir)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Check if MariaDB volume already exists (indicates database is already initialized)
if docker volume ls --format "{{.Name}}" | grep -q "^rathena_mariadb_data$"; then
  echo "⚠️  MariaDB volume 'rathena_mariadb_data' already exists."
  echo "Database appears to already be initialized. Skipping initialization."
  echo "If you want to reinitialize, please run 'make clean' first to remove the existing volume."
  exit 0
fi

if [ ! -d "sql-init" ]; then
  echo "sql-init directory not found. Please run 'make extract-sql' first."
  exit 1
fi

cid=$(docker compose run --rm --volume ./sql-init:/docker-entrypoint-initdb.d:ro --detach mariadb)
timeout=120
echo "Waiting for container $cid to become healthy for $timeout seconds..."
while [ "$timeout" -gt 0 ]; do
  status=$(docker inspect --format='{{.State.Health.Status}}' "$cid" 2>/dev/null || echo "unknown")
  if [ "$status" = "healthy" ]; then
    echo "✅ Container is healthy."
    break
  fi
  if [ "$status" = "unhealthy" ]; then
    echo "❌ Container became unhealthy."
    break
  fi
  sleep 2
  ((timeout--))
done

# cleanup sql-init directory
rm -rf sql-init

sleep 1
docker compose down --remove-orphans

echo "✅ Database initialization completed."
