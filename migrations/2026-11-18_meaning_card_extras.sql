-- =========================================================================
-- Word card extras: a second example sentence and common phrases for each meaning.
--
-- The word cards beside an article now show, under the meaning's example, a second example and
-- the common phrases that use this meaning ("defense mechanism"). The AI writes them the first
-- time a card shows the meaning; they are saved on the meaning row, so every reader shares them
-- and each meaning costs one AI answer, once.
--
--   second_example    another example sentence, different from example_sentence
--   phrases           JSONB list of strings; [] when the meaning has no common phrase
--   extras_filled_at  when the AI wrote them; NULL = not asked yet
--
-- No staging: run this by hand on PROD, BEFORE deploying the backend that reads the new columns
-- (ddl-auto=validate fails on a missing column). It only ADDS three nullable columns; nothing
-- existing is changed, so no backup is needed. Every statement is safe to re-run.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; the single row must show migration_ok = true.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

ALTER TABLE meaning ADD COLUMN IF NOT EXISTS second_example TEXT;
ALTER TABLE meaning ADD COLUMN IF NOT EXISTS phrases JSONB;
ALTER TABLE meaning ADD COLUMN IF NOT EXISTS extras_filled_at TIMESTAMPTZ;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). migration_ok must be true and checks_run 4.
-- =========================================================================
SELECT bool_and(ok) AS migration_ok,
       count(*)     AS checks_run,
       string_agg(check_name, '; ') FILTER (WHERE NOT ok) AS failed_checks
FROM (
  SELECT 'meaning.second_example is text' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'meaning' AND column_name = 'second_example'
                   AND data_type = 'text') AS ok
  UNION ALL
  SELECT 'meaning.phrases is jsonb',
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'meaning' AND column_name = 'phrases'
                   AND data_type = 'jsonb')
  UNION ALL
  SELECT 'meaning.extras_filled_at is timestamptz',
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'meaning' AND column_name = 'extras_filled_at'
                   AND data_type = 'timestamp with time zone')
  UNION ALL
  SELECT 'no meaning has extras yet (fresh columns)',
         NOT EXISTS (SELECT 1 FROM meaning WHERE extras_filled_at IS NOT NULL)
) checks;
