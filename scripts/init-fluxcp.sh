#!/bin/bash
set -euo pipefail

# Get the project root directory (parent of scripts dir)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# add check and exit errror env nont initialized
if [ ! -f ".env" ]; then
  echo ".env file not found. Please run 'make init-env' before running this script."
  exit 1
fi
source .env

COOKIE_JAR="$(mktemp)"
trap 'rm -f "${COOKIE_JAR}"' EXIT

curl -qsSLo /dev/null -c "${COOKIE_JAR}" "https://${DOMAIN}"
while ! grep -q 'fluxSessionData' "${COOKIE_JAR}" 2>/dev/null; do
  sleep 2
  curl -qsSLo /dev/null -c "${COOKIE_JAR}" "https://${DOMAIN}"
done

curl -qsSLo /dev/null -b "${COOKIE_JAR}" -c "${COOKIE_JAR}" "https://${DOMAIN}/?module=install" --data "installer_password=${INSTALLER_PASSWORD}"
curl -qsSLo /dev/null -b "${COOKIE_JAR}" -c "${COOKIE_JAR}" "https://${DOMAIN}/?module=install&update_all=1"

echo "✅ FluxCP initialization completed."