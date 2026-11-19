-- =========================================================================
-- Short forms ("CEO", "AI", "GDP") in articles, and the reader's "Got it" on them.
-- Design: LanJourney2.0/docs/rewrite-pipeline.md ("Names, titles, terms and short forms").
--
-- 1. article_term.kind may now be SHORT_FORM: a short form of ordinary words, whose note starts
--    with the full form ("chief executive officer: the top boss of a company").
-- 2. reader_known_term: the short forms a reader marked "Got it"; later articles show them as
--    plain text. Not a word list: never quizzed.
--
-- No staging: run this by hand on PROD, BEFORE deploying the backend that reads the new table
-- (ddl-auto=validate fails on a missing table, and saving a SHORT_FORM row fails on the old check).
-- It only ADDS a table and widens one check; nothing existing is changed, so no backup is needed.
-- Every statement is safe to re-run.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; the single row must show migration_ok = true.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

ALTER TABLE article_term DROP CONSTRAINT IF EXISTS article_term_kind_check;
ALTER TABLE article_term
  ADD CONSTRAINT article_term_kind_check
  CHECK (kind IN ('NAME', 'TITLE', 'TERM', 'SHORT_FORM'));

-- One row per reader and short form they marked "Got it". term is lower case, without a plural
-- "s" ("ceo" for "CEOs").
CREATE TABLE IF NOT EXISTS reader_known_term (
  user_id    UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
  term       TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, term)
);

-- Supabase exposes every public table over its REST API; no policies means no access for the
-- anon/authenticated roles. The backend connects as 'postgres', which bypasses RLS.
ALTER TABLE reader_known_term ENABLE ROW LEVEL SECURITY;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). migration_ok must be true and checks_run 4.
-- =========================================================================
SELECT bool_and(ok) AS migration_ok,
       count(*)     AS checks_run,
       string_agg(check_name, '; ') FILTER (WHERE NOT ok) AS failed_checks
FROM (
  SELECT 'article_term kind check allows SHORT_FORM' AS check_name,
         COALESCE((SELECT pg_get_constraintdef(oid) LIKE '%SHORT_FORM%'
                   FROM pg_constraint
                   WHERE conname = 'article_term_kind_check'), FALSE) AS ok
  UNION ALL
  SELECT 'table reader_known_term exists',
         to_regclass('reader_known_term') IS NOT NULL
  UNION ALL
  SELECT 'reader_known_term has user_id, term, created_at',
         (SELECT count(*) FROM information_schema.columns
          WHERE table_name = 'reader_known_term'
            AND column_name IN ('user_id', 'term', 'created_at')) = 3
  UNION ALL
  SELECT 'row level security is on',
         COALESCE((SELECT relrowsecurity FROM pg_class
                   WHERE oid = to_regclass('reader_known_term')), FALSE)
) checks;


-- =========================================================================
-- Rollback (only if the backend change is rolled back too, and no SHORT_FORM rows were saved):
--   DROP TABLE IF EXISTS reader_known_term;
--   ALTER TABLE article_term DROP CONSTRAINT IF EXISTS article_term_kind_check;
--   ALTER TABLE article_term ADD CONSTRAINT article_term_kind_check
--     CHECK (kind IN ('NAME', 'TITLE', 'TERM'));
-- =========================================================================
