-- ====================================================================================================
-- Hand-run schema migrations from 2026-08-30 to 2026-10-03 (merged into one file on 2026-10-22).
--
-- RECORD ONLY. Every change below is already applied on stage and prod and is already part of schema.sql.
-- Do not run this file on a database built from schema.sql. It exists so an old database can be compared or rebuilt.
-- Each section keeps its original text, including its own notes on how it was run.
--
-- Contents, in the order they were applied:
--   1. 2026-08-30_add_meaning_wordnet_sense_id.sql
--   2. 2026-08-31_add_meaning_vocab_wordnet_sense_unique.sql
--   3. 2026-09-24_add_quiz_tables.sql
--   4. 2026-10-03_add_user_meaning_source.sql
-- ====================================================================================================


-- ####################################################################################################
-- ## FILE: 2026-08-30_add_meaning_wordnet_sense_id.sql
-- ####################################################################################################

-- =========================================================================
-- Rewrite Pipeline V3 (Part A): bridge column for local WordNet sense
-- resolution. meaning.sense_key is AI-generated free text (see
-- MeaningService.normalizeSenseKey) — it has no relationship to WordNet's
-- own sense identifiers, which is what extjwnl-based local Lesk resolution
-- produces. This column lets Step 2 check "does the reader already know
-- this (vocab, WordNet sense)" without going through the AI's namespace.
--
-- This project has no migration runner (spring.jpa.hibernate.ddl-auto=
-- validate everywhere). Run this by hand in the Supabase SQL Editor —
-- staging first, then prod — after schema.sql/reset.sql have been reviewed
-- with the same change. Safe to re-run (every statement is idempotent).
-- =========================================================================

ALTER TABLE meaning ADD COLUMN IF NOT EXISTS wordnet_sense_id TEXT;

ALTER TABLE meaning DROP CONSTRAINT IF EXISTS chk_wordnet_sense_id_format;
ALTER TABLE meaning ADD CONSTRAINT chk_wordnet_sense_id_format
  CHECK (wordnet_sense_id IS NULL OR wordnet_sense_id ~ '^[nvasr]#[0-9]+$');

CREATE INDEX IF NOT EXISTS idx_meaning_vocab_wordnet_sense
  ON meaning (vocab_id, wordnet_sense_id) WHERE wordnet_sense_id IS NOT NULL;


-- ####################################################################################################
-- ## FILE: 2026-08-31_add_meaning_vocab_wordnet_sense_unique.sql
-- ####################################################################################################

-- =========================================================================
-- Rewrite Pipeline V3 (Part B): close a race-condition gap Part A's own
-- migration left open. idx_meaning_vocab_wordnet_sense (added in
-- 2026-08-30_add_meaning_wordnet_sense_id.sql) is a plain index, not a
-- unique one. Step 3 generates a fresh AI senseKey per request, so two
-- concurrent first-time resolutions of the same (vocab, wordnet_sense_id)
-- can each get a different AI senseKey, both pass the existing
-- uq_meaning_vocab_sense (vocab_id, sense_key) constraint, and silently
-- create two Meaning rows for the same underlying WordNet sense.
--
-- This project has no migration runner (spring.jpa.hibernate.ddl-auto=
-- validate everywhere). Run this by hand in the Supabase SQL Editor —
-- staging first, then prod — after schema.sql/reset.sql have been reviewed
-- with the same change. Safe to re-run.
-- =========================================================================

DROP INDEX IF EXISTS idx_meaning_vocab_wordnet_sense;

CREATE UNIQUE INDEX IF NOT EXISTS uq_meaning_vocab_wordnet_sense
  ON meaning (vocab_id, wordnet_sense_id) WHERE wordnet_sense_id IS NOT NULL;


-- ####################################################################################################
-- ## FILE: 2026-09-24_add_quiz_tables.sql
-- ####################################################################################################

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


-- ####################################################################################################
-- ## FILE: 2026-10-03_add_user_meaning_source.sql
-- ####################################################################################################

-- =========================================================================
-- Provenance for user_meaning: how each row was CREATED. Written once at
-- insert and never updated (status changes, reviews and resets are logged in
-- meaning_review instead). Values: ONBOARDING (bulk-seeded from the onboarding
-- quiz), ARTICLE (taught by a rewrite), QUIZ (first met in a daily quiz),
-- MANUAL (reserved), UNKNOWN (backfill rows that couldn't be classified).
--
-- No migration runner (ddl-auto=validate): run by hand, stage first, then
-- prod, BEFORE deploying the backend that writes the column. Safe to re-run.
--
-- Part 1 (this file, run now): add the column with a temporary default so the
--   old backend keeps inserting, then backfill existing rows.
-- Part 2 (see the bottom, run only AFTER the new backend is live): drop the
--   default so every creator must choose a source explicitly.
-- =========================================================================

BEGIN;

-- 1) Column. Existing rows get 'ARTICLE' for now; step 2 corrects them.
ALTER TABLE user_meaning
  ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'ARTICLE';

ALTER TABLE user_meaning DROP CONSTRAINT IF EXISTS chk_user_meaning_source;
ALTER TABLE user_meaning
  ADD CONSTRAINT chk_user_meaning_source
  CHECK (source IN ('ONBOARDING', 'ARTICLE', 'QUIZ', 'MANUAL', 'UNKNOWN'));

-- 2) Backfill. The onboarding seed inserts thousands of rows in one statement, so they
--    share an exact first_seen_at; rewrite-taught rows arrive in small batches with
--    different timestamps. This doesn't depend on the current status, so seeded rows the
--    reader has since reviewed are still recognised.
UPDATE user_meaning um
   SET source = 'ONBOARDING'
  FROM (SELECT user_id, first_seen_at
          FROM user_meaning
         GROUP BY user_id, first_seen_at
        HAVING COUNT(*) > 200) bulk
 WHERE um.user_id = bulk.user_id
   AND um.first_seen_at = bulk.first_seen_at;

COMMIT;

-- Part 2 -- run LATER, once the backend that writes `source` is deployed:
-- ALTER TABLE user_meaning ALTER COLUMN source DROP DEFAULT;
