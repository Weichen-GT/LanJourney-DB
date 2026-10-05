-- =============================================================
-- RESET: DELETES EVERYTHING, then rebuilds the empty schema.
-- GENERATED from schema.sql by tools/build_reset.py -- do not edit by hand.
--
-- !! This drops all 17 tables with all their data (users, articles, progress, vocabulary).
-- !! Only run it on a database you are happy to wipe (local dev, or an empty/staging project).
--
-- After it, load the vocabulary (see README.md > "Rebuild a database"):
--   seed/01_vocabulary_original.sql, seed/02_vocabulary_wordnet.sql, seed/03_frequency_rank.sql
-- Runs as one script in the Supabase SQL editor or psql (no BEGIN/COMMIT: the editor runs statements separately).
-- =============================================================

DROP TABLE IF EXISTS meaning_review CASCADE;
DROP TABLE IF EXISTS quiz_item CASCADE;
DROP TABLE IF EXISTS quiz_session CASCADE;
DROP TABLE IF EXISTS daily_quiz_question CASCADE;
DROP TABLE IF EXISTS daily_quiz CASCADE;
DROP TABLE IF EXISTS user_vocab_level CASCADE;
DROP TABLE IF EXISTS pending_vocab_enrichment CASCADE;
DROP TABLE IF EXISTS vocab_level CASCADE;
DROP TABLE IF EXISTS article_meaning CASCADE;
DROP TABLE IF EXISTS user_vocabulary CASCADE;
DROP TABLE IF EXISTS user_meaning CASCADE;
DROP TABLE IF EXISTS meaning CASCADE;
DROP TABLE IF EXISTS user_article CASCADE;
DROP TABLE IF EXISTS article CASCADE;
DROP TABLE IF EXISTS vocabulary CASCADE;
DROP TABLE IF EXISTS pending_signup CASCADE;
DROP TABLE IF EXISTS app_user CASCADE;
DROP FUNCTION IF EXISTS set_updated_at() CASCADE;

-- =============================================================
-- schema.sql (verbatim)
-- =============================================================

-- =========================
-- Trigger function: keep updated_at current on any UPDATE, even raw SQL
-- =========================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================
-- 1) users
-- =========================
CREATE TABLE
  IF NOT EXISTS app_user (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name TEXT,
    email TEXT NOT NULL UNIQUE,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    -- backend-controlled "enum"
    auth_provider TEXT NOT NULL,              -- e.g. "google"
    auth_provider_user_id TEXT NOT NULL,      -- provider unique id (Google "sub"); equals email for local auth
    password_hash TEXT,                       -- bcrypt hash; NULL for OAuth users
    date_of_birth DATE,
    gender TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    terms_accepted_at TIMESTAMPTZ,
    email_verification_token TEXT,
    email_verification_token_expires_at TIMESTAMPTZ,
    password_reset_token TEXT,
    password_reset_token_expires_at TIMESTAMPTZ,
    last_password_changed_at TIMESTAMPTZ,
    failed_login_attempts INT NOT NULL DEFAULT 0,
    locked_until TIMESTAMPTZ,
    avatar_url TEXT,
    locale VARCHAR(35),
    profile_completed BOOLEAN NOT NULL DEFAULT FALSE,
    onboarding_quiz BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,
    CONSTRAINT uq_user_provider_identity UNIQUE (auth_provider, auth_provider_user_id)
  );

CREATE OR REPLACE TRIGGER trg_app_user_updated_at
  BEFORE UPDATE ON app_user
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================
-- 1b) pending signups (email + 6-digit code, before account exists)
-- =========================
CREATE TABLE
  IF NOT EXISTS pending_signup (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    verification_code TEXT NOT NULL,
    code_expires_at TIMESTAMPTZ NOT NULL,
    attempts INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

CREATE OR REPLACE TRIGGER trg_pending_signup_updated_at
  BEFORE UPDATE ON pending_signup
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================
-- 2) vocabulary items
-- =========================
CREATE TABLE
  IF NOT EXISTS vocabulary (
    id BIGSERIAL PRIMARY KEY,
    term TEXT NOT NULL,       -- always stored in base/dictionary form e.g. "take", "car"
    frequency_rank INT,       -- 1 = most frequent English word; drives onboarding-quiz binding (NULL = unranked)
    is_phrase BOOLEAN NOT NULL DEFAULT FALSE,
    is_abbreviation BOOLEAN NOT NULL DEFAULT FALSE,
    full_form TEXT,           -- e.g. "Chief Executive Officer" for "CEO", null for normal terms
    irregular_forms TEXT,     -- comma-separated irregular inflections e.g. "took, taken, taking"
    pronunciation TEXT,       -- IPA or phonetic respelling, e.g. "/boʊt/"
    definition_en TEXT,
    part_of_speech TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

CREATE UNIQUE INDEX IF NOT EXISTS uq_vocabulary_term_lower ON vocabulary ((LOWER(term)));

-- Range scans over frequency_rank power onboarding-quiz binding (WHERE frequency_rank <= :estimate)
CREATE INDEX IF NOT EXISTS idx_vocabulary_frequency_rank ON vocabulary (frequency_rank);

CREATE OR REPLACE TRIGGER trg_vocabulary_updated_at
  BEFORE UPDATE ON vocabulary
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================
-- 3) articles
-- =========================
CREATE TABLE
  IF NOT EXISTS article (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    source_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

CREATE OR REPLACE TRIGGER trg_article_updated_at
  BEFORE UPDATE ON article
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================
-- 4) user <-> article relation
-- =========================
CREATE TABLE
  IF NOT EXISTS user_article (
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    article_id UUID NOT NULL REFERENCES article (id) ON DELETE CASCADE,
    saved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, article_id)
  );

-- Allows reverse lookup: which users saved a given article?
CREATE INDEX IF NOT EXISTS idx_user_article_article_id ON user_article (article_id);

-- =========================
-- 5) meanings (one vocabulary word can have multiple senses)
-- =========================
CREATE TABLE
  IF NOT EXISTS meaning (
    id BIGSERIAL PRIMARY KEY,
    vocab_id BIGINT NOT NULL REFERENCES vocabulary (id) ON DELETE CASCADE,
    sense_key TEXT NOT NULL,        -- short snake_case key, e.g. "noun_financial_institution"
    -- AI-generated free text (see MeaningService.normalizeSenseKey), NOT a WordNet identifier.
    -- wordnet_sense_id bridges to extjwnl's identifier space so V3's local (Lesk) resolution can
    -- look up "does the reader know this sense" without going through the AI's freeform string.
    -- extjwnl POS-key#offset, e.g. "n#04170037". NULL until backfilled at AI-confirm time.
    wordnet_sense_id TEXT,
    definition TEXT NOT NULL,
    explanation_zh TEXT,            -- Chinese explanation of this specific sense
    part_of_speech TEXT,
    example_sentence TEXT,
    example_sentence_zh TEXT,       -- Chinese translation of example_sentence
    rank INT NOT NULL DEFAULT 1 CHECK (rank > 0),   -- 1 = most common sense, higher = more obscure
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_meaning_vocab_sense UNIQUE (vocab_id, sense_key),
    CONSTRAINT chk_sense_key_format CHECK (sense_key ~ '^[a-z0-9_]+$'),
    CONSTRAINT chk_wordnet_sense_id_format CHECK (wordnet_sense_id IS NULL OR wordnet_sense_id ~ '^[nvasr]#[0-9]+$')
  );

-- Lets Step 2's local sense resolution look up "does the reader already know this
-- (vocab, WordNet sense)" without going through the AI's senseKey namespace. UNIQUE (not just
-- indexed): Step 3 generates a fresh AI senseKey per request, so two concurrent first-time
-- resolutions of the same (vocab, wordnet_sense_id) could otherwise each get a different
-- senseKey, both pass uq_meaning_vocab_sense, and silently create duplicate rows for one sense.
CREATE UNIQUE INDEX IF NOT EXISTS uq_meaning_vocab_wordnet_sense
  ON meaning (vocab_id, wordnet_sense_id) WHERE wordnet_sense_id IS NOT NULL;

-- =========================
-- 6) user <-> meaning relation
-- =========================
CREATE TABLE
  IF NOT EXISTS user_meaning (
    user_id           UUID   NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    meaning_id        BIGINT NOT NULL REFERENCES meaning  (id) ON DELETE CASCADE,
    status            INT    NOT NULL DEFAULT 0 CHECK (status BETWEEN 0 AND 10),
    -- How the row was CREATED; written once, never updated (status changes live in meaning_review).
    source            TEXT   NOT NULL CHECK (source IN ('ONBOARDING', 'ARTICLE', 'QUIZ', 'MANUAL', 'UNKNOWN')),
    -- The article that taught this meaning; NULL for other sources. Written once, like source.
    source_article_id UUID   REFERENCES article (id) ON DELETE SET NULL,
    first_seen_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    learned_at        TIMESTAMPTZ,
    last_reviewed_at  TIMESTAMPTZ,
    PRIMARY KEY (user_id, meaning_id)
  );

-- Allows reverse lookup: which users have encountered a given meaning?
CREATE INDEX IF NOT EXISTS idx_user_meaning_meaning_id ON user_meaning (meaning_id);

-- Groups a reader's Learning meanings by the article (and so the topic) that taught them, and
-- keeps ON DELETE SET NULL cheap when an article is deleted.
CREATE INDEX IF NOT EXISTS idx_user_meaning_source_article_id ON user_meaning (source_article_id);

-- =========================
-- 7) user <-> vocabulary relation
-- =========================
CREATE TABLE
  IF NOT EXISTS user_vocabulary (
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    vocab_id BIGINT NOT NULL REFERENCES vocabulary (id) ON DELETE CASCADE,
    status INT NOT NULL DEFAULT 0 CHECK (status BETWEEN 0 AND 10),  -- 0 = new, 1-9 = in progress, 10 = mastered
    times_seen INT NOT NULL DEFAULT 0,
    review_count INT NOT NULL DEFAULT 0,
    last_seen_at TIMESTAMPTZ,
    last_reviewed_at TIMESTAMPTZ,
    first_added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, vocab_id)
  );

-- Allows reverse lookup: which users have this vocabulary item?
CREATE INDEX IF NOT EXISTS idx_user_vocabulary_vocab_id ON user_vocabulary (vocab_id);

-- =========================
-- 8) article <-> meaning relation
-- =========================
CREATE TABLE
  IF NOT EXISTS article_meaning (
    article_id UUID   NOT NULL REFERENCES article (id) ON DELETE CASCADE,
    meaning_id BIGINT NOT NULL REFERENCES meaning  (id) ON DELETE CASCADE,
    -- the sentence where the article used this meaning (taught meanings only); Quick Test asks it
    sentence TEXT,
    PRIMARY KEY (article_id, meaning_id)
  );

CREATE INDEX IF NOT EXISTS idx_article_meaning_meaning_id ON article_meaning (meaning_id);

-- =========================
-- 9) vocab_level: vocabulary-size tiers (1-10, each split into IV/III/II/I sub-tiers)
-- =========================
CREATE TABLE
  IF NOT EXISTS vocab_level (
    id SERIAL PRIMARY KEY,
    level INT NOT NULL CHECK (level BETWEEN 1 AND 10),
    sub_tier TEXT CHECK (sub_tier IN ('IV', 'III', 'II', 'I')),  -- NULL only for level 10 (Mythic)
    name TEXT NOT NULL UNIQUE,   -- e.g. "Iron IV", ... "Iron I", "Bronze IV", ..., "Mythic"
    min_words INT NOT NULL,      -- inclusive lower bound of estimated vocabulary size
    max_words INT,               -- exclusive upper bound; NULL = unbounded (Mythic, 18000+)
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
  (10, NULL, 'Mythic', 18000, NULL)
ON CONFLICT (name) DO NOTHING;

-- =========================
-- 10) pending vocab enrichment retry queue
-- =========================
CREATE TABLE
  IF NOT EXISTS pending_vocab_enrichment (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID        NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    article_id        UUID        REFERENCES article (id) ON DELETE SET NULL,
    term              TEXT        NOT NULL,
    status            TEXT        NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'FAILED')),
    discovered_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_attempted_at TIMESTAMPTZ
  );

CREATE INDEX IF NOT EXISTS idx_pve_user_id    ON pending_vocab_enrichment (user_id);
CREATE INDEX IF NOT EXISTS idx_pve_article_id ON pending_vocab_enrichment (article_id);
CREATE INDEX IF NOT EXISTS idx_pve_term       ON pending_vocab_enrichment (term);

-- =========================
-- 11) user <-> vocab_level binding (each user's current tier)
-- =========================
CREATE TABLE
  IF NOT EXISTS user_vocab_level (
    user_id UUID PRIMARY KEY REFERENCES app_user (id) ON DELETE CASCADE,
    level_id INT NOT NULL REFERENCES vocab_level (id),
    estimated_vocabulary INT NOT NULL,   -- the size estimate that produced this level
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

CREATE INDEX IF NOT EXISTS idx_user_vocab_level_level_id ON user_vocab_level (level_id);

CREATE OR REPLACE TRIGGER trg_user_vocab_level_updated_at
  BEFORE UPDATE ON user_vocab_level
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================
-- 11) daily_quiz: one AI-generated quiz session per user per calendar day
-- =========================
CREATE TABLE
  IF NOT EXISTS daily_quiz (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    quiz_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'COMPLETED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    -- one quiz per user per day; re-requesting the same day returns the existing quiz
    CONSTRAINT uq_daily_quiz_user_date UNIQUE (user_id, quiz_date)
  );

-- =========================
-- 12) daily_quiz_question: AI-generated multiple-choice questions belonging to one quiz
-- =========================
CREATE TABLE
  IF NOT EXISTS daily_quiz_question (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID NOT NULL REFERENCES daily_quiz (id) ON DELETE CASCADE,
    vocab_id BIGINT NOT NULL REFERENCES vocabulary (id) ON DELETE CASCADE,
    -- NULL when the word has no meaning rows yet — the question then targets the word as a whole
    meaning_id BIGINT REFERENCES meaning (id) ON DELETE CASCADE,
    -- snapshot of the tier used at generation time, independent of later status drift
    familiarity_tier TEXT NOT NULL CHECK (familiarity_tier IN ('LOW', 'HIGH', 'MASTER')),
    question_order INT NOT NULL,
    question_text TEXT NOT NULL,
    options TEXT NOT NULL,            -- JSON array of {"key":"A","label":"..."}
    correct_option_key TEXT NOT NULL, -- never sent to the client until after submission
    user_answer_key TEXT,
    is_correct BOOLEAN,
    answered_at TIMESTAMPTZ
  );

CREATE INDEX IF NOT EXISTS idx_daily_quiz_question_quiz_id ON daily_quiz_question (quiz_id);

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

-- =========================
-- Row Level Security
-- =========================
-- Supabase exposes every table in the public schema through its REST API. Enabling RLS with no
-- policies blocks that path for the anon/authenticated roles; the backend connects as the
-- 'postgres' role, which bypasses RLS, so the app is unaffected. This loop covers every table,
-- including any added later, so nothing is left exposed by accident. Safe to re-run.
DO $$
DECLARE t RECORD;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t.tablename);
  END LOOP;
END $$;

COMMIT;
