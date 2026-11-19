-- =========================================================================
-- Quick Test hints: every database change for the feature, in one file. Design:
-- LanJourney2.0/docs/quiz-design.md ("Hints on typed questions").
--
-- A typed question can now offer "More context": the same sentence with a little extra context
-- around it. The AI writes it together with the question, so it is saved with the question; this
-- file adds the column for it. Nothing else changes: the meaning hint, the hover meanings and the
-- hint scoring need no table.
--
-- No migration runner (ddl-auto=validate): run by hand on PROD (no staging since 2026-10-23),
-- BEFORE deploying the backend that reads the column (the backend fails to start if a column it
-- expects is missing). Old questions keep NULL, which just means "no more context available".
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
-- quiz_item.extended_sentence -- TYPED questions only: the question sentence with one or two short
-- sentences of context added, containing the same answer word. NULL for other types and for
-- questions written before this feature.
-- -------------------------------------------------------------------------
ALTER TABLE quiz_item
  ADD COLUMN IF NOT EXISTS extended_sentence TEXT;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). Every row must show ok = true.
-- =========================================================================
SELECT check_name, ok FROM (
  SELECT 'quiz_item.extended_sentence exists as nullable text' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'quiz_item' AND column_name = 'extended_sentence'
                    AND data_type = 'text' AND is_nullable = 'YES') AS ok
  UNION ALL
  SELECT 'no existing question was changed (every old row is still NULL)',
         NOT EXISTS (SELECT 1 FROM quiz_item
                      WHERE extended_sentence IS NOT NULL
                        AND answered_at IS NOT NULL
                        AND answered_at < TIMESTAMPTZ '2026-11-14')
) checks;
