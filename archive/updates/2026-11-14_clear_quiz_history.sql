-- =========================================================================
-- Clear all quiz history (one-time, decided 2026-11-14: every current user is a test user, and
-- the quiz is being reworked, so everyone starts the quizzes fresh).
--
-- DELETES, for ALL users: every Quick Test and Conversation session, with its questions
-- (quiz_item), conversation messages (conversation_message) and conversation targets
-- (conversation_target). They go through ON DELETE CASCADE from quiz_session. THIS CANNOT BE
-- UNDONE: take a backup first (Supabase: Database > Backups, or pg_dump).
--
-- What it shows afterwards: the "Recent practice" list on the Quiz page is empty and the quiz
-- streak is 0, because both are read from quiz_session.
--
-- What it does NOT touch (on purpose):
--   * word levels (user_meaning.status, last_reviewed_at): words stay at the level the quizzes
--     gave them. To also reset those, say so; it is a separate, bigger decision.
--   * meaning_review (the review log, also used for the reading-gate counts).
--   * the onboarding placement quiz result and the seeded word list.
--
-- No migration runner: run by hand on PROD. Safe to re-run (a second run deletes nothing).
--
-- How to run:
--   PART 0 (preview)  -> run first, read the counts, check they are what you expect.
--   PART 1 (delete)   -> run it all.
--   PART 2 (verify)   -> run it after PART 1; every row must show ok = true.
-- =========================================================================


-- =========================================================================
-- PART 0: preview (read-only): what PART 1 will delete
-- =========================================================================
SELECT
  (SELECT COUNT(*) FROM quiz_session)                                  AS sessions,
  (SELECT COUNT(*) FROM quiz_session WHERE mode = 'QUICK')             AS quick_tests,
  (SELECT COUNT(*) FROM quiz_session WHERE mode = 'CONVERSATION')      AS conversations,
  (SELECT COUNT(*) FROM quiz_item)                                     AS quiz_items,
  (SELECT COUNT(*) FROM conversation_message)                          AS conversation_messages,
  (SELECT COUNT(*) FROM conversation_target)                           AS conversation_targets,
  (SELECT COUNT(DISTINCT user_id) FROM quiz_session)                   AS users_affected,
  (SELECT COUNT(*) FROM app_user)                                      AS users_total;


-- =========================================================================
-- PART 1: delete
-- =========================================================================
BEGIN;

DELETE FROM quiz_session;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). Every row must show ok = true.
-- =========================================================================
SELECT check_name, ok FROM (
  SELECT 'no quiz sessions are left' AS check_name,
         NOT EXISTS (SELECT 1 FROM quiz_session) AS ok
  UNION ALL
  SELECT 'no quiz questions are left', NOT EXISTS (SELECT 1 FROM quiz_item)
  UNION ALL
  SELECT 'no conversation messages are left', NOT EXISTS (SELECT 1 FROM conversation_message)
  UNION ALL
  SELECT 'no conversation targets are left', NOT EXISTS (SELECT 1 FROM conversation_target)
  UNION ALL
  SELECT 'users and their word levels were not touched (users still exist)',
         EXISTS (SELECT 1 FROM app_user)
) checks;
