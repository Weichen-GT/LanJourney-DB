-- =========================================================================
-- Daily article generation: every database change for the feature, in one file.
-- Design: LanJourney2.0/docs/daily-article-generation.md. Each section names its ticket.
--
-- No migration runner (ddl-auto=validate): run by hand, STAGE first, then PROD,
-- BEFORE deploying the backend from the article-generation branch (the backend
-- fails to start if a column it expects is missing). Every statement is safe to
-- re-run, so running the whole file again after new sections are added is fine.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; every row must show ok = true.
--   PART 3 (later)    -> commented out; run only when its note says so.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

-- -------------------------------------------------------------------------
-- P3: user_meaning.source_article_id -- the article that taught the meaning.
-- Nullable; NULL for onboarding/quiz/manual rows and for rows taught before
-- this column existed (no backfill). ON DELETE SET NULL so deleting an
-- article never deletes a reader's progress.
-- -------------------------------------------------------------------------
ALTER TABLE user_meaning
  ADD COLUMN IF NOT EXISTS source_article_id UUID REFERENCES article (id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_user_meaning_source_article_id
  ON user_meaning (source_article_id);

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). Every row must show ok = true.
-- =========================================================================
SELECT check_name, ok FROM (
  -- P3
  SELECT 'P3 user_meaning.source_article_id column is uuid' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'user_meaning' AND column_name = 'source_article_id'
                    AND data_type = 'uuid' AND is_nullable = 'YES') AS ok
  UNION ALL
  SELECT 'P3 source_article_id references article with ON DELETE SET NULL',
         EXISTS (SELECT 1 FROM pg_constraint c
                  WHERE c.conrelid = 'user_meaning'::regclass AND c.contype = 'f'
                    AND c.confrelid = 'article'::regclass AND c.confdeltype = 'n')
  UNION ALL
  SELECT 'P3 index idx_user_meaning_source_article_id exists',
         EXISTS (SELECT 1 FROM pg_indexes
                  WHERE tablename = 'user_meaning'
                    AND indexname = 'idx_user_meaning_source_article_id')
) checks;


-- =========================================================================
-- PART 3: later steps (commented out on purpose)
-- =========================================================================
-- (none yet)
