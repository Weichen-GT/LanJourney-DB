-- =========================================================================
-- Retire the old Quick Test question pool (one-time data fix, decided 2026-11-18).
--
-- Why: pool questions are reused across readers, and every question saved before 2026-11-19
-- was written under the old generation rules. Since then the rules changed: options must test
-- the word, never a fine distinction; a verb and a noun of one idea are never offered together
-- in "Which meaning"; words inside titles and short forms are taught. Old questions that break
-- those rules would keep coming back, so all of them stop being used.
--
-- What it does: sets retired_at on every pool question (shared and reader-private) created
-- before 2026-11-19 00:00 Pacific that is not already retired. Nothing is deleted:
--   * The backend skips retired questions (QuizQuestionRepository.findUsable: retired_at IS NULL)
--     and writes fresh ones with the AI under the current rules, so the next few Quick Tests
--     make more AI calls than usual until the pool fills up again.
--   * Tests already started keep working: quiz_item holds its own copy of the sentence and options.
--   * To undo: UPDATE quiz_question SET retired_at = NULL WHERE retired_at = <the time it ran>;
--
-- Run it AFTER the backend with the new rules is live on Railway (backend main at 2eec653 or
-- later), so no old-rule questions are written after it runs.
--
-- No migration runner: run by hand on PROD. Safe to re-run (a second run changes nothing,
-- except questions written later on 2026-11-18, which it also retires -- harmless).
--
-- How to run:
--   PART 0 (preview)  -> run first, read the counts.
--   PART 1 (retire)   -> run it all.
--   PART 2 (verify)   -> run it after PART 1; every row must show ok = true.
-- =========================================================================


-- =========================================================================
-- PART 0: preview (read-only): what PART 1 will retire
-- =========================================================================
SELECT
  COUNT(*)                                                                  AS pool_total,
  COUNT(*) FILTER (WHERE retired_at IS NULL)                                AS active_now,
  COUNT(*) FILTER (WHERE retired_at IS NULL
                     AND created_at < TIMESTAMPTZ '2026-11-19 00:00:00-08') AS will_retire,
  COUNT(*) FILTER (WHERE retired_at IS NULL
                     AND created_at < TIMESTAMPTZ '2026-11-19 00:00:00-08'
                     AND owner_user_id IS NULL)                             AS will_retire_shared,
  COUNT(*) FILTER (WHERE retired_at IS NULL
                     AND created_at < TIMESTAMPTZ '2026-11-19 00:00:00-08'
                     AND owner_user_id IS NOT NULL)                         AS will_retire_private
FROM quiz_question;


-- =========================================================================
-- PART 1: retire
-- =========================================================================
BEGIN;

UPDATE quiz_question
   SET retired_at = NOW()
 WHERE retired_at IS NULL
   AND created_at < TIMESTAMPTZ '2026-11-19 00:00:00-08';

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). Every row must show ok = true.
-- =========================================================================
SELECT check_name, ok FROM (
  SELECT 'no question saved before 2026-11-19 is still in use' AS check_name,
         NOT EXISTS (SELECT 1 FROM quiz_question
                      WHERE retired_at IS NULL
                        AND created_at < TIMESTAMPTZ '2026-11-19 00:00:00-08') AS ok
  UNION ALL
  SELECT 'questions written from 2026-11-19 on were not touched',
         NOT EXISTS (SELECT 1 FROM quiz_question
                      WHERE retired_at IS NOT NULL
                        AND created_at >= TIMESTAMPTZ '2026-11-19 00:00:00-08')
) checks;
