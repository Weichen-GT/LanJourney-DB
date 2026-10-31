-- =========================================================================
-- Article styles: every database change for the feature, in one file. Design:
-- LanJourney2.0/docs/article-styles.md.
--
-- Each generated article is written in one of nine styles (mini story, myth or fact, diary...).
-- The style has been saved inside generated_article.plan (plan.choice.style) since the style
-- cards were built; this file adds a plain column for it, so it can be filtered, counted and
-- joined without digging into the JSON ("which styles get opened and completed?").
--
-- No migration runner (ddl-auto=validate): run by hand on PROD (no staging since 2026-10-23),
-- BEFORE deploying the backend that writes the column (the backend fails to start if a column
-- it expects is missing). The 2026-10-04_article_generation.sql file must already have run (this
-- file changes generated_article). Every statement is safe to re-run.
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
-- generated_article.style -- the style the article was written in: the name of the Java enum
-- ArticleStyle (STORY_TWIST, MYTH_FACT, LETTER, DIARY, THREE_THINGS, DIALOGUE, MISTAKE_FIX,
-- QUESTION, LOCAL_NEWS). NULL for articles written before style cards. No CHECK on the values:
-- a new style is added in the backend alone, with no change here.
-- -------------------------------------------------------------------------
ALTER TABLE generated_article
  ADD COLUMN IF NOT EXISTS style TEXT;

-- Copy the style out of the plan for rows that already have one (none on prod before the
-- styles are deployed; harmless to run, and fills any row written between deploy and this file).
UPDATE generated_article
   SET style = plan -> 'choice' ->> 'style'
 WHERE style IS NULL
   AND plan -> 'choice' ->> 'style' IS NOT NULL;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). Every row must show ok = true.
-- =========================================================================
SELECT check_name, ok FROM (
  SELECT 'generated_article.style exists as nullable text' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'generated_article' AND column_name = 'style'
                    AND data_type = 'text' AND is_nullable = 'YES') AS ok
  UNION ALL
  SELECT 'every row whose plan names a style has the same style in the column',
         NOT EXISTS (SELECT 1 FROM generated_article
                      WHERE plan -> 'choice' ->> 'style' IS NOT NULL
                        AND style IS DISTINCT FROM plan -> 'choice' ->> 'style')
) checks;

-- Look at the result (not a pass/fail check): how many articles per style so far.
SELECT COALESCE(style, '(none: written before styles)') AS style, COUNT(*) AS articles
  FROM generated_article
 GROUP BY 1
 ORDER BY 2 DESC;
