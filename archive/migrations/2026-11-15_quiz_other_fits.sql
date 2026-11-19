-- =========================================================================
-- Quick Test: accept the other words that fit the blank. Every database change for the feature,
-- in one file. Design: LanJourney2.0/docs/quiz-design.md ("Other words that fit").
--
-- When the AI writes a typed question it also lists other words that would fit the blank (the
-- vague-sentence check). A reader who types one of them knows a good word, so it now counts as
-- right (level unchanged, with a "that fits too, but we were looking for X" note). The list is
-- saved with the question; this file adds the column for it.
--
-- No migration runner (ddl-auto=validate): run by hand on PROD (no staging since 2026-10-23),
-- BEFORE deploying the backend that reads the column (the backend fails to start if a column it
-- expects is missing). Old questions keep NULL, which just means "no alternatives accepted".
-- The statement is safe to re-run.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; every row must show ok = true.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

-- -------------------------------------------------------------------------
-- quiz_item.other_fits -- TYPED questions only: a JSON array of lowercase words, e.g.
-- ["declare","reveal"]. NULL for other types, for questions written before this feature, and
-- when the AI listed none.
-- -------------------------------------------------------------------------
ALTER TABLE quiz_item
  ADD COLUMN IF NOT EXISTS other_fits TEXT;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). Every row must show ok = true.
-- =========================================================================
SELECT check_name, ok FROM (
  SELECT 'quiz_item.other_fits exists as nullable text' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'quiz_item' AND column_name = 'other_fits'
                    AND data_type = 'text' AND is_nullable = 'YES') AS ok
  UNION ALL
  SELECT 'the earlier extended_sentence column is still there',
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'quiz_item' AND column_name = 'extended_sentence')
) checks;
