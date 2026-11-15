-- =========================================================================
-- article_term: the names, titles and hard words in a saved article, with a short plain note.
-- Design: LanJourney2.0/docs/trend-page.md ("Reading a Trend article").
--
-- There is NO staging environment: run this by hand on PROD, BEFORE deploying the backend that
-- reads and writes it (ddl-auto=validate fails on a missing table). It only ADDS one table and an
-- index, and every statement is safe to re-run. No backup needed (nothing existing is changed).
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; the single row must show migration_ok = true.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

-- One row per name, title or term that appears in a saved article ("L3Harris", NAME,
-- "US defence and technology company"). The sidebar lists them apart from the words to learn.
CREATE TABLE IF NOT EXISTS article_term (
  id         BIGSERIAL PRIMARY KEY,
  article_id UUID NOT NULL REFERENCES article (id) ON DELETE CASCADE,
  term       TEXT NOT NULL,                       -- as written in the article
  kind       TEXT NOT NULL CHECK (kind IN ('NAME', 'TITLE', 'TERM')),
  note       TEXT,                                -- a few plain words; may be empty
  position   INT NOT NULL DEFAULT 0               -- order of first appearance
);

CREATE INDEX IF NOT EXISTS idx_article_term_article ON article_term (article_id, position);

-- Supabase exposes every public table over its REST API; no policies means no access for the
-- anon/authenticated roles. The backend connects as 'postgres', which bypasses RLS.
ALTER TABLE article_term ENABLE ROW LEVEL SECURITY;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). migration_ok must be true and checks_run 4.
-- =========================================================================
SELECT bool_and(ok) AS migration_ok,
       count(*)     AS checks_run,
       string_agg(check_name, '; ') FILTER (WHERE NOT ok) AS failed_checks
FROM (
  SELECT 'table article_term exists' AS check_name,
         to_regclass('article_term') IS NOT NULL AS ok
  UNION ALL
  SELECT 'kind check allows NAME, TITLE and TERM',
         COALESCE((SELECT pg_get_constraintdef(oid) LIKE '%NAME%'
                          AND pg_get_constraintdef(oid) LIKE '%TITLE%'
                          AND pg_get_constraintdef(oid) LIKE '%TERM%'
                   FROM pg_constraint
                   WHERE conrelid = to_regclass('article_term') AND contype = 'c'), FALSE)
  UNION ALL
  SELECT 'deleting an article deletes its terms (cascade)',
         EXISTS (SELECT 1 FROM pg_constraint
                 WHERE conrelid = to_regclass('article_term') AND contype = 'f'
                   AND confdeltype = 'c')
  UNION ALL
  SELECT 'row level security is on',
         COALESCE((SELECT relrowsecurity FROM pg_class
                   WHERE oid = to_regclass('article_term')), FALSE)
) checks;


-- =========================================================================
-- Rollback (only if the backend change is rolled back too):
--   DROP TABLE IF EXISTS article_term;
-- =========================================================================


-- =========================================================================
-- PART 3 (OPTIONAL, owner's choice): tidy the first Trend article's "new meanings".
-- The flight article of 2026-11-15 (article 0ad14a9a-a1dc-167a-81a1-dce8178e001e) gave its reader 26 new
-- meanings of words they already knew. 15 of them are among the 1,000 most common words (say, need, about,
-- give, ...), which the new rewrite never teaches. This marks those 15 as known (status 6, what "I know this"
-- does), so they leave the Learning list. The other 11 stay to be learned or dismissed by hand.
-- To run it: remove the leading "-- " from the four lines below. Re-running changes nothing more.
-- =========================================================================
-- UPDATE user_meaning um SET status = 6
-- FROM meaning m JOIN vocabulary v ON v.id = m.vocab_id
-- WHERE um.meaning_id = m.id AND um.source_article_id = '0ad14a9a-a1dc-167a-81a1-dce8178e001e'
--   AND um.status = 0 AND v.frequency_rank <= 1000;
-- Check (read-only): rows of that article still at status 0 (11 expected after the update, 26 before).
-- SELECT count(*) FROM user_meaning WHERE source_article_id = '0ad14a9a-a1dc-167a-81a1-dce8178e001e' AND status = 0;
