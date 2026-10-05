#!/usr/bin/env bash
# Throwaway Postgres test of a hand-run migration (needs the PostgreSQL binaries; Git Bash on Windows):
#  old_db:  main-branch schema.sql, then the migration twice (must be re-runnable)
#  prod_db: main-branch schema made to look like prod (2026-10-03 constraint name,
#           leftover default, sample rows), migration, PART 3, migration again
#  new_db:  branch schema.sql, then the migration (must be a no-op on a fresh schema)
set -euo pipefail
PGBIN="${PGBIN:-/c/Program Files/PostgreSQL/18/bin}"
DBREPO="$(cd "$(dirname "$0")/.." && pwd)"
MIG="${1:?usage: tools/test_migration.sh migrations/<file>.sql}"; MIG="$(cd "$(dirname "$MIG")" && pwd)/$(basename "$MIG")"
WORK="${TMPDIR:-/tmp}/lj-migration-test"
PORT=54329
rm -rf "$WORK"; mkdir -p "$WORK"
"$PGBIN/initdb" -D "$WORK/data" -U postgres -A trust -E UTF8 >/dev/null
"$PGBIN/pg_ctl" -D "$WORK/data" -o "-p $PORT" -l "$WORK/log" -w start >/dev/null
trap '"$PGBIN/pg_ctl" -D "$WORK/data" -m fast -w stop >/dev/null' EXIT
PSQL=("$PGBIN/psql" -h localhost -p $PORT -U postgres -v ON_ERROR_STOP=1 -q -X)

git -C "$DBREPO" show main:schema.sql > "$WORK/old_schema.sql"
# PART 3 is commented out in the file: pull out every "-- BEGIN; ... -- COMMIT;" block.
sed -n '/^-- BEGIN;/,/^-- COMMIT;/p' "$MIG" | sed 's/^-- //' > "$WORK/part3.sql"

for db in old_db prod_db new_db; do "${PSQL[@]}" -c "CREATE DATABASE $db"; done
"${PSQL[@]}" -d old_db -f "$WORK/old_schema.sql" >/dev/null
"${PSQL[@]}" -d prod_db -f "$WORK/old_schema.sql" >/dev/null
"${PSQL[@]}" -d new_db -f "$DBREPO/schema.sql" >/dev/null

"${PSQL[@]}" -d prod_db >/dev/null <<'SQL'
ALTER TABLE user_meaning RENAME CONSTRAINT user_meaning_source_check TO chk_user_meaning_source;
ALTER TABLE user_meaning ALTER COLUMN source SET DEFAULT 'ARTICLE';
INSERT INTO app_user (id, email, auth_provider, auth_provider_user_id)
  VALUES ('00000000-0000-0000-0000-000000000001', 't@example.com', 'local', 't@example.com');
INSERT INTO vocabulary (id, term) VALUES (1, 'harbor'), (2, 'zebra');
INSERT INTO meaning (id, vocab_id, sense_key, definition) VALUES (1, 1, 'noun_port', 'a port'), (2, 2, 'noun_animal', 'an animal');
INSERT INTO user_meaning (user_id, meaning_id, status, source) VALUES
  ('00000000-0000-0000-0000-000000000001', 1, 0, 'ARTICLE'),
  ('00000000-0000-0000-0000-000000000001', 2, 6, 'ONBOARDING');
INSERT INTO meaning_review (user_id, meaning_id, source, recognized, status_before, status_after, reviewed_at) VALUES
  ('00000000-0000-0000-0000-000000000001', 1, 'ARTICLE',    true, 0, 0, '2026-09-01T08:00:00Z'),
  ('00000000-0000-0000-0000-000000000001', 1, 'ARTICLE',    true, 0, 1, '2026-09-05T08:00:00Z'),
  ('00000000-0000-0000-0000-000000000001', 1, 'QUICK_TEST', true, 1, 2, '2026-09-10T08:00:00Z');
SQL

echo "== old_db: migration (1st run)"; "${PSQL[@]}" -d old_db -f "$MIG"
echo "== old_db: migration (2nd run)"; "${PSQL[@]}" -d old_db -f "$MIG" 2>/dev/null
echo "== prod_db: migration";          "${PSQL[@]}" -d prod_db -f "$MIG"
echo "== prod_db: rows after PART 1 (meaning 1: REWRITE, last seen 2026-09-05; meaning 2: no exposure)"
"${PSQL[@]}" -d prod_db -c "SET TIME ZONE 'UTC'; SELECT meaning_id, source, last_seen_at FROM user_meaning ORDER BY 1"
echo "== prod_db: PART 3, then migration again (must stay strict)"
"${PSQL[@]}" -d prod_db -f "$WORK/part3.sql"
"${PSQL[@]}" -d prod_db -f "$MIG" 2>/dev/null
echo "== prod_db: an ARTICLE insert must now fail"
if "${PSQL[@]}" -d prod_db -c "INSERT INTO user_meaning (user_id, meaning_id, status, source) VALUES ('00000000-0000-0000-0000-000000000001', 2, 0, 'ARTICLE')" 2>/dev/null; then echo "FAIL: ARTICLE accepted"; else echo "ok: ARTICLE rejected"; fi
echo "== new_db: migration on the fresh branch schema"; "${PSQL[@]}" -d new_db -f "$MIG" 2>/dev/null
if [ -n "${EXTRA_SQL:-}" ]; then echo "== extra checks"; "${PSQL[@]}" -d prod_db -c "$EXTRA_SQL"; fi
