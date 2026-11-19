-- =========================================================================
-- AI cost log: every AI call the app makes gets a row in ai_call_log, tagged with the reader action that
-- caused it, so we can see which behaviors are expensive and which are cheap.
-- Report queries: tools/ai_cost_report.sql.
--
-- There is NO staging environment: run this by hand on PROD, BEFORE deploying the backend that writes
-- these columns (ddl-auto=validate fails on a missing column).
--
-- What it changes (table ai_call_log only):
--   behavior   new column: what started the call. For a request it is the HTTP method and route,
--              e.g. 'POST /api/v1/articles/rewrite/v3' (pasting an article); for a background job it is
--              'job: <name>', e.g. 'job: nightly generation'. NULL on the rows written before this change.
--   action_id  new column: one id per reader action, shared by all the calls that action made (a pasted
--              article makes several), so the cost of one action is SUM(cost_usd) GROUP BY action_id.
--   purpose    the check now also allows the calls that were not logged before: REWRITE, WORD_EXPLAIN,
--              QUIZ_BUILD, PROFANITY_CHECK, CONVERSATION_REPLY, CONVERSATION_GRADE, CONVERSATION_SCENARIO,
--              CONVERSATION_SAMPLE and OTHER (a call the code did not name).
-- Both columns may be NULL, so the backend still running until the deploy keeps working. Safe to re-run.
-- It only adds columns, an index and allowed values; nothing existing is changed or deleted, so no
-- backup is needed.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; the single row must show migration_ok = true, checks_run 5.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

ALTER TABLE ai_call_log ADD COLUMN IF NOT EXISTS behavior TEXT;
ALTER TABLE ai_call_log ADD COLUMN IF NOT EXISTS action_id UUID;

-- The report groups a time range by behavior, then by action.
CREATE INDEX IF NOT EXISTS idx_ai_call_log_behavior ON ai_call_log (behavior, created_at);

ALTER TABLE ai_call_log DROP CONSTRAINT IF EXISTS ai_call_log_purpose_check;
ALTER TABLE ai_call_log ADD CONSTRAINT ai_call_log_purpose_check CHECK (purpose IN (
  'GENERATE', 'REGENERATE', 'SENSE_CONFIRM', 'SENTENCE_REPAIR', 'JUDGE', 'SAFETY', 'INTEREST_LABEL',
  'SUBAREA_PROPOSAL', 'PROFILE_EXTRACTION', 'REWRITE_SELECT', 'SCENARIO_BANK',
  'REWRITE', 'WORD_EXPLAIN', 'QUIZ_BUILD', 'PROFANITY_CHECK', 'CONVERSATION_REPLY', 'CONVERSATION_GRADE',
  'CONVERSATION_SCENARIO', 'CONVERSATION_SAMPLE', 'OTHER'));

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). migration_ok must be true and checks_run 5.
-- =========================================================================
SELECT bool_and(ok) AS migration_ok,
       count(*)     AS checks_run,
       string_agg(check_name, '; ') FILTER (WHERE NOT ok) AS failed_checks
FROM (
  SELECT 'ai_call_log.behavior exists as text, may be NULL' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'ai_call_log' AND column_name = 'behavior'
                   AND data_type = 'text' AND is_nullable = 'YES') AS ok
  UNION ALL
  SELECT 'ai_call_log.action_id exists as uuid, may be NULL',
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'ai_call_log' AND column_name = 'action_id'
                   AND data_type = 'uuid' AND is_nullable = 'YES')
  UNION ALL
  SELECT 'idx_ai_call_log_behavior exists',
         EXISTS (SELECT 1 FROM pg_indexes
                 WHERE tablename = 'ai_call_log' AND indexname = 'idx_ai_call_log_behavior')
  UNION ALL
  SELECT 'purpose check allows the new purposes',
         COALESCE((SELECT pg_get_constraintdef(oid) LIKE '%''REWRITE''%'
                          AND pg_get_constraintdef(oid) LIKE '%WORD_EXPLAIN%'
                          AND pg_get_constraintdef(oid) LIKE '%QUIZ_BUILD%'
                          AND pg_get_constraintdef(oid) LIKE '%PROFANITY_CHECK%'
                          AND pg_get_constraintdef(oid) LIKE '%CONVERSATION_REPLY%'
                          AND pg_get_constraintdef(oid) LIKE '%CONVERSATION_GRADE%'
                          AND pg_get_constraintdef(oid) LIKE '%CONVERSATION_SCENARIO%'
                          AND pg_get_constraintdef(oid) LIKE '%CONVERSATION_SAMPLE%'
                          AND pg_get_constraintdef(oid) LIKE '%''OTHER''%'
                   FROM pg_constraint
                   WHERE conrelid = 'ai_call_log'::regclass AND conname = 'ai_call_log_purpose_check'),
                  FALSE)
  UNION ALL
  SELECT 'purpose check still allows the old purposes',
         COALESCE((SELECT pg_get_constraintdef(oid) LIKE '%SCENARIO_BANK%'
                          AND pg_get_constraintdef(oid) LIKE '%REWRITE_SELECT%'
                          AND pg_get_constraintdef(oid) LIKE '%''GENERATE''%'
                   FROM pg_constraint
                   WHERE conrelid = 'ai_call_log'::regclass AND conname = 'ai_call_log_purpose_check'),
                  FALSE)
) checks;


-- =========================================================================
-- Rollback (only if the backend change is rolled back too; the new purposes' rows must go first):
--   DELETE FROM ai_call_log WHERE purpose IN ('REWRITE', 'WORD_EXPLAIN', 'QUIZ_BUILD', 'PROFANITY_CHECK',
--     'CONVERSATION_REPLY', 'CONVERSATION_GRADE', 'CONVERSATION_SCENARIO', 'CONVERSATION_SAMPLE', 'OTHER');
--   ALTER TABLE ai_call_log DROP CONSTRAINT IF EXISTS ai_call_log_purpose_check;
--   ALTER TABLE ai_call_log ADD CONSTRAINT ai_call_log_purpose_check CHECK (purpose IN (
--     'GENERATE', 'REGENERATE', 'SENSE_CONFIRM', 'SENTENCE_REPAIR', 'JUDGE', 'SAFETY', 'INTEREST_LABEL',
--     'SUBAREA_PROPOSAL', 'PROFILE_EXTRACTION', 'REWRITE_SELECT', 'SCENARIO_BANK'));
--   DROP INDEX IF EXISTS idx_ai_call_log_behavior;
--   ALTER TABLE ai_call_log DROP COLUMN IF EXISTS action_id;
--   ALTER TABLE ai_call_log DROP COLUMN IF EXISTS behavior;
-- =========================================================================
