#!/usr/bin/env bash
set -euo pipefail

ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
  echo ".env already exists, skipping."
  exit 0
fi

DOMAIN_DEFAULT="$(hostname -f 2>/dev/null || hostname || echo 'localhost')"
RATHENA_USR_DEFAULT="$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 10 || echo s1)"
RATHENA_PWD_DEFAULT="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20 || echo p1)"

INSTALLER_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

RFC1918_IPS="127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
ALLOWED_IPS="$RFC1918_IPS"

cat > "$ENV_FILE" <<EOF
# rAthena environment overrides
# Generated on $(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Server identity
DOMAIN=${DOMAIN_DEFAULT}
RO_SERVER_NAME=Botland
SET_MOTD='Botland Server'

# rAthena credentials and naming
RATHENA_USR=${RATHENA_USR_DEFAULT}
RATHENA_PWD=${RATHENA_PWD_DEFAULT}
RATHENA_NAME=${DOMAIN_DEFAULT}

# FluxCP installer password
INSTALLER_PASSWORD=${INSTALLER_PASSWORD}

ALLOWED_IPS=${ALLOWED_IPS}
EOF

echo "Created $ENV_FILE with defaults."
