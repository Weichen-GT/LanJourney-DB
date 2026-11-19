-- =============================================================
-- 2026-11-18: turn on row level security for quiz_question (prod only; schema.sql already has it).
--
-- Why: migrations/2026-11-17_quiz_question_pool.sql created quiz_question but, unlike schema.sql, did not
-- enable RLS. Supabase exposes every public table through its REST API to the anon/authenticated roles;
-- RLS with no policies closes that path. The backend connects as postgres, which bypasses RLS, so the
-- app is not affected. Found while checking that schema.sql equals all migrations together.
--
-- Run once on prod (SQL editor or psql). Safe to re-run. Then run the verify query: expect t.
-- =============================================================

ALTER TABLE quiz_question ENABLE ROW LEVEL SECURITY;

-- VERIFY (expect one row, ok = t)
SELECT 'quiz_question has row level security on' AS check_name,
       relrowsecurity AS ok
FROM pg_class
WHERE oid = 'public.quiz_question'::regclass;
