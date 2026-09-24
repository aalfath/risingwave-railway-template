#!/bin/sh
set -eu

: "${RW_ROOT_PASSWORD:?set RW_ROOT_PASSWORD}"
export RW_SINGLE_NODE_CONFIG_PATH="${RW_SINGLE_NODE_CONFIG_PATH:-/etc/risingwave/risingwave.toml}"
export RW_SINGLE_NODE_STORE_DIRECTORY="${RW_SINGLE_NODE_STORE_DIRECTORY:-/risingwave/data}"
mkdir -p "$RW_SINGLE_NODE_STORE_DIRECTORY"

/risingwave/bin/risingwave single_node --listen-addr "${RW_LISTEN_ADDR:-[::]:4566}" "$@" &
pid=$!
trap 'kill -TERM "$pid"' TERM INT

# Wait for the frontend.
tries=0
until pg_isready -q -h 127.0.0.1 -p 4566; do
  kill -0 "$pid" 2>/dev/null || exit 1
  tries=$((tries + 1)); [ "$tries" -gt 300 ] && { echo "risingwave did not become ready" >&2; exit 1; }
  sleep 1
done
# Loopback is trusted (see risingwave.toml), so apply RW_ROOT_PASSWORD on every start;
# changing the variable and redeploying rotates the password.
pw=$(printf "%s" "$RW_ROOT_PASSWORD" | sed "s/'/''/g")
psql -h 127.0.0.1 -p 4566 -U root -d dev -w -qAtc "ALTER USER root WITH PASSWORD '$pw'" && echo "root password set"

# Keep waiting after a TERM so the server finishes its shutdown before the container exits.
status=0
wait "$pid" || status=$?
while kill -0 "$pid" 2>/dev/null; do
  wait "$pid" || status=$?
done
exit "$status"
