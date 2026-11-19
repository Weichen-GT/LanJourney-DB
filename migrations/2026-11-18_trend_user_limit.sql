-- =========================================================================
-- Per-reader Trend limit: app_user.trend_daily_limit.
--
-- How many Trend articles a reader may start per local day (failed ones are not counted). Every
-- reader gets 3, the number the code used before; change one reader by hand:
--   UPDATE app_user SET trend_daily_limit = 10 WHERE email = 'reader@example.com';
-- 0 means the reader cannot start Trend articles.
--
-- No staging: run this by hand on PROD, BEFORE deploying the backend that reads the column
-- (ddl-auto=validate fails on a missing column). It only ADDS a column with a default; nothing
-- existing is changed, so no backup is needed. Every statement is safe to re-run.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; the single row must show migration_ok = true.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

ALTER TABLE app_user
  ADD COLUMN IF NOT EXISTS trend_daily_limit INT NOT NULL DEFAULT 3
  CHECK (trend_daily_limit >= 0);

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). migration_ok must be true and checks_run 3.
-- =========================================================================
SELECT bool_and(ok) AS migration_ok,
       count(*)     AS checks_run,
       string_agg(check_name, '; ') FILTER (WHERE NOT ok) AS failed_checks
FROM (
  SELECT 'column app_user.trend_daily_limit is INT NOT NULL DEFAULT 3' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'app_user' AND column_name = 'trend_daily_limit'
                   AND data_type = 'integer' AND is_nullable = 'NO'
                   AND column_default = '3') AS ok
  UNION ALL
  SELECT 'check on trend_daily_limit >= 0',
         EXISTS (SELECT 1 FROM pg_constraint
                 WHERE conrelid = 'app_user'::regclass AND contype = 'c'
                   AND pg_get_constraintdef(oid) LIKE '%trend_daily_limit >= 0%')
  UNION ALL
  SELECT 'every reader has a limit',
         NOT EXISTS (SELECT 1 FROM app_user WHERE trend_daily_limit IS NULL)
) checks;
