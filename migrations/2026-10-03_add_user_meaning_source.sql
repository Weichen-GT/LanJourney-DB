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
