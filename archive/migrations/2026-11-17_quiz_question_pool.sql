-- =========================================================================
-- Quick Test question pool, with the reasons shown after a wrong answer. Every database change
-- for the feature, in one file. Design: LanJourney2.0/docs/quiz-design.md ("Question pool").
--
-- Until now every Quick Test asked the AI to write all its questions, and each question lived only
-- in that test (quiz_item). Now a question the AI writes is also saved in a pool (quiz_question),
-- together with one line on why the right answer is right and one line per wrong option on why it
-- is wrong. The next reader quizzed on the same meaning gets a pool question when one fits them
-- (every word known to them, not seen by them before), so no AI call; the AI is called only for
-- the gaps. After a wrong answer the app shows the saved reasons, again with no AI call.
--
-- No migration runner (ddl-auto=validate): run by hand on PROD (no staging since 2026-10-23),
-- BEFORE deploying the backend that reads the table (the backend fails to start if a table or
-- column it expects is missing). Old questions keep question_id NULL, which just means "no
-- reasons to show". Every statement is safe to re-run.
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
-- quiz_question -- the pool: one reusable Quick Test question about one meaning.
-- owner_user_id: NULL = shared with every reader. Set = the sentence came from that reader's own
-- article, so only that reader is ever given it (a pasted article can be private).
-- -------------------------------------------------------------------------
CREATE TABLE
  IF NOT EXISTS quiz_question (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meaning_id BIGINT NOT NULL REFERENCES meaning (id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('TILES', 'TYPED', 'WHICH_MEANING')),
    owner_user_id UUID REFERENCES app_user (id) ON DELETE CASCADE,
    sentence TEXT NOT NULL,
    answer_form TEXT NOT NULL,       -- the word exactly as it appears in the sentence
    extended_sentence TEXT,          -- "More context": the sentence with a little context around it; NULL when none
    other_fits TEXT,                 -- TYPED only: JSON array of other words that also fit the blank; NULL when none
    why_right TEXT,                  -- one short line: why the right answer fits this sentence
    -- TILES / WHICH_MEANING: JSON array of {"id","why"}, every wrong option that passed the checks with the line on
    -- why it is wrong. id = the word (TILES) or the meaning id (WHICH_MEANING). NULL for TYPED.
    wrong_options TEXT,
    too_close TEXT,                  -- WHICH_MEANING only: JSON array of meaning ids too close to the right one to offer
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    retired_at TIMESTAMPTZ           -- set to stop using a bad question (nothing sets it yet)
  );

CREATE INDEX IF NOT EXISTS idx_quiz_question_meaning_type
  ON quiz_question (meaning_id, type) WHERE retired_at IS NULL;

-- -------------------------------------------------------------------------
-- quiz_item.question_id -- the pool question a test question was made from: its reasons are shown
-- after a wrong answer, and a reader is never given the same pool question twice. NULL for
-- questions written before this feature and for the rare question built without the AI.
-- -------------------------------------------------------------------------
ALTER TABLE quiz_item
  ADD COLUMN IF NOT EXISTS question_id UUID REFERENCES quiz_question (id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_quiz_item_question_id ON quiz_item (question_id);

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). Every row must show ok = true.
-- =========================================================================
SELECT check_name, ok FROM (
  SELECT 'quiz_question table exists' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.tables
                  WHERE table_name = 'quiz_question') AS ok
  UNION ALL
  SELECT 'quiz_question has all 13 columns',
         (SELECT COUNT(*) FROM information_schema.columns
           WHERE table_name = 'quiz_question'
             AND column_name IN ('id', 'meaning_id', 'type', 'owner_user_id', 'sentence',
                                 'answer_form', 'extended_sentence', 'other_fits', 'why_right',
                                 'wrong_options', 'too_close', 'created_at', 'retired_at')) = 13
  UNION ALL
  SELECT 'quiz_question meaning/type index exists',
         EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_quiz_question_meaning_type')
  UNION ALL
  SELECT 'quiz_item.question_id exists as nullable uuid',
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'quiz_item' AND column_name = 'question_id'
                    AND data_type = 'uuid' AND is_nullable = 'YES')
  UNION ALL
  SELECT 'no existing question was changed (every old row is still NULL)',
         NOT EXISTS (SELECT 1 FROM quiz_item
                      WHERE question_id IS NOT NULL
                        AND answered_at IS NOT NULL
                        AND answered_at < TIMESTAMPTZ '2026-11-17')
) checks;
