-- =========================================================================
-- Trend page: every database change for the feature, in one file. Design:
-- LanJourney2.0/docs/article-system-v3.md and docs/trend-page.md.
--
-- What it adds: trend_story (one row per listed trend: category, rank, title and the stored
-- source brief that an article is written from) and article_request.trend_story_id (a Discover
-- request that came from a Trend click instead of the Discover button).
--
-- No migration runner (ddl-auto=validate): run by hand on PROD (no staging since 2026-10-23),
-- BEFORE deploying the backend from the trend-page branch (the backend fails to start if a
-- table or column it expects is missing). The 2026-10-28_on_demand_article.sql file must
-- already have run. Every statement is safe to re-run.
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
-- trend_story -- one listed trend story, shared by every reader. The brief is the list of
-- verified facts (each tagged with its source) an article is written from; it holds facts in
-- our own words, never source text. Readers never see the brief, only the title and teaser.
-- A story is listed for one day and category; rank 1 is the top of that category.
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS trend_story (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_date   DATE NOT NULL,                       -- the UTC day the story was listed for
  category     TEXT NOT NULL CHECK (category IN ('WORLD', 'BUSINESS', 'TECH', 'SCIENCE_HEALTH')),
  rank         SMALLINT NOT NULL CHECK (rank BETWEEN 1 AND 5),
  title        TEXT NOT NULL,
  teaser       TEXT,                                -- one line shown on the page
  lane         TEXT NOT NULL CHECK (lane IN ('NEWS', 'KNOWLEDGE')),
  brief        JSONB NOT NULL,                      -- the SourceBrief the article is written from
  source_count INT NOT NULL,                        -- how many different sources the brief rests on
  signal       JSONB,                               -- what made it a trend: domains, links, counts
  status       TEXT NOT NULL DEFAULT 'LISTED' CHECK (status IN ('LISTED', 'RETIRED')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (story_date, category, rank)
);
CREATE INDEX IF NOT EXISTS idx_trend_story_date ON trend_story (story_date DESC, category, rank);
ALTER TABLE trend_story ENABLE ROW LEVEL SECURITY;

-- -------------------------------------------------------------------------
-- article_request.trend_story_id -- set when the request came from a Trend click. A story that
-- is deleted later leaves the request (and the article) in place.
-- -------------------------------------------------------------------------
ALTER TABLE article_request
  ADD COLUMN IF NOT EXISTS trend_story_id UUID REFERENCES trend_story (id) ON DELETE SET NULL;

COMMIT;


-- =========================================================================
-- PART 2: verify (run after PART 1; every row must show ok = true)
-- =========================================================================
SELECT 'trend_story table exists' AS check_name,
       to_regclass('public.trend_story') IS NOT NULL AS ok
UNION ALL
SELECT 'trend_story has RLS on',
       COALESCE((SELECT relrowsecurity FROM pg_class WHERE oid = to_regclass('public.trend_story')), false)
UNION ALL
SELECT 'trend_story has all 12 columns',
       (SELECT COUNT(*) FROM information_schema.columns
         WHERE table_schema = 'public' AND table_name = 'trend_story') = 12
UNION ALL
SELECT 'article_request.trend_story_id exists',
       EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema = 'public' AND table_name = 'article_request'
                  AND column_name = 'trend_story_id')
UNION ALL
SELECT 'one story per day, category and rank (unique constraint)',
       EXISTS (SELECT 1 FROM pg_constraint
                WHERE conrelid = to_regclass('public.trend_story') AND contype = 'u');

-- Rollback (only if nothing reads the feature yet):
--   ALTER TABLE article_request DROP COLUMN IF EXISTS trend_story_id;
--   DROP TABLE IF EXISTS trend_story;
