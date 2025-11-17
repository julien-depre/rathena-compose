#!/bin/bash
set -euo pipefail

# Get the project root directory (parent of scripts dir)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "[SQL Extract] Extracting SQL initialization files from rAthena image..."

# Prepare directory for SQL files (keep directory to avoid deleting tracked files)
mkdir -p ./sql-init

# Remove only previously extracted SQL files from the directory, preserving
# any tracked files like .gitkeep so Git doesn't see deletions.
shopt -s nullglob
for f in ./sql-init/*.sql; do
    rm -f -- "$f"
done
shopt -u nullglob

# Create a temporary container to extract SQL files
echo "[SQL Extract] Creating temporary container..."
CONTAINER_ID=$(docker create ghcr.io/julien-depre/rathena-docker:all-latest)

# Define the exact files needed in execution order
declare -a SQL_FILES=(
    "sql-files/main.sql"
    "sql-files/web.sql"
    "sql-files/roulette_default_data.sql"
    "sql-files/logs.sql"
    "sql-files/item_db_re.sql"
    "sql-files/item_db_re_equip.sql"
    "sql-files/item_db_re_etc.sql"
    "sql-files/item_db_re_usable.sql"
    "sql-files/item_db2_re.sql"
    "sql-files/mob_db_re.sql"
    "sql-files/mob_db2_re.sql"
    "sql-files/mob_skill_db_re.sql"
    "sql-files/mob_skill_db2_re.sql"
    "sql-files/compatibility/item_db_re_compat.sql"
    "sql-files/compatibility/item_db2_re_compat.sql"
)

# Extract each file in order with numeric prefix
echo "[SQL Extract] Extracting SQL files in specified order..."
counter=1
for sql_file in "${SQL_FILES[@]}"; do
    filename=$(basename "$sql_file")
    prefix=$(printf "%02d" $counter)
    output_file="./sql-init/${prefix}-${filename}"
    
    # Try different base paths
    extracted=false
    for base_path in "/rathena" "/src/rathena"; do
        full_path="${base_path}/${sql_file}"
        
        if docker cp "${CONTAINER_ID}:${full_path}" "${output_file}" 2>/dev/null; then
            echo "  ✓ [${prefix}] ${filename}"
            extracted=true
            ((counter++))
            break
        fi
    done
    
    if [ "$extracted" = false ]; then
        echo "  ✗ [${prefix}] ${filename} - NOT FOUND"
    fi
done

# Clean up temporary container
echo "[SQL Extract] Cleaning up..."
docker rm "${CONTAINER_ID}" >/dev/null

# Summary
echo ""
echo "[SQL Extract] Summary:"
echo "  Total files requested: ${#SQL_FILES[@]}"
echo "  Files extracted: $(find ./sql-init -name "*.sql" | wc -l)"
echo ""
echo "[SQL Extract] Extracted files:"
find ./sql-init -name "*.sql" | sort | sed 's|^\./sql-init/|  |'

echo ""
echo "[SQL Extract] Done! SQL files are ready for MariaDB initialization."
echo "[SQL Extract] Files will be executed in alphabetical order by MariaDB."

