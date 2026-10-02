-- =========================================================================
-- Quiz (Quick Test): session and question tables; the review log
-- (meaning_review); and the sentence each taught meaning appeared in (Quick
-- Test uses it as the question sentence).
--
-- This project has no migration runner (spring.jpa.hibernate.ddl-auto=
-- validate everywhere), so the backend will NOT START until this has run.
-- Run it by hand in the Supabase SQL Editor — staging first, then prod —
-- before deploying the code that uses it. Safe to re-run (every statement is
-- idempotent).
-- =========================================================================

ALTER TABLE article_meaning ADD COLUMN IF NOT EXISTS sentence TEXT;

-- =========================
-- 13) quiz_session: one practice session (Quick Test)
-- =========================
CREATE TABLE
  IF NOT EXISTS quiz_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    -- only Quick Tests today; room for other practice types later
    mode TEXT NOT NULL CHECK (mode IN ('QUICK')),
    status TEXT NOT NULL DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'COMPLETED')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
  );

CREATE INDEX IF NOT EXISTS idx_quiz_session_user_started ON quiz_session (user_id, started_at DESC);

-- =========================
-- 14) quiz_item: one Quick Test question
-- =========================
CREATE TABLE
  IF NOT EXISTS quiz_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES quiz_session (id) ON DELETE CASCADE,
    meaning_id BIGINT NOT NULL REFERENCES meaning (id) ON DELETE CASCADE,
    item_order INT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('TILES', 'TYPED', 'WHICH_MEANING')),
    sentence TEXT NOT NULL,
    -- TILES/TYPED: the exact word form in the sentence; WHICH_MEANING: the correct meaning id
    answer TEXT NOT NULL,
    options TEXT,                    -- JSON array of {"id","label"}: the tiles (TILES) or the word's meanings (WHICH_MEANING); NULL for TYPED
    user_answer TEXT,
    result TEXT CHECK (result IN ('RIGHT', 'ALMOST', 'WRONG')),
    status_before INT,
    status_after INT,
    answered_at TIMESTAMPTZ
  );

CREATE INDEX IF NOT EXISTS idx_quiz_item_session_id ON quiz_item (session_id);



-- =========================
-- 15) meaning_review: the review log — every review of a user's meaning, and every level set by
--     hand, with the status before and after. The reading gates (4→5, 8→9) are counted from it.
-- =========================
CREATE TABLE
  IF NOT EXISTS meaning_review (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    meaning_id BIGINT NOT NULL REFERENCES meaning (id) ON DELETE CASCADE,
    source TEXT NOT NULL CHECK (
      source IN ('ARTICLE', 'QUICK_TEST', 'ARTICLE_REVIEW', 'DAILY_QUIZ', 'REVIEW', 'MANUAL')
    ),
    recognized BOOLEAN,              -- NULL for MANUAL changes (not a test of the user)
    status_before INT NOT NULL,
    status_after INT NOT NULL,
    article_id UUID REFERENCES article (id) ON DELETE SET NULL,  -- ARTICLE only
    reviewed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

CREATE INDEX IF NOT EXISTS idx_meaning_review_user_meaning
  ON meaning_review (user_id, meaning_id, reviewed_at);

ALTER TABLE quiz_session         ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_item            ENABLE ROW LEVEL SECURITY;
ALTER TABLE meaning_review       ENABLE ROW LEVEL SECURITY;
