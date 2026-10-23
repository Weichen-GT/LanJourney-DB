#!/usr/bin/env bash
# Throwaway Postgres test of a small hand-run migration (needs the PostgreSQL binaries; Git Bash on
# Windows). Unlike test_migration.sh (written for the article-generation migration, with prod-like
# sample rows), this one checks only that the migration brings an old database to the same schema as
# schema.sql:
#   old_db: the schema at BASE_REF, then the migration twice (must be re-runnable; PART 2 must be all ok)
#   new_db: the current schema.sql
# and compares the structure of every table named in TABLES.
#
#   tools/test_migration_simple.sh migrations/2026-10-21_conversation_quiz.sql [BASE_REF]
#   TABLES="quiz_session meaning_review ..." overrides the compared tables.
set -euo pipefail
PGBIN="${PGBIN:-/c/Program Files/PostgreSQL/18/bin}"
DBREPO="$(cd "$(dirname "$0")/.." && pwd)"
MIG="${1:?usage: tools/test_migration_simple.sh migrations/<file>.sql [base-ref]}"
MIG="$(cd "$(dirname "$MIG")" && pwd)/$(basename "$MIG")"
BASE_REF="${2:-article-generation}"
TABLES="${TABLES:-quiz_session meaning_review conversation_message conversation_target}"
WORK="${TMPDIR:-/tmp}/lj-migration-simple"
PORT=54328
rm -rf "$WORK"; mkdir -p "$WORK"
"$PGBIN/initdb" -D "$WORK/data" -U postgres -A trust -E UTF8 >/dev/null
"$PGBIN/pg_ctl" -D "$WORK/data" -o "-p $PORT" -l "$WORK/log" -w start >/dev/null
trap '"$PGBIN/pg_ctl" -D "$WORK/data" -m fast -w stop >/dev/null' EXIT
PSQL=("$PGBIN/psql" -h localhost -p $PORT -U postgres -v ON_ERROR_STOP=1 -q -X)

git -C "$DBREPO" show "$BASE_REF:schema.sql" > "$WORK/old_schema.sql"
for db in old_db new_db; do "${PSQL[@]}" -c "CREATE DATABASE $db"; done
"${PSQL[@]}" -d old_db -f "$WORK/old_schema.sql" >/dev/null
"${PSQL[@]}" -d new_db -f "$DBREPO/schema.sql" >/dev/null

echo "== old_db: migration, first run"
"${PSQL[@]}" -d old_db -f "$MIG"
echo "== old_db: migration, second run (must not fail, PART 2 must still be all true)"
"${PSQL[@]}" -d old_db -f "$MIG" | tee "$WORK/second_run.txt"
if grep -E '^\s*[^|]+\|\s*f\s*$' "$WORK/second_run.txt" >/dev/null; then
  echo "FAIL: a PART 2 check is false" >&2; exit 1
fi

args=()
for t in $TABLES; do args+=(-t "$t"); done
for db in old_db new_db; do
  "$PGBIN/pg_dump" -h localhost -p $PORT -U postgres -s --no-owner --no-privileges "${args[@]}" "$db" \
    | grep -v '^--' | grep -v '^$' | grep -v '^SET \|^SELECT pg_catalog\|^.restrict \|^.unrestrict ' | sort > "$WORK/$db.dump"
done
if diff "$WORK/old_db.dump" "$WORK/new_db.dump" > "$WORK/schema.diff"; then
  echo "OK: the migrated database has the same structure as schema.sql for: $TABLES"
else
  echo "FAIL: migrated database differs from schema.sql:" >&2; cat "$WORK/schema.diff" >&2; exit 1
fi
