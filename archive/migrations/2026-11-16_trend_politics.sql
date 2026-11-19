-- =========================================================================
-- Trend politics switch: one on/off switch on the Trend page, the same for every reader. On, the
-- Trend build also lists political news under a new Politics category; off (the default), it builds
-- none and the page hides any it already has.
-- Design: LanJourney2.0/docs/trend-page.md ("Politics switch").
--
-- There is NO staging environment: run this by hand on PROD, BEFORE deploying the backend that
-- reads and writes it (ddl-auto=validate fails on a missing table).
--
-- What it changes:
--   app_switch                  new table: on/off switches changed from the app (a missing row = off).
--                               The backend writes the 'trend.politics' row the first time someone
--                               uses the switch; nothing is inserted here, so the switch starts off.
--   trend_story_category_check  now also allows 'POLITICS' (the old list plus one value).
-- Safe to re-run. It adds a table and widens one check; no existing row is changed or deleted, so no
-- backup is needed.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; the single row must show migration_ok = true, checks_run 5.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

CREATE TABLE IF NOT EXISTS app_switch (
  name       TEXT PRIMARY KEY,                    -- e.g. 'trend.politics'
  enabled    BOOLEAN NOT NULL DEFAULT FALSE,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- when it was last switched
  changed_by UUID REFERENCES app_user (id) ON DELETE SET NULL -- the reader who switched it last
);

-- Supabase exposes every public table through its REST API; RLS with no policies closes that path
-- (the backend connects as postgres, which bypasses RLS).
ALTER TABLE app_switch ENABLE ROW LEVEL SECURITY;

-- The check gets its old name back, so a re-run finds and replaces the same constraint.
ALTER TABLE trend_story DROP CONSTRAINT IF EXISTS trend_story_category_check;
ALTER TABLE trend_story ADD CONSTRAINT trend_story_category_check
  CHECK (category IN ('WORLD', 'POLITICS', 'BUSINESS', 'TECH', 'SCIENCE_HEALTH'));

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). migration_ok must be true and checks_run 5.
-- =========================================================================
SELECT bool_and(ok) AS migration_ok,
       count(*)     AS checks_run,
       string_agg(check_name, '; ') FILTER (WHERE NOT ok) AS failed_checks
FROM (
  SELECT 'app_switch table exists' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'app_switch') AS ok
  UNION ALL
  SELECT 'app_switch has name, enabled, changed_at, changed_by',
         (SELECT count(*) FROM information_schema.columns
          WHERE table_name = 'app_switch'
            AND column_name IN ('name', 'enabled', 'changed_at', 'changed_by')) = 4
  UNION ALL
  SELECT 'app_switch has row level security on',
         COALESCE((SELECT relrowsecurity FROM pg_class WHERE relname = 'app_switch'), FALSE)
  UNION ALL
  SELECT 'trend_story category check allows POLITICS',
         EXISTS (SELECT 1 FROM pg_constraint
                 WHERE conname = 'trend_story_category_check'
                   AND pg_get_constraintdef(oid) LIKE '%POLITICS%'
                   AND pg_get_constraintdef(oid) LIKE '%SCIENCE_HEALTH%')
  UNION ALL
  SELECT 'every listed story still passes the check',
         NOT EXISTS (SELECT 1 FROM trend_story
                     WHERE category NOT IN ('WORLD', 'POLITICS', 'BUSINESS', 'TECH', 'SCIENCE_HEALTH'))
) checks;


-- =========================================================================
-- Rollback (only if the backend change is rolled back too; political stories must go first):
--   DELETE FROM trend_story WHERE category = 'POLITICS';
--   ALTER TABLE trend_story DROP CONSTRAINT IF EXISTS trend_story_category_check;
--   ALTER TABLE trend_story ADD CONSTRAINT trend_story_category_check
--     CHECK (category IN ('WORLD', 'BUSINESS', 'TECH', 'SCIENCE_HEALTH'));
--   DROP TABLE IF EXISTS app_switch;
-- =========================================================================
