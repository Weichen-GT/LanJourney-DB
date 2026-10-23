-- =========================================================================
-- Conversation quiz safety: one new column, in one file.
-- Design: LanJourney2.0/docs/conversation-quiz-safety.md (ticket S4).
--
-- There is NO staging environment (decided 2026-10-23): run this by hand on PROD, BEFORE deploying
-- the backend that has the safety changes (ddl-auto=validate fails on a missing column). Take a
-- backup first if you like; the change only ADDS a nullable column and an index, and every
-- statement is safe to re-run, so running the whole file twice is fine.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; the single row must show migration_ok = true.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

-- conversation_message.flag: why a learner message was a safety event (off topic, an attempt to
-- instruct the assistant, a moderation hit, self-harm text). NULL on a normal message. Kept after
-- the text is erased (30 days), so repeated abuse stays visible to the strike rules.
ALTER TABLE conversation_message ADD COLUMN IF NOT EXISTS flag TEXT;

ALTER TABLE conversation_message DROP CONSTRAINT IF EXISTS conversation_message_flag_check;
ALTER TABLE conversation_message
  ADD CONSTRAINT conversation_message_flag_check
  CHECK (flag IS NULL OR flag IN ('OFF_TOPIC', 'INJECTION', 'MODERATION', 'SELF_HARM'));

-- The strike rules and the weekly review read only flagged messages, newest first.
CREATE INDEX IF NOT EXISTS idx_conversation_message_flag
  ON conversation_message (created_at)
  WHERE flag IS NOT NULL;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). migration_ok must be true and checks_run 3.
-- =========================================================================
SELECT bool_and(ok) AS migration_ok,
       count(*)     AS checks_run,
       string_agg(check_name, '; ') FILTER (WHERE NOT ok) AS failed_checks
FROM (
  SELECT 'conversation_message.flag exists' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'conversation_message' AND column_name = 'flag') AS ok
  UNION ALL
  SELECT 'flag check allows the four values',
         COALESCE((SELECT pg_get_constraintdef(oid) LIKE '%SELF_HARM%'
                          AND pg_get_constraintdef(oid) LIKE '%INJECTION%'
                          AND pg_get_constraintdef(oid) LIKE '%MODERATION%'
                          AND pg_get_constraintdef(oid) LIKE '%OFF_TOPIC%'
                   FROM pg_constraint WHERE conname = 'conversation_message_flag_check'), FALSE)
  UNION ALL
  SELECT 'flag index exists', to_regclass('idx_conversation_message_flag') IS NOT NULL
) checks;
