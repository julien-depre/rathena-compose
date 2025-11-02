#!/bin/bash
set -euo pipefail

# Get the project root directory (parent of scripts dir)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "[Clean] Purging generated files and directories..."

# Remove SQL initialization files
if [ -d ./sql-init ]; then
    echo "[Clean] Removing SQL files..."
    rm -rf ./sql-init
    echo "  ✓ sql-init/ removed"
else
    echo "  ✓ sql-init/ (already clean)"
fi

# Remove Docker container/volume/network
echo "[Clean] Stopping and removing Docker containers, volumes, and networks..."
docker compose down --volumes --remove-orphans

# Remove .env file
if [ -f .env ]; then
    echo "[Clean] Removing .env file..."
    rm -f .env
    echo "  ✓ .env removed"
else
    echo "  ✓ .env (already clean)"
fi

echo "[Clean] Purge complete!"
