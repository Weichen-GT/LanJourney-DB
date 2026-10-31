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
    username TEXT,                            -- public handle, unique ignoring case (index below); "user-123456" until the user picks one
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
    avatar_icon TEXT,                         -- key of the built-in icon the user picked (e.g. "cat"); NULL = none
    locale VARCHAR(35),
    time_zone TEXT,   -- IANA time zone of the reader, from the browser (G3)
    profile_completed BOOLEAN NOT NULL DEFAULT FALSE,
    onboarding_quiz BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,
    CONSTRAINT uq_user_provider_identity UNIQUE (auth_provider, auth_provider_user_id)
  );

CREATE UNIQUE INDEX IF NOT EXISTS uq_app_user_username_lower
  ON app_user (lower(username));

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
    -- REWRITE = taught by a pasted article's rewrite, GENERATED = by a generated article.
    source            TEXT   NOT NULL CONSTRAINT chk_user_meaning_source
                        CHECK (source IN ('ONBOARDING', 'REWRITE', 'GENERATED', 'QUIZ', 'MANUAL', 'UNKNOWN')),
    -- The article that taught this meaning; NULL for other sources. Written once, like source.
    source_article_id UUID   REFERENCES article (id) ON DELETE SET NULL,
    first_seen_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    learned_at        TIMESTAMPTZ,
    last_reviewed_at  TIMESTAMPTZ,            -- graded reviews and status changes; the due check counts from it
    last_seen_at      TIMESTAMPTZ,            -- every article exposure, counted or not (article planner)
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
-- 8b) article_topic: what an article is about (labels and a one-line gist only, never the text).
--     Learning meanings are grouped by the topic of the article that taught them.
-- =========================
CREATE TABLE
  IF NOT EXISTS article_topic (
    article_id    UUID PRIMARY KEY REFERENCES article (id) ON DELETE CASCADE,
    -- the closed topic list (ParentTopic in the backend), in its default priority order
    parent_topic  TEXT NOT NULL CHECK (parent_topic IN (
                    'DAILY_LIFE', 'FOOD', 'SHOPPING_SERVICES', 'TRAVEL', 'HEALTH', 'SOCIAL_LIFE',
                    'WORK', 'JOB_SEARCH', 'EDUCATION', 'ENTERTAINMENT', 'SPORTS_HOBBIES',
                    'TECHNOLOGY', 'MONEY', 'LIVING_ABROAD', 'NATURE')),
    interest_area TEXT NOT NULL,             -- the reader's interest it shows, e.g. "computer science"
    sub_area      TEXT,                      -- narrower, e.g. "machine learning"; NULL if general
    gist          TEXT NOT NULL,             -- one sentence: what the article is about
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

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
-- 13) quiz_session: one practice session (Quick Test or Conversation)
-- =========================
CREATE TABLE
  IF NOT EXISTS quiz_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    mode TEXT NOT NULL CHECK (mode IN ('QUICK', 'CONVERSATION')),
    -- ABANDONED: a Conversation closed before the user sent any message (not counted anywhere)
    status TEXT NOT NULL DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'COMPLETED', 'ABANDONED')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    title TEXT,                      -- Conversation only: the scenario's title
    scenario TEXT,                   -- Conversation only: the 1-2 sentence setup shown to the user
    source_article_id UUID REFERENCES article (id) ON DELETE SET NULL  -- Conversation only: the article its words came from
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
      source IN ('ARTICLE', 'QUICK_TEST', 'ARTICLE_REVIEW', 'DAILY_QUIZ', 'REVIEW', 'MANUAL', 'CONVERSATION')
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
-- 16) conversation_message: every message of a Conversation. The text (and the grader's answer,
--     which quotes it) is set to NULL after 30 days; the verdict and scores stay for analysis.
-- =========================
CREATE TABLE
  IF NOT EXISTS conversation_message (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES quiz_session (id) ON DELETE CASCADE,
    turn INT NOT NULL,               -- 1, 2, 3 ... both roles, in order
    role TEXT NOT NULL CHECK (role IN ('USER', 'AI')),
    text TEXT,                       -- NULL after the retention period
    target_meaning_id BIGINT REFERENCES meaning (id) ON DELETE SET NULL,  -- the active target when a USER message was sent
    verdict TEXT CHECK (verdict IN ('NOT_USED', 'WRONG_SENSE', 'THIN', 'ALMOST', 'PASS')),  -- USER messages: kept for analysis
    score INT,                       -- USER messages: 0-100, from the four parts below
    use_score SMALLINT,              -- the grader's four parts, each 0-2
    sense_score SMALLINT,
    form_score SMALLINT,
    context_score SMALLINT,
    partner_action TEXT CHECK (partner_action IN ('IMPROVE', 'RE_ASK_NAME_IT', 'RE_ASK_REPHRASE', 'REVEAL_WORD', 'REDIRECT_WRONG_SENSE', 'NEXT_TARGET', 'STEER_BACK', 'WRAP_UP')),  -- USER messages: what the partner does next (decided when the message is graded)
    improve_angle TEXT,              -- USER messages: CAUSE, EXAMPLE or CONSEQUENCE, for an IMPROVE action
    flag TEXT CHECK (flag IS NULL OR flag IN ('OFF_TOPIC', 'INJECTION', 'MODERATION', 'SELF_HARM')),  -- USER messages: why it was a safety event (strike rules); NULL on a normal message; kept after the text is erased
    grader_json TEXT,                -- the grader's full answer (quotes the user); NULL after the retention period
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (session_id, turn)
  );

-- The strike rules and the weekly review read only flagged messages, newest first.
CREATE INDEX IF NOT EXISTS idx_conversation_message_flag
  ON conversation_message (created_at)
  WHERE flag IS NOT NULL;

-- =========================
-- 17) conversation_target: one word meaning tested in a Conversation, and how it went
-- =========================
CREATE TABLE
  IF NOT EXISTS conversation_target (
    session_id UUID NOT NULL REFERENCES quiz_session (id) ON DELETE CASCADE,
    meaning_id BIGINT NOT NULL REFERENCES meaning (id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,  -- repeated from the session so the fail-gap query is one index
    position INT NOT NULL,           -- order in the conversation, 1-3
    guiding_question TEXT,           -- the prepared questions from the scenario (no user text)
    re_ask TEXT,
    state TEXT NOT NULL DEFAULT 'PENDING' CHECK (state IN ('PENDING', 'ACTIVE', 'PASS', 'FAIL', 'NOT_ATTEMPTED')),
    messages_used INT NOT NULL DEFAULT 0,        -- user messages while this was the active target (at most 3)
    word_used BOOLEAN NOT NULL DEFAULT FALSE,    -- the user has used the word, so it is no longer hidden
    word_revealed BOOLEAN NOT NULL DEFAULT FALSE,  -- the word was shown in the sidebar (message 3)
    path TEXT CHECK (path IN ('A', 'B', 'C')),   -- set on PASS: the message the word was first used on (C = shown to the user)
    best_score INT,                  -- the highest score among its replies
    best_message_id UUID REFERENCES conversation_message (id) ON DELETE SET NULL,  -- that reply: the one explained in the summary
    status_before INT,               -- on PASS: the meaning's status before and after the gate was crossed
    status_after INT,
    finished_at TIMESTAMPTZ,
    PRIMARY KEY (session_id, meaning_id)
  );

-- the fail-gap query: this user's recent conversations about this meaning
CREATE INDEX IF NOT EXISTS idx_conversation_target_user_meaning
  ON conversation_target (user_id, meaning_id, finished_at DESC);

-- =========================
-- 18) ai_call_log: one row per AI call of article generation (D9). The numbers are kept; the request and
--     response text is set to NULL after about 30 days. A call whose prompt holds a reader's pasted
--     article (or profile text) is logged with no text at all.
-- =========================
CREATE TABLE
  IF NOT EXISTS ai_call_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES app_user (id) ON DELETE CASCADE,  -- deleted with the reader's account
    generated_article_id UUID,       -- the draft this call served; the key to generated_article is added with that table (B4)
    purpose TEXT NOT NULL CHECK (purpose IN ('GENERATE', 'REGENERATE', 'SENSE_CONFIRM', 'SENTENCE_REPAIR', 'JUDGE',
                                             'SAFETY', 'INTEREST_LABEL', 'SUBAREA_PROPOSAL', 'PROFILE_EXTRACTION',
                                             'REWRITE_SELECT', 'SCENARIO_BANK')),
    attempt INT NOT NULL DEFAULT 1,  -- the try within one request (1 = first)
    model TEXT NOT NULL,
    prompt_version TEXT,             -- e.g. gen-v2
    settings_version TEXT,           -- the GenerationSettings fingerprint
    request_text TEXT,               -- system + user prompt; NULL after the retention period or when never kept
    response_text TEXT,              -- the model's answer; NULL after the retention period or when never kept
    input_tokens INT NOT NULL DEFAULT 0,
    output_tokens INT NOT NULL DEFAULT 0,
    reasoning_tokens INT NOT NULL DEFAULT 0,  -- hidden reasoning, already counted in output_tokens
    cost_usd NUMERIC(12, 6),         -- NULL when the model has no configured price
    latency_ms BIGINT,
    status TEXT NOT NULL CHECK (status IN ('OK', 'ERROR', 'RETRY', 'SCHEMA_FAIL')),
    error TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    text_purged_at TIMESTAMPTZ       -- when the text was removed
  );

-- the nightly text purge and the dashboard's time ranges
CREATE INDEX IF NOT EXISTS idx_ai_call_log_created_at ON ai_call_log (created_at);
-- a reader's calls (account view, per-reader cost)
CREATE INDEX IF NOT EXISTS idx_ai_call_log_user ON ai_call_log (user_id, created_at DESC);

-- =========================
-- 18b) scenario_bank (global, no personal data) and reader_scene_use (B1): everyday scenes for each topic or
--     interest label, written once by a model and reused for everyone. A reader's own use and blocks live in
--     reader_scene_use, so one reader's "not for me" never changes the shared bank.
-- =========================
CREATE TABLE
  IF NOT EXISTS scenario_bank (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    label TEXT NOT NULL,             -- a parent topic (ParentTopic name) or a reader-interest area label
    scene TEXT NOT NULL,             -- one short situation, e.g. "reporting a blocker in a daily standup"
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

-- the same scene is never stored twice for a label (compared case-insensitively)
CREATE UNIQUE INDEX IF NOT EXISTS uq_scenario_bank_label_scene ON scenario_bank (label, lower(scene));

CREATE TABLE
  IF NOT EXISTS reader_scene_use (
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    scene_id UUID NOT NULL REFERENCES scenario_bank (id) ON DELETE CASCADE,
    times_used INT NOT NULL DEFAULT 0,
    last_used_at TIMESTAMPTZ,
    blocked BOOLEAN NOT NULL DEFAULT FALSE,   -- "not for me": this reader never gets the scene again
    PRIMARY KEY (user_id, scene_id)
  );

-- =========================
-- 18c) reader_interest (B12): the reader's interest tree. Level 1 = interest area ("computer science"), level 2 =
--     sub-area ("machine learning", later). The score is computed from the evidence counts and
--     last_engaged_at (so the weights can change without a migration).
-- =========================
CREATE TABLE
  IF NOT EXISTS reader_interest (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    parent_topic TEXT NOT NULL CHECK (parent_topic IN (
                    'DAILY_LIFE', 'FOOD', 'SHOPPING_SERVICES', 'TRAVEL', 'HEALTH', 'SOCIAL_LIFE',
                    'WORK', 'JOB_SEARCH', 'EDUCATION', 'ENTERTAINMENT', 'SPORTS_HOBBIES',
                    'TECHNOLOGY', 'MONEY', 'LIVING_ABROAD', 'NATURE')),
    level SMALLINT NOT NULL DEFAULT 1 CHECK (level IN (1, 2)),
    label TEXT NOT NULL,
    parent_interest_id UUID REFERENCES reader_interest (id) ON DELETE CASCADE,
    pasted INT NOT NULL DEFAULT 0,       -- evidence counts
    profile INT NOT NULL DEFAULT 0,
    completed INT NOT NULL DEFAULT 0,
    thumbs_up INT NOT NULL DEFAULT 0,
    opened INT NOT NULL DEFAULT 0,
    negative INT NOT NULL DEFAULT 0,
    delivered INT NOT NULL DEFAULT 0,
    last_engaged_at TIMESTAMPTZ,
    blocked_scope TEXT CHECK (blocked_scope IN ('SCENE', 'AREA', 'TOPIC')),  -- NULL = not blocked
    blocked_at TIMESTAMPTZ,
    first_source TEXT NOT NULL CHECK (first_source IN ('P', 'R', 'C', 'X')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

CREATE UNIQUE INDEX IF NOT EXISTS uq_reader_interest_label ON reader_interest (user_id, parent_topic, level, lower(label));
CREATE INDEX IF NOT EXISTS idx_reader_interest_user ON reader_interest (user_id);

-- =========================
-- 18d) reader_profile (A1): what the reader told us about why they learn English. The raw answers are
--      kept exactly as written and never edited by the extraction, so the extraction can be re-run.
--      Private data: not logged, deleted with the account.
-- =========================
CREATE TABLE
  IF NOT EXISTS reader_profile (
    user_id UUID PRIMARY KEY REFERENCES app_user (id) ON DELETE CASCADE,
    onboarding_status TEXT NOT NULL DEFAULT 'NONE' CHECK (onboarding_status IN ('NONE', 'ANSWERED', 'SKIPPED')),
    onboarding_answers JSONB,        -- question id -> the reader's text, as written
    self_rated_level TEXT,
    description TEXT,                -- "describe your day" (later)
    notes TEXT,
    extraction JSONB,                -- the model's structured reading of the answers
    extraction_version TEXT,
    extraction_status TEXT NOT NULL DEFAULT 'NONE' CHECK (extraction_status IN ('NONE', 'PENDING', 'DONE', 'FAILED')),
    purpose TEXT,
    deadline_date DATE,
    deadline_note TEXT,
    register TEXT,
    skills_needed JSONB,
    situations JSONB,
    vocabulary_themes JSONB,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

-- =========================
-- 18e) profile_suggestion (A6): an interest the extraction guessed from the answers, shown as a one-tap
--      chip ("We think you want ... Right?"). Yes makes it an interest; No hides it for good.
-- =========================
CREATE TABLE
  IF NOT EXISTS profile_suggestion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    parent_topic TEXT NOT NULL CHECK (parent_topic IN (
                    'DAILY_LIFE', 'FOOD', 'SHOPPING_SERVICES', 'TRAVEL', 'HEALTH', 'SOCIAL_LIFE',
                    'WORK', 'JOB_SEARCH', 'EDUCATION', 'ENTERTAINMENT', 'SPORTS_HOBBIES',
                    'TECHNOLOGY', 'MONEY', 'LIVING_ABROAD', 'NATURE')),
    area TEXT NOT NULL,
    source TEXT NOT NULL CHECK (source IN ('STATED', 'INFERRED')),
    confidence NUMERIC(3, 2),
    evidence TEXT,                   -- the reader's own words that support it (a short quote)
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    decided_at TIMESTAMPTZ
  );

CREATE UNIQUE INDEX IF NOT EXISTS uq_profile_suggestion_area ON profile_suggestion (user_id, parent_topic, lower(area));

-- =========================
-- 18f) email_preference (G3/G8): whether the reader gets the article emails, and how often.
-- =========================
CREATE TABLE
  IF NOT EXISTS email_preference (
    user_id UUID PRIMARY KEY REFERENCES app_user (id) ON DELETE CASCADE,
    emails_enabled BOOLEAN NOT NULL DEFAULT TRUE,   -- the profile-page switch; unsubscribing turns it off
    frequency_days INT NOT NULL DEFAULT 2 CHECK (frequency_days BETWEEN 1 AND 7),
    send_hour_local INT NOT NULL DEFAULT 8 CHECK (send_hour_local BETWEEN 0 AND 23),
    paused_until TIMESTAMPTZ,
    unsubscribed_at TIMESTAMPTZ,
    unsubscribe_reason TEXT,
    unsubscribe_feedback TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

-- =========================
-- 18g) email_send (G2): one row per article email, so a re-run of the job never sends twice
--      (one row per reader and local day).
-- =========================
CREATE TABLE
  IF NOT EXISTS email_send (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    send_date DATE NOT NULL,         -- the reader's local day
    subject TEXT,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SENT', 'FAILED', 'SKIPPED')),
    attempts INT NOT NULL DEFAULT 0,
    provider_message_id TEXT,
    error TEXT,
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sent_at TIMESTAMPTZ,
    bounced_at TIMESTAMPTZ,
    complained_at TIMESTAMPTZ,
    first_clicked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, send_date)
  );

-- =========================
-- 19) generated_article: an article written for a reader (design doc B4). Drafts live here; an
--     article row is created only when the reader completes it, so unread drafts never touch
--     article / user_article / the vocabulary. After 30 days unread (60 days after the first open)
--     the text is deleted and the small metadata row stays.
-- =========================
CREATE TABLE
  IF NOT EXISTS generated_article (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),   -- chosen before generation, so the AI call log can name it
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    slot SMALLINT CHECK (slot IN (1, 2)),            -- set by the planner (B8): 1 = profile, 2 = pasted topics
    source TEXT CHECK (source IN ('P', 'R', 'C', 'X')),  -- what the topic came from (profile, recent paste, completed, explore)
    pick_type TEXT CHECK (pick_type IN ('EXPLOIT', 'DRILL_DOWN', 'EXPLORE')),
    topic_label TEXT,                                -- the parent topic
    scene TEXT NOT NULL,
    plan JSONB NOT NULL,                             -- scene, counts, the NEW and LEARNING pools, the must-use word
    validation_report JSONB,                         -- targets found, strays, repairs, cost of the final text
    title TEXT,                                      -- title, teaser and content: NULL once the text is deleted
    teaser TEXT,
    content TEXT,
    word_count INT NOT NULL,
    read_minutes INT NOT NULL,
    quality TEXT NOT NULL CHECK (quality IN ('PASSED', 'RELAXED')),  -- how the vocabulary check ended
    relaxation TEXT CHECK (relaxation IN ('STRAY_ALLOWANCE', 'LEARNING_MINIMUM')),
    prompt_version TEXT NOT NULL,
    model TEXT NOT NULL,
    settings_version TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'GENERATED'
      CHECK (status IN ('GENERATED', 'DELIVERED', 'OPENED', 'COMPLETED', 'EXPIRED', 'HIDDEN')),
    status_before_hidden TEXT,                       -- where "undo" returns to
    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    delivered_at TIMESTAMPTZ,
    first_opened_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    expired_at TIMESTAMPTZ,
    hidden_at TIMESTAMPTZ,
    text_deleted_at TIMESTAMPTZ,
    feedback TEXT,
    not_interested_reason TEXT,
    interest_id UUID REFERENCES reader_interest (id) ON DELETE SET NULL,  -- the interest node the article served (B8)
    annotations JSONB,                               -- the detected words of the final text, for the reader page and Complete (D10)
    send_id UUID REFERENCES email_send (id) ON DELETE SET NULL,   -- the email this article was sent in (G2)
    article_id UUID REFERENCES article (id) ON DELETE SET NULL,  -- set on Complete (D10)
    origin TEXT NOT NULL DEFAULT 'SEND' CHECK (origin IN ('SEND', 'ON_DEMAND')),  -- SEND = written for an email send; ON_DEMAND = the reader pressed Discover
    style TEXT                                       -- the style it was written in (ArticleStyle name: STORY_TWIST, MYTH_FACT, ...); NULL before style cards
  );

-- the reader's feed: newest first, by state
CREATE INDEX IF NOT EXISTS idx_generated_article_user ON generated_article (user_id, generated_at DESC);
-- the nightly expiry job reads only the open states
CREATE INDEX IF NOT EXISTS idx_generated_article_open
  ON generated_article (status, generated_at)
  WHERE status IN ('GENERATED', 'DELIVERED', 'OPENED');

-- =========================
-- 20) article_request: one press of the Discover button on the For You page. The page asks for the
--     result until the request is READY or FAILED. It is also the daily-limit ledger: the requests of
--     the reader's local day (local_date) that are not FAILED are what the limit counts. Only one
--     PENDING request per reader, so a double click cannot start two articles.
-- =========================
CREATE TABLE
  IF NOT EXISTS article_request (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'READY', 'FAILED')),
    generated_article_id UUID REFERENCES generated_article (id) ON DELETE SET NULL,
    failure TEXT,                                    -- why a FAILED request failed (a short code, never reader text)
    local_date DATE NOT NULL,                        -- the reader's local day when they asked
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finished_at TIMESTAMPTZ
  );
CREATE UNIQUE INDEX IF NOT EXISTS uq_article_request_one_pending
  ON article_request (user_id) WHERE status = 'PENDING';
CREATE INDEX IF NOT EXISTS idx_article_request_user_day ON article_request (user_id, local_date);
CREATE INDEX IF NOT EXISTS idx_article_request_requested_at ON article_request (requested_at);

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
