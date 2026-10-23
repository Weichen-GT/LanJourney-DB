#!/usr/bin/env bash
# Throwaway local Postgres for the article-generation spike (needs the PostgreSQL binaries; Git Bash
# on Windows). It holds the real vocabulary (schema.sql + seed/) and nothing else: the spike creates
# its synthetic readers in it and never touches prod.
#
#   tools/spike_db.sh start   create the cluster on first use, load schema + seeds, start it
#   tools/spike_db.sh stop    stop it (data stays)
#   tools/spike_db.sh reset   delete everything and load again
#   tools/spike_db.sh psql    open psql on it
#
# The data lives outside OneDrive (it must not be synced). Port 54330, database lanjourney, user
# postgres, no password (trust auth, localhost only). Your own PostgreSQL service is not touched.
set -euo pipefail
PGBIN="${PGBIN:-/c/Program Files/PostgreSQL/18/bin}"
DBREPO="$(cd "$(dirname "$0")/.." && pwd)"
HOME_DIR="${LJ_SPIKE_DB_DIR:-${LOCALAPPDATA:-$HOME}/lj-spike-db}"
DATA="$HOME_DIR/data"
PORT="${LJ_SPIKE_DB_PORT:-54330}"
PSQL=("$PGBIN/psql" -h localhost -p "$PORT" -U postgres -v ON_ERROR_STOP=1 -q -X)
export PGCLIENTENCODING=UTF8 # psql on Windows defaults to WIN1252 and fails on the seeds

running() { "$PGBIN/pg_ctl" -D "$DATA" status >/dev/null 2>&1; }

start() {
  mkdir -p "$HOME_DIR"
  if [ ! -d "$DATA" ]; then
    echo "creating cluster in $DATA"
    "$PGBIN/initdb" -D "$DATA" -U postgres -A trust -E UTF8 >/dev/null
  fi
  if ! running; then
    "$PGBIN/pg_ctl" -D "$DATA" -o "-p $PORT -c listen_addresses=localhost" \
      -l "$HOME_DIR/server.log" -w start >/dev/null
  fi
  if ! "${PSQL[@]}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='lanjourney'" | grep -q 1; then
    echo "loading schema and vocabulary (a minute or two)"
    "${PSQL[@]}" -d postgres -c "CREATE DATABASE lanjourney"
    "${PSQL[@]}" -d lanjourney -f "$DBREPO/schema.sql" >/dev/null
    for f in "$DBREPO"/seed/0*.sql; do
      echo "  $(basename "$f")"
      "${PSQL[@]}" -d lanjourney -f "$f" >/dev/null
    done
  fi
  echo "ready: jdbc:postgresql://localhost:$PORT/lanjourney (user postgres, no password)"
  "${PSQL[@]}" -d lanjourney -tAc \
    "SELECT 'vocabulary: ' || COUNT(*) || ' words, ' || COUNT(frequency_rank) || ' ranked; meanings: ' || (SELECT COUNT(*) FROM meaning) FROM vocabulary"
}

stop() { running && "$PGBIN/pg_ctl" -D "$DATA" -m fast -w stop >/dev/null && echo stopped || echo "not running"; }

case "${1:-}" in
  start) start ;;
  stop) stop ;;
  reset) stop || true; rm -rf "$HOME_DIR"; start ;;
  psql) exec "$PGBIN/psql" -h localhost -p "$PORT" -U postgres -d lanjourney ;;
  *) echo "usage: tools/spike_db.sh start|stop|reset|psql" >&2; exit 2 ;;
esac
