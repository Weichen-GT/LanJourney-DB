-- =========================================================================
-- article_new_word: a log of the words readers paste that are outside our ranked word list.
-- Design: LanJourney2.0/docs/rewrite-pipeline.md ("Words outside the ranked list").
--
-- There is NO staging environment (decided 2026-10-23): run this by hand on PROD, BEFORE deploying
-- the backend that writes to it (ddl-auto=validate fails on a missing table). The change only
-- ADDS one table and its indexes, and every statement is safe to re-run, so running the whole
-- file twice is fine. No backup needed (nothing existing is changed).
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; the single row must show migration_ok = true.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

-- One row per (pasted article, word) where the word's vocabulary row has no frequency_rank, i.e. it
-- is not in the ~11k ranked list. The row says what the rewrite did with it, so the weekly review
-- can count how many such words readers bring, which ones come up again and again, and which
-- ones were taught with only an AI-written definition.
CREATE TABLE IF NOT EXISTS article_new_word (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
  article_id UUID REFERENCES article (id) ON DELETE SET NULL,
  vocab_id   BIGINT NOT NULL REFERENCES vocabulary (id) ON DELETE CASCADE,
  meaning_id BIGINT REFERENCES meaning (id) ON DELETE SET NULL,   -- set when the word was taught
  outcome    TEXT NOT NULL CHECK (outcome IN ('TAUGHT', 'REWRITTEN', 'NO_WORDNET_ENTRY', 'LEFT')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (article_id, vocab_id)
);

-- "how many times has this word come up" and "what did this reader bring"
CREATE INDEX IF NOT EXISTS idx_article_new_word_vocab ON article_new_word (vocab_id);
CREATE INDEX IF NOT EXISTS idx_article_new_word_user ON article_new_word (user_id, created_at DESC);

-- Supabase exposes every public table over its REST API; no policies means no access for the
-- anon/authenticated roles. The backend connects as 'postgres', which bypasses RLS.
ALTER TABLE article_new_word ENABLE ROW LEVEL SECURITY;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). migration_ok must be true and checks_run 4.
-- =========================================================================
SELECT bool_and(ok) AS migration_ok,
       count(*)     AS checks_run,
       string_agg(check_name, '; ') FILTER (WHERE NOT ok) AS failed_checks
FROM (
  SELECT 'table article_new_word exists' AS check_name,
         to_regclass('article_new_word') IS NOT NULL AS ok
  UNION ALL
  SELECT 'outcome check allows the four values',
         COALESCE((SELECT pg_get_constraintdef(oid) LIKE '%TAUGHT%'
                          AND pg_get_constraintdef(oid) LIKE '%REWRITTEN%'
                          AND pg_get_constraintdef(oid) LIKE '%NO_WORDNET_ENTRY%'
                          AND pg_get_constraintdef(oid) LIKE '%LEFT%'
                   FROM pg_constraint
                   WHERE conrelid = to_regclass('article_new_word') AND contype = 'c'), FALSE)
  UNION ALL
  SELECT 'one row per article and word (unique)',
         EXISTS (SELECT 1 FROM pg_constraint
                 WHERE conrelid = to_regclass('article_new_word') AND contype = 'u')
  UNION ALL
  SELECT 'row level security is on',
         COALESCE((SELECT relrowsecurity FROM pg_class
                   WHERE oid = to_regclass('article_new_word')), FALSE)
) checks;
