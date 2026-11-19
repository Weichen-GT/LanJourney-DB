-- =========================================================================
-- Reading page: an article's words reach the reader's list only when they press Complete Reading.
-- Design: LanJourney2.0/docs/reading-page.md.
--
-- There is NO staging environment: run this by hand on PROD, BEFORE deploying the backend that
-- reads and writes these columns (ddl-auto=validate fails on a missing column).
--
-- What it changes:
--   user_article.completed_at  new column, NULL while the reader has not finished the article.
--                              Every existing row gets its saved_at: those articles saved their words
--                              when they were written, so they count as finished.
--   article_meaning.role       new column, TAUGHT (a word the article teaches) or SEEN (a word the
--                              reader already has, used again). Every existing row is TAUGHT, which is
--                              what the old code saved.
-- Both columns default to "finished" / TAUGHT, so the backend still running until the deploy keeps
-- saving rows that are correct for the way it works. Safe to re-run. It only adds columns and fills
-- them in; nothing existing is changed or deleted, so no backup is needed.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; the single row must show migration_ok = true.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

-- Only when the column is new: ADD COLUMN fills the existing rows with the time of this run, and their
-- real finish time is when they were saved. A re-run after the deploy must not touch the column, or it
-- would mark readers' unfinished articles as finished.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'user_article' AND column_name = 'completed_at') THEN
    ALTER TABLE user_article ADD COLUMN completed_at TIMESTAMPTZ DEFAULT NOW();
    UPDATE user_article SET completed_at = saved_at;
  END IF;
END $$;

ALTER TABLE article_meaning ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'TAUGHT';
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'article_meaning_role_check') THEN
    ALTER TABLE article_meaning
      ADD CONSTRAINT article_meaning_role_check CHECK (role IN ('TAUGHT', 'SEEN'));
  END IF;
END $$;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). migration_ok must be true and checks_run 5.
-- Run it right after PART 1, before the deploy: once the new backend runs, unfinished articles are
-- normal and the second check will (correctly) find them.
-- =========================================================================
SELECT bool_and(ok) AS migration_ok,
       count(*)     AS checks_run,
       string_agg(check_name, '; ') FILTER (WHERE NOT ok) AS failed_checks
FROM (
  SELECT 'user_article.completed_at exists, may be NULL' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'user_article' AND column_name = 'completed_at'
                   AND is_nullable = 'YES') AS ok
  UNION ALL
  SELECT 'every article saved before today counts as finished',
         NOT EXISTS (SELECT 1 FROM user_article
                     WHERE completed_at IS NULL AND saved_at < now() - interval '1 hour')
  UNION ALL
  SELECT 'article_meaning.role exists, NOT NULL, default TAUGHT',
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'article_meaning' AND column_name = 'role'
                   AND is_nullable = 'NO' AND column_default LIKE '%TAUGHT%')
  UNION ALL
  SELECT 'role check allows TAUGHT and SEEN',
         COALESCE((SELECT pg_get_constraintdef(oid) LIKE '%TAUGHT%'
                          AND pg_get_constraintdef(oid) LIKE '%SEEN%'
                   FROM pg_constraint WHERE conname = 'article_meaning_role_check'), FALSE)
  UNION ALL
  SELECT 'every existing link is TAUGHT',
         NOT EXISTS (SELECT 1 FROM article_meaning WHERE role IS NULL)
) checks;


-- =========================================================================
-- Rollback (only if the backend change is rolled back too):
--   ALTER TABLE article_meaning DROP CONSTRAINT IF EXISTS article_meaning_role_check;
--   ALTER TABLE article_meaning DROP COLUMN IF EXISTS role;
--   ALTER TABLE user_article DROP COLUMN IF EXISTS completed_at;
-- =========================================================================
