-- =========================================================================
-- Conversation quiz: every database change for the feature, in one file.
-- Design: LanJourney2.0/docs/conversation-quiz-design.md; build plan:
-- LanJourney2.0/docs/conversation-quiz-implementation.md (ticket CQ1, section 3).
--
-- No migration runner (ddl-auto=validate): run by hand, STAGE first, then PROD,
-- BEFORE deploying the backend from the conversation-quiz branch (the backend
-- fails to start if a table, column or constraint it expects is missing). Every
-- statement is safe to re-run, so running the whole file twice is fine.
--
-- How to run:
--   PART 1 (changes)  -> run it all (Supabase SQL editor or psql).
--   PART 2 (verify)   -> run it after PART 1; every row must show ok = true.
-- =========================================================================


-- =========================================================================
-- PART 1: changes
-- =========================================================================
BEGIN;

-- quiz_session: Conversation sessions. A new mode, a new status for a conversation closed before
-- the user sent anything (ABANDONED), and three columns only a Conversation uses. Quick Test
-- rows are untouched (mode 'QUICK', the new columns NULL).
ALTER TABLE quiz_session DROP CONSTRAINT IF EXISTS quiz_session_mode_check;
ALTER TABLE quiz_session
  ADD CONSTRAINT quiz_session_mode_check CHECK (mode IN ('QUICK', 'CONVERSATION'));

ALTER TABLE quiz_session DROP CONSTRAINT IF EXISTS quiz_session_status_check;
ALTER TABLE quiz_session
  ADD CONSTRAINT quiz_session_status_check
  CHECK (status IN ('IN_PROGRESS', 'COMPLETED', 'ABANDONED'));

ALTER TABLE quiz_session ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE quiz_session ADD COLUMN IF NOT EXISTS scenario TEXT;
ALTER TABLE quiz_session
  ADD COLUMN IF NOT EXISTS source_article_id UUID REFERENCES article (id) ON DELETE SET NULL;

-- meaning_review: a Conversation pass is logged with its own source.
ALTER TABLE meaning_review DROP CONSTRAINT IF EXISTS meaning_review_source_check;
ALTER TABLE meaning_review
  ADD CONSTRAINT meaning_review_source_check CHECK (
    source IN ('ARTICLE', 'QUICK_TEST', 'ARTICLE_REVIEW', 'DAILY_QUIZ', 'REVIEW', 'MANUAL', 'CONVERSATION')
  );

-- conversation_message: every message. The text and the grader's answer (which quotes the user)
-- are set to NULL after 30 days by the backend; the verdict and the scores stay for analysis.
CREATE TABLE
  IF NOT EXISTS conversation_message (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES quiz_session (id) ON DELETE CASCADE,
    turn INT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('USER', 'AI')),
    text TEXT,
    target_meaning_id BIGINT REFERENCES meaning (id) ON DELETE SET NULL,
    verdict TEXT CHECK (verdict IN ('NOT_USED', 'WRONG_SENSE', 'THIN', 'ALMOST', 'PASS')),
    score INT,
    use_score SMALLINT,
    sense_score SMALLINT,
    form_score SMALLINT,
    context_score SMALLINT,
    partner_action TEXT CHECK (partner_action IN ('IMPROVE', 'RE_ASK_NAME_IT', 'RE_ASK_REPHRASE', 'REVEAL_WORD', 'REDIRECT_WRONG_SENSE', 'NEXT_TARGET', 'STEER_BACK', 'WRAP_UP')),
    improve_angle TEXT,
    grader_json TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (session_id, turn)
  );

-- conversation_target: one word meaning tested in a conversation, and how it went.
CREATE TABLE
  IF NOT EXISTS conversation_target (
    session_id UUID NOT NULL REFERENCES quiz_session (id) ON DELETE CASCADE,
    meaning_id BIGINT NOT NULL REFERENCES meaning (id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    position INT NOT NULL,
    guiding_question TEXT,
    re_ask TEXT,
    state TEXT NOT NULL DEFAULT 'PENDING' CHECK (state IN ('PENDING', 'ACTIVE', 'PASS', 'FAIL', 'NOT_ATTEMPTED')),
    messages_used INT NOT NULL DEFAULT 0,
    word_used BOOLEAN NOT NULL DEFAULT FALSE,
    word_revealed BOOLEAN NOT NULL DEFAULT FALSE,
    path TEXT CHECK (path IN ('A', 'B', 'C')),
    best_score INT,
    best_message_id UUID REFERENCES conversation_message (id) ON DELETE SET NULL,
    status_before INT,
    status_after INT,
    finished_at TIMESTAMPTZ,
    PRIMARY KEY (session_id, meaning_id)
  );

CREATE INDEX IF NOT EXISTS idx_conversation_target_user_meaning
  ON conversation_target (user_id, meaning_id, finished_at DESC);

ALTER TABLE conversation_message ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_target  ENABLE ROW LEVEL SECURITY;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). Every row must show ok = true.
-- =========================================================================
SELECT 'quiz_session.mode allows CONVERSATION' AS check_name,
       COALESCE((SELECT pg_get_constraintdef(oid) LIKE '%CONVERSATION%'
                 FROM pg_constraint WHERE conname = 'quiz_session_mode_check'), FALSE) AS ok
UNION ALL
SELECT 'quiz_session.status allows ABANDONED',
       COALESCE((SELECT pg_get_constraintdef(oid) LIKE '%ABANDONED%'
                 FROM pg_constraint WHERE conname = 'quiz_session_status_check'), FALSE)
UNION ALL
SELECT 'quiz_session has title, scenario, source_article_id',
       (SELECT count(*) = 3 FROM information_schema.columns
         WHERE table_name = 'quiz_session' AND column_name IN ('title', 'scenario', 'source_article_id'))
UNION ALL
SELECT 'meaning_review.source allows CONVERSATION',
       COALESCE((SELECT pg_get_constraintdef(oid) LIKE '%CONVERSATION%'
                 FROM pg_constraint WHERE conname = 'meaning_review_source_check'), FALSE)
UNION ALL
SELECT 'conversation_message exists', to_regclass('conversation_message') IS NOT NULL
UNION ALL
SELECT 'conversation_target exists', to_regclass('conversation_target') IS NOT NULL
UNION ALL
SELECT 'conversation_target index exists',
       to_regclass('idx_conversation_target_user_meaning') IS NOT NULL
UNION ALL
SELECT 'row level security is on for both tables',
       (SELECT count(*) = 2 FROM pg_class
         WHERE relname IN ('conversation_message', 'conversation_target') AND relrowsecurity)
UNION ALL
SELECT 'Quick Test sessions untouched (none has a title)',
       (SELECT count(*) = 0 FROM quiz_session WHERE mode = 'QUICK' AND title IS NOT NULL);

-- Informational (not a pass/fail): both tables are empty until the first conversation.
SELECT (SELECT count(*) FROM conversation_message) AS conversation_messages,
       (SELECT count(*) FROM conversation_target) AS conversation_targets;
