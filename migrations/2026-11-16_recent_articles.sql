-- =========================================================================
-- Recent Articles: the sidebar lists the articles the reader opened last, not the ones saved last.
-- Design: LanJourney2.0/docs/reading-page.md ("Recent Articles").
--
-- There is NO staging environment: run this by hand on PROD, BEFORE deploying the backend that
-- reads and writes these columns (ddl-auto=validate fails on a missing column).
--
-- What it changes:
--   user_article.last_opened_at       new column, NOT NULL, default now(): when the reader last opened
--                                     the article (its save time until the first open). Every existing
--                                     row gets the last time we know they read it: completed_at, or
--                                     saved_at when unfinished. Rows saved before 2026-11-15 already have
--                                     completed_at = saved_at, so their order does not change.
--   idx_user_article_user_last_opened the reader's articles, last opened first (the sidebar query).
--   generated_article.last_opened_at  new column, NULL until the reader opens the For You article; every
--                                     existing row gets its first_opened_at.
-- The default keeps the backend that is still running until the deploy saving valid rows. Safe to
-- re-run. It only adds columns and an index and fills them in; nothing existing is changed or
-- deleted, so no backup is needed.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; the single row must show migration_ok = true, checks_run 6.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

-- Only when the column is new: a re-run after the deploy must not reset the open times readers made.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'user_article' AND column_name = 'last_opened_at') THEN
    ALTER TABLE user_article ADD COLUMN last_opened_at TIMESTAMPTZ;
    UPDATE user_article SET last_opened_at = COALESCE(completed_at, saved_at);
    ALTER TABLE user_article
      ALTER COLUMN last_opened_at SET DEFAULT NOW(),
      ALTER COLUMN last_opened_at SET NOT NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_user_article_user_last_opened
  ON user_article (user_id, last_opened_at DESC);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'generated_article' AND column_name = 'last_opened_at') THEN
    ALTER TABLE generated_article ADD COLUMN last_opened_at TIMESTAMPTZ;
    UPDATE generated_article SET last_opened_at = first_opened_at;
  END IF;
END $$;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). migration_ok must be true and checks_run 6.
-- Run it right after PART 1, before the deploy: once the new backend runs, reopened For You articles
-- have a later last_opened_at than first_opened_at, and the last check will (correctly) find them.
-- =========================================================================
SELECT bool_and(ok) AS migration_ok,
       count(*)     AS checks_run,
       string_agg(check_name, '; ') FILTER (WHERE NOT ok) AS failed_checks
FROM (
  SELECT 'user_article.last_opened_at exists, NOT NULL, default now()' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'user_article' AND column_name = 'last_opened_at'
                   AND is_nullable = 'NO' AND column_default ILIKE '%now()%') AS ok
  UNION ALL
  SELECT 'every saved article has an open time',
         NOT EXISTS (SELECT 1 FROM user_article WHERE last_opened_at IS NULL)
  UNION ALL
  SELECT 'every saved article counts as opened when it was last read (completed, else saved)',
         NOT EXISTS (SELECT 1 FROM user_article
                     WHERE last_opened_at < COALESCE(completed_at, saved_at))
  UNION ALL
  SELECT 'index idx_user_article_user_last_opened exists',
         EXISTS (SELECT 1 FROM pg_indexes
                 WHERE tablename = 'user_article' AND indexname = 'idx_user_article_user_last_opened')
  UNION ALL
  SELECT 'generated_article.last_opened_at exists, may be NULL',
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'generated_article' AND column_name = 'last_opened_at'
                   AND is_nullable = 'YES')
  UNION ALL
  SELECT 'every For You article''s open time is its first open',
         NOT EXISTS (SELECT 1 FROM generated_article
                     WHERE last_opened_at IS DISTINCT FROM first_opened_at)
) checks;


-- =========================================================================
-- Rollback (only if the backend change is rolled back too):
--   DROP INDEX IF EXISTS idx_user_article_user_last_opened;
--   ALTER TABLE user_article DROP COLUMN IF EXISTS last_opened_at;
--   ALTER TABLE generated_article DROP COLUMN IF EXISTS last_opened_at;
-- =========================================================================
