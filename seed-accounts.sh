#!/bin/bash
# Creates dummy test accounts on the PDS. Requires PDS to be running and PDS_ADMIN_PASSWORD set.
set -e
ADMIN_PASSWORD="${PDS_ADMIN_PASSWORD:?PDS_ADMIN_PASSWORD required}"
# Use hostname only for handles (strip https://)
HOST="${PDS_HOSTNAME:-localhost}"
HOST="${HOST#https://}"
HOST="${HOST#http://}"
HOST="${HOST%%/*}"
PDS_PORT="${PORT:-${PDS_PORT:-3000}}"

create_account() {
  local handle="$1"
  local email="$2"
  local password="$3"
  echo "Creating account @${handle}..."
  /usr/local/bin/goat pds admin account create \
    --admin-password "$ADMIN_PASSWORD" \
    --pds-host "http://127.0.0.1:${PDS_PORT}" \
    --handle "$handle" \
    --email "$email" \
    --password "$password" \
    || true
}

# Create 3 test users (handles under your PDS hostname)
create_account "alice.${HOST}" "alice@example.com" "testpass123"
create_account "bob.${HOST}" "bob@example.com" "testpass123"
create_account "carol.${HOST}" "carol@example.com" "testpass123"

echo "Done. Test accounts (password: testpass123):"
echo "  - alice.${HOST}"
echo "  - bob.${HOST}"
echo "  - carol.${HOST}"
