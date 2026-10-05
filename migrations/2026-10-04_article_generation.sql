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
--   PART 2 (verify)   -> run it after PART 1; every row must show ok = true, except rows
--                        marked "(true only after PART 3)".
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

-- -------------------------------------------------------------------------
-- P4: user_meaning.source 'ARTICLE' becomes 'REWRITE' (pasted article) and
-- 'GENERATED' (generated article). The CHECK still allows 'ARTICLE' until
-- PART 3, because the backend running now writes it until the new one is
-- deployed. The constraint was named chk_user_meaning_source by the
-- 2026-10-03 migration but user_meaning_source_check in databases built from
-- schema.sql, so both names are dropped. Skipped when already done, so a
-- re-run never loosens the final constraint from PART 3.
-- -------------------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint
              WHERE conrelid = 'user_meaning'::regclass
                AND conname = 'chk_user_meaning_source'
                AND pg_get_constraintdef(oid) LIKE '%GENERATED%') THEN
    RETURN;
  END IF;
  ALTER TABLE user_meaning DROP CONSTRAINT IF EXISTS chk_user_meaning_source;
  ALTER TABLE user_meaning DROP CONSTRAINT IF EXISTS user_meaning_source_check;
  ALTER TABLE user_meaning ADD CONSTRAINT chk_user_meaning_source
    CHECK (source IN ('ONBOARDING', 'ARTICLE', 'REWRITE', 'GENERATED', 'QUIZ', 'MANUAL', 'UNKNOWN'));
END $$;

UPDATE user_meaning SET source = 'REWRITE' WHERE source = 'ARTICLE';

-- A leftover default from the 2026-10-03 migration would write the retired 'ARTICLE'.
ALTER TABLE user_meaning ALTER COLUMN source DROP DEFAULT;

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
  -- P4
  UNION ALL
  SELECT 'P4 source CHECK allows REWRITE and GENERATED',
         EXISTS (SELECT 1 FROM pg_constraint
                  WHERE conrelid = 'user_meaning'::regclass
                    AND conname = 'chk_user_meaning_source'
                    AND pg_get_constraintdef(oid) LIKE '%''REWRITE''%'
                    AND pg_get_constraintdef(oid) LIKE '%''GENERATED''%')
  UNION ALL
  SELECT 'P4 only one CHECK on source (old auto-named one gone)',
         NOT EXISTS (SELECT 1 FROM pg_constraint
                      WHERE conrelid = 'user_meaning'::regclass
                        AND conname = 'user_meaning_source_check')
  UNION ALL
  SELECT 'P4 no user_meaning rows left with source ARTICLE',
         NOT EXISTS (SELECT 1 FROM user_meaning WHERE source = 'ARTICLE')
  UNION ALL
  SELECT 'P4 source has no default',
         (SELECT column_default IS NULL FROM information_schema.columns
           WHERE table_name = 'user_meaning' AND column_name = 'source')
  UNION ALL
  SELECT 'P4 (true only after PART 3) CHECK no longer allows ARTICLE',
         NOT EXISTS (SELECT 1 FROM pg_constraint
                      WHERE conrelid = 'user_meaning'::regclass
                        AND conname = 'chk_user_meaning_source'
                        AND pg_get_constraintdef(oid) LIKE '%''ARTICLE''%')
) checks;


-- =========================================================================
-- PART 3: later steps (commented out on purpose)
-- =========================================================================
-- P4 final step. Run RIGHT AFTER the article-generation backend is live (the
-- old backend writes 'ARTICLE'; the new one cannot read that value, so rows the
-- old one wrote between PART 1 and the deploy must be converted promptly).
--
-- BEGIN;
-- UPDATE user_meaning SET source = 'REWRITE' WHERE source = 'ARTICLE';
-- ALTER TABLE user_meaning DROP CONSTRAINT IF EXISTS chk_user_meaning_source;
-- ALTER TABLE user_meaning ADD CONSTRAINT chk_user_meaning_source
--   CHECK (source IN ('ONBOARDING', 'REWRITE', 'GENERATED', 'QUIZ', 'MANUAL', 'UNKNOWN'));
-- COMMIT;
