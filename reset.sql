-- =============================================================
-- RESET: drop everything and recreate from current schema
-- Safe to run when there is no data.
-- Run this in Supabase SQL Editor.
-- =============================================================

-- -------------------------
-- Drop tables (child tables first, CASCADE handles FK deps)
-- -------------------------
DROP TABLE IF EXISTS meaning_review       CASCADE;
DROP TABLE IF EXISTS quiz_item            CASCADE;
DROP TABLE IF EXISTS quiz_session         CASCADE;
DROP TABLE IF EXISTS daily_quiz_question CASCADE;
DROP TABLE IF EXISTS daily_quiz         CASCADE;
DROP TABLE IF EXISTS pending_vocab_enrichment CASCADE;
DROP TABLE IF EXISTS article_meaning CASCADE;
DROP TABLE IF EXISTS user_vocab_level CASCADE;
DROP TABLE IF EXISTS vocab_level     CASCADE;
DROP TABLE IF EXISTS user_vocabulary CASCADE;
DROP TABLE IF EXISTS user_meaning    CASCADE;
DROP TABLE IF EXISTS user_article    CASCADE;
DROP TABLE IF EXISTS meaning         CASCADE;
DROP TABLE IF EXISTS article         CASCADE;
DROP TABLE IF EXISTS vocabulary      CASCADE;
DROP TABLE IF EXISTS pending_signup  CASCADE;
DROP TABLE IF EXISTS app_user        CASCADE;

DROP FUNCTION IF EXISTS set_updated_at();

-- =============================================================
-- Recreate from current schema
-- =============================================================

-- -------------------------
-- Trigger function
-- -------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- -------------------------
-- 1) app_user
-- -------------------------
CREATE TABLE app_user (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name          TEXT,
  email                 TEXT NOT NULL UNIQUE,
  email_verified        BOOLEAN NOT NULL DEFAULT FALSE,
  auth_provider         TEXT NOT NULL,
  auth_provider_user_id TEXT NOT NULL,
  password_hash         TEXT,
  date_of_birth         DATE,
  gender                TEXT,
  is_active             BOOLEAN NOT NULL DEFAULT TRUE,
  terms_accepted_at     TIMESTAMPTZ,
  email_verification_token TEXT,
  email_verification_token_expires_at TIMESTAMPTZ,
  password_reset_token  TEXT,
  password_reset_token_expires_at TIMESTAMPTZ,
  last_password_changed_at TIMESTAMPTZ,
  failed_login_attempts INT NOT NULL DEFAULT 0,
  locked_until          TIMESTAMPTZ,
  avatar_url            TEXT,
  locale                VARCHAR(35),
  profile_completed     BOOLEAN NOT NULL DEFAULT FALSE,
  onboarding_quiz       BOOLEAN NOT NULL DEFAULT FALSE,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at         TIMESTAMPTZ,
  CONSTRAINT uq_user_provider_identity UNIQUE (auth_provider, auth_provider_user_id)
);

CREATE OR REPLACE TRIGGER trg_app_user_updated_at
  BEFORE UPDATE ON app_user
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------
-- 1b) pending_signup
-- -------------------------
CREATE TABLE pending_signup (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email             TEXT NOT NULL UNIQUE,
  verification_code TEXT NOT NULL,
  code_expires_at   TIMESTAMPTZ NOT NULL,
  attempts          INT NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE TRIGGER trg_pending_signup_updated_at
  BEFORE UPDATE ON pending_signup
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------
-- 2) vocabulary
-- -------------------------
CREATE TABLE vocabulary (
  id              BIGSERIAL PRIMARY KEY,
  term            TEXT NOT NULL,
  frequency_rank  INT,
  is_phrase       BOOLEAN NOT NULL DEFAULT FALSE,
  is_abbreviation BOOLEAN NOT NULL DEFAULT FALSE,
  full_form       TEXT,
  irregular_forms TEXT,
  pronunciation   TEXT,
  definition_en   TEXT,
  part_of_speech  TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uq_vocabulary_term_lower ON vocabulary ((LOWER(term)));

CREATE INDEX idx_vocabulary_frequency_rank ON vocabulary (frequency_rank);

CREATE OR REPLACE TRIGGER trg_vocabulary_updated_at
  BEFORE UPDATE ON vocabulary
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------
-- 3) article
-- -------------------------
CREATE TABLE article (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title      TEXT NOT NULL,
  content    TEXT NOT NULL,
  source_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE TRIGGER trg_article_updated_at
  BEFORE UPDATE ON article
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------
-- 4) user_article
-- -------------------------
CREATE TABLE user_article (
  user_id    UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
  article_id UUID NOT NULL REFERENCES article   (id) ON DELETE CASCADE,
  saved_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, article_id)
);

CREATE INDEX idx_user_article_article_id ON user_article (article_id);

-- -------------------------
-- 5) meaning
-- -------------------------
CREATE TABLE meaning (
  id               BIGSERIAL PRIMARY KEY,
  vocab_id         BIGINT NOT NULL REFERENCES vocabulary (id) ON DELETE CASCADE,
  sense_key        TEXT NOT NULL,
  wordnet_sense_id TEXT,   -- extjwnl POS-key#offset, e.g. "n#04170037"; NULL until backfilled
  definition       TEXT NOT NULL,
  explanation_zh   TEXT,
  part_of_speech   TEXT,
  example_sentence TEXT,
  example_sentence_zh TEXT,
  rank             INT NOT NULL DEFAULT 1 CHECK (rank > 0),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_meaning_vocab_sense       UNIQUE (vocab_id, sense_key),
  CONSTRAINT chk_sense_key_format         CHECK  (sense_key ~ '^[a-z0-9_]+$'),
  CONSTRAINT chk_wordnet_sense_id_format  CHECK  (wordnet_sense_id IS NULL OR wordnet_sense_id ~ '^[nvasr]#[0-9]+$')
);

-- UNIQUE, not just indexed: prevents two concurrent first-time AI resolutions of the same
-- (vocab, wordnet_sense_id) from creating duplicate rows with different AI-generated senseKeys.
CREATE UNIQUE INDEX uq_meaning_vocab_wordnet_sense
  ON meaning (vocab_id, wordnet_sense_id) WHERE wordnet_sense_id IS NOT NULL;

-- -------------------------
-- 6) user_meaning
-- -------------------------
CREATE TABLE user_meaning (
  user_id           UUID   NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
  meaning_id        BIGINT NOT NULL REFERENCES meaning  (id) ON DELETE CASCADE,
  status            INT    NOT NULL DEFAULT 0 CHECK (status BETWEEN 0 AND 10),
  first_seen_at     TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
  learned_at        TIMESTAMPTZ,
  last_reviewed_at  TIMESTAMPTZ,
  PRIMARY KEY (user_id, meaning_id)
);

CREATE INDEX idx_user_meaning_meaning_id ON user_meaning (meaning_id);

-- -------------------------
-- 7) user_vocabulary
-- -------------------------
CREATE TABLE user_vocabulary (
  user_id          UUID   NOT NULL REFERENCES app_user  (id) ON DELETE CASCADE,
  vocab_id         BIGINT NOT NULL REFERENCES vocabulary (id) ON DELETE CASCADE,
  status            INT NOT NULL DEFAULT 0 CHECK (status BETWEEN 0 AND 10),
  times_seen        INT NOT NULL DEFAULT 0,
  review_count      INT NOT NULL DEFAULT 0,
  last_seen_at      TIMESTAMPTZ,
  last_reviewed_at  TIMESTAMPTZ,
  first_added_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, vocab_id)
);

CREATE INDEX idx_user_vocabulary_vocab_id ON user_vocabulary (vocab_id);

-- -------------------------
-- 8) article_meaning
-- -------------------------
CREATE TABLE article_meaning (
  article_id UUID   NOT NULL REFERENCES article (id) ON DELETE CASCADE,
  meaning_id BIGINT NOT NULL REFERENCES meaning  (id) ON DELETE CASCADE,
  -- the sentence where the article used this meaning (taught meanings only); Quick Test asks it
  sentence TEXT,
  PRIMARY KEY (article_id, meaning_id)
);

CREATE INDEX idx_article_meaning_meaning_id ON article_meaning (meaning_id);

-- -------------------------
-- 9) vocab_level
-- -------------------------
CREATE TABLE vocab_level (
  id        SERIAL PRIMARY KEY,
  level     INT NOT NULL CHECK (level BETWEEN 1 AND 10),
  sub_tier  TEXT CHECK (sub_tier IN ('IV', 'III', 'II', 'I')),
  name      TEXT NOT NULL UNIQUE,
  min_words INT NOT NULL,
  max_words INT,
  CONSTRAINT uq_vocab_level_sub_tier UNIQUE (level, sub_tier),
  CONSTRAINT chk_vocab_level_range CHECK (max_words IS NULL OR max_words > min_words)
);

INSERT INTO vocab_level (level, sub_tier, name, min_words, max_words) VALUES
  (1, 'IV', 'Iron IV', 1, 500),
  (1, 'III', 'Iron III', 500, 1000),
  (1, 'II', 'Iron II', 1000, 1500),
  (1, 'I', 'Iron I', 1500, 2000),
  (2, 'IV', 'Bronze IV', 2000, 2500),
  (2, 'III', 'Bronze III', 2500, 3000),
  (2, 'II', 'Bronze II', 3000, 3500),
  (2, 'I', 'Bronze I', 3500, 4000),
  (3, 'IV', 'Silver IV', 4000, 4500),
  (3, 'III', 'Silver III', 4500, 5000),
  (3, 'II', 'Silver II', 5000, 5500),
  (3, 'I', 'Silver I', 5500, 6000),
  (4, 'IV', 'Gold IV', 6000, 6500),
  (4, 'III', 'Gold III', 6500, 7000),
  (4, 'II', 'Gold II', 7000, 7500),
  (4, 'I', 'Gold I', 7500, 8000),
  (5, 'IV', 'Platinum IV', 8000, 8500),
  (5, 'III', 'Platinum III', 8500, 9000),
  (5, 'II', 'Platinum II', 9000, 9500),
  (5, 'I', 'Platinum I', 9500, 10000),
  (6, 'IV', 'Diamond IV', 10000, 10500),
  (6, 'III', 'Diamond III', 10500, 11000),
  (6, 'II', 'Diamond II', 11000, 11500),
  (6, 'I', 'Diamond I', 11500, 12000),
  (7, 'IV', 'Master IV', 12000, 12500),
  (7, 'III', 'Master III', 12500, 13000),
  (7, 'II', 'Master II', 13000, 13500),
  (7, 'I', 'Master I', 13500, 14000),
  (8, 'IV', 'Grandmaster IV', 14000, 14500),
  (8, 'III', 'Grandmaster III', 14500, 15000),
  (8, 'II', 'Grandmaster II', 15000, 15500),
  (8, 'I', 'Grandmaster I', 15500, 16000),
  (9, 'IV', 'Legend IV', 16000, 16500),
  (9, 'III', 'Legend III', 16500, 17000),
  (9, 'II', 'Legend II', 17000, 17500),
  (9, 'I', 'Legend I', 17500, 18000),
  (10, NULL, 'Mythic', 18000, NULL);

-- -------------------------
-- 10) user_vocab_level
-- -------------------------
CREATE TABLE user_vocab_level (
  user_id              UUID PRIMARY KEY REFERENCES app_user (id) ON DELETE CASCADE,
  level_id             INT NOT NULL REFERENCES vocab_level (id),
  estimated_vocabulary INT NOT NULL,
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_vocab_level_level_id ON user_vocab_level (level_id);

CREATE OR REPLACE TRIGGER trg_user_vocab_level_updated_at
  BEFORE UPDATE ON user_vocab_level
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- -------------------------
-- 11) daily_quiz
-- -------------------------
CREATE TABLE daily_quiz (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
  quiz_date    DATE NOT NULL,
  status       TEXT NOT NULL DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'COMPLETED')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  CONSTRAINT uq_daily_quiz_user_date UNIQUE (user_id, quiz_date)
);

-- -------------------------
-- 12) daily_quiz_question
-- -------------------------
CREATE TABLE daily_quiz_question (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id            UUID NOT NULL REFERENCES daily_quiz (id) ON DELETE CASCADE,
  vocab_id           BIGINT NOT NULL REFERENCES vocabulary (id) ON DELETE CASCADE,
  meaning_id         BIGINT REFERENCES meaning (id) ON DELETE CASCADE,
  familiarity_tier   TEXT NOT NULL CHECK (familiarity_tier IN ('LOW', 'HIGH', 'MASTER')),
  question_order     INT NOT NULL,
  question_text      TEXT NOT NULL,
  options            TEXT NOT NULL,
  correct_option_key TEXT NOT NULL,
  user_answer_key    TEXT,
  is_correct         BOOLEAN,
  answered_at        TIMESTAMPTZ
);

CREATE INDEX idx_daily_quiz_question_quiz_id ON daily_quiz_question (quiz_id);

-- -------------------------
-- 13) pending_vocab_enrichment (retry queue for failed AI word enrichment)
-- -------------------------
CREATE TABLE pending_vocab_enrichment (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID        NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
  article_id        UUID        REFERENCES article (id) ON DELETE SET NULL,
  term              TEXT        NOT NULL,
  status            TEXT        NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'FAILED')),
  discovered_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_attempted_at TIMESTAMPTZ
);

CREATE INDEX idx_pve_user_id    ON pending_vocab_enrichment (user_id);
CREATE INDEX idx_pve_article_id ON pending_vocab_enrichment (article_id);
CREATE INDEX idx_pve_term       ON pending_vocab_enrichment (term);

-- -------------------------
-- 14) quiz_session: one practice session (Quick Test)
-- -------------------------
CREATE TABLE quiz_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    -- only Quick Tests today; room for other practice types later
    mode TEXT NOT NULL CHECK (mode IN ('QUICK')),
    status TEXT NOT NULL DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'COMPLETED')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
  );

CREATE INDEX idx_quiz_session_user_started ON quiz_session (user_id, started_at DESC);

-- -------------------------
-- 15) quiz_item: one Quick Test question
-- -------------------------
CREATE TABLE quiz_item (
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

CREATE INDEX idx_quiz_item_session_id ON quiz_item (session_id);

-- -------------------------
-- 16) meaning_review: the review log — every review of a user's meaning, and every level set by
--     hand, with the status before and after. The reading gates (4→5, 8→9) are counted from it.
-- -------------------------
CREATE TABLE meaning_review (
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

CREATE INDEX idx_meaning_review_user_meaning
  ON meaning_review (user_id, meaning_id, reviewed_at);


-- =============================================================
-- Enable Row Level Security (RLS) on all tables
-- =============================================================
-- Supabase exposes every table through an auto-generated REST API reachable
-- from the browser with the public anon / authenticated keys. Without RLS,
-- anyone with the (public) anon key can read/write these tables.
--
-- This app's Spring Boot backend connects DIRECTLY to Postgres (JDBC,
-- role = postgres), which BYPASSES RLS, so enabling RLS does NOT affect the
-- backend. With RLS enabled and NO permissive policies, the public anon /
-- authenticated keys get ZERO rows — the public API is effectively closed.
-- End-user access is enforced by the backend's own JWT auth, not Supabase Auth.


-- Sensitive: emails, password hashes, reset tokens
ALTER TABLE app_user        ENABLE ROW LEVEL SECURITY;

-- Sensitive: pending email-verification codes
ALTER TABLE pending_signup  ENABLE ROW LEVEL SECURITY;

-- Per-user private data (learning progress, saved articles, quizzes)
ALTER TABLE user_article     ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_meaning     ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_vocabulary  ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_vocab_level ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quiz          ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quiz_question ENABLE ROW LEVEL SECURITY;
ALTER TABLE pending_vocab_enrichment ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_session         ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_item            ENABLE ROW LEVEL SECURITY;
ALTER TABLE meaning_review       ENABLE ROW LEVEL SECURITY;

-- Shared content (dictionary + articles); backend still serves it via direct connection
ALTER TABLE vocabulary      ENABLE ROW LEVEL SECURITY;
ALTER TABLE meaning         ENABLE ROW LEVEL SECURITY;
ALTER TABLE article         ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_meaning ENABLE ROW LEVEL SECURITY;
ALTER TABLE vocab_level      ENABLE ROW LEVEL SECURITY;
