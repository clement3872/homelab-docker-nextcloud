#!/usr/bin/env bash
# Generates a ready-to-use .env from .env.example
# Run once before first `docker compose up`
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
EXAMPLE_FILE="$SCRIPT_DIR/.env.example"

if [[ -f "$ENV_FILE" ]]; then
  echo ".env already exists — delete it first if you want to regenerate."
  exit 1
fi

# tr -d '\n' strips the newline openssl introduces at 64 chars (would break sed)
PG_PASS=$(openssl rand -base64 36 | tr -d '\n')
ADMIN_PASS=$(openssl rand -base64 24 | tr -d '\n')
WHITEBOARD_SECRET=$(openssl rand -base64 36 | tr -d '\n')
TURN_SECRET=$(openssl rand -hex 32)

sed \
  -e "s|^PG_PASS=.*|PG_PASS=$PG_PASS|" \
  -e "s|^NEXTCLOUD_ADMIN_PASSWORD=.*|NEXTCLOUD_ADMIN_PASSWORD=$ADMIN_PASS|" \
  -e "s|^WHITEBOARD_SECRET=.*|WHITEBOARD_SECRET=$WHITEBOARD_SECRET|" \
  -e "s|^TURN_SECRET=.*|TURN_SECRET=$TURN_SECRET|" \
  "$EXAMPLE_FILE" > "$ENV_FILE"

echo ".env created with fresh secrets."
echo ""
echo "  PG_PASS              : $PG_PASS"
echo "  NEXTCLOUD_ADMIN_PASS : $ADMIN_PASS"
echo "  WHITEBOARD_SECRET    : $WHITEBOARD_SECRET"
echo "  TURN_SECRET          : $TURN_SECRET"
echo ""
echo "Next:"
echo "  1. Edit .env — set NEXTCLOUD_DOMAIN, AUTH_DOMAIN, NEXTCLOUD_PORT, NEXTCLOUD_TAG"
echo "  2. Copy TURN_SECRET to /etc/turnserver.conf on the VPS"
echo "  3. mkdir -p data/postgresql data/redis html userdata"
echo "  4. docker compose up -d"
