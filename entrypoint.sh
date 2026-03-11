#!/bin/bash
set -e

# Railway sets PORT; PDS uses PDS_PORT
export PDS_PORT="${PORT:-${PDS_PORT:-3000}}"
PDS_DATA="${PDS_DATA_DIRECTORY:-/pds}"
MARKER="${PDS_DATA}/.test_accounts_created"
LISTEN_PORT="${PDS_PORT}"

# If we have no existing DB and test accounts were never created, create them on first run
if [ ! -f "${MARKER}" ]; then
  if [ -z "$PDS_ADMIN_PASSWORD" ] || [ -z "$PDS_HOSTNAME" ]; then
    echo "Skipping test account creation: PDS_ADMIN_PASSWORD or PDS_HOSTNAME not set"
  else
    echo "First run: starting PDS briefly to create test accounts..."
    export PDS_PORT="$LISTEN_PORT"
    # Start PDS in background
    node --enable-source-maps index.js &
    NODE_PID=$!
    # Wait for PDS to be ready
    for i in $(seq 1 45); do
      if curl -sf "http://127.0.0.1:${LISTEN_PORT}/xrpc/_health" >/dev/null 2>&1; then
        break
      fi
      sleep 1
    done
    # Create test accounts (goat is at /usr/local/bin/goat in the image)
    if [ -x /usr/local/bin/goat ]; then
      /app/seed-accounts.sh || true
      touch "${MARKER}"
    fi
    # Stop background PDS so we can start it in foreground below
    kill $NODE_PID 2>/dev/null || true
    wait $NODE_PID 2>/dev/null || true
    echo "Test account creation complete."
  fi
fi

# Start PDS in foreground (default image CMD)
exec node --enable-source-maps index.js
