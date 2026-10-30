-- =========================================================================
-- Profile page: every user gets a unique username (user-123456 until they pick their own) and can
-- choose one of a few built-in avatar icons. All database changes for the feature, in one file.
--
-- No migration runner (ddl-auto=validate): run by hand on PROD (no staging since 2026-10-23),
-- BEFORE deploying the backend from the profile-username-avatar branch (the backend fails to
-- start if a column it expects is missing). Every statement is safe to re-run.
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
-- app_user.username -- the public handle. 3-20 letters, digits, "_" or "-" (the backend enforces
-- that; the database only guarantees uniqueness). Nullable so a row written by raw SQL does not
-- fail; the backend gives every new account one at signup.
-- app_user.avatar_icon -- key of the built-in icon the user picked (e.g. "cat"); NULL = none
-- picked, show the Google photo or the initials. The backend holds the list of valid keys.
-- -------------------------------------------------------------------------
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS username    TEXT;
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS avatar_icon TEXT;

-- -------------------------------------------------------------------------
-- Backfill: give every existing account a random "user-123456" name, re-drawing on a clash.
-- -------------------------------------------------------------------------
DO $$
DECLARE
  r         RECORD;
  candidate TEXT;
BEGIN
  FOR r IN SELECT id FROM app_user WHERE username IS NULL LOOP
    LOOP
      candidate := 'user-' || lpad(floor(random() * 1000000)::INT::TEXT, 6, '0');
      EXIT WHEN NOT EXISTS (SELECT 1 FROM app_user WHERE lower(username) = candidate);
    END LOOP;
    UPDATE app_user SET username = candidate WHERE id = r.id;
  END LOOP;
END $$;

-- -------------------------------------------------------------------------
-- One username per person, ignoring case ("Anna" and "anna" clash). This index, not the
-- backend's pre-check, is what stops two people who save the same name at the same moment.
-- NULLs do not clash, so accounts without a username are still allowed.
-- -------------------------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS uq_app_user_username_lower
  ON app_user (lower(username));

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). Every row must show ok = true.
-- =========================================================================
SELECT check_name, ok FROM (
  SELECT 'app_user.username exists' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'app_user' AND column_name = 'username') AS ok
  UNION ALL
  SELECT 'app_user.avatar_icon exists',
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'app_user' AND column_name = 'avatar_icon')
  UNION ALL
  SELECT 'every account has a username',
         NOT EXISTS (SELECT 1 FROM app_user WHERE username IS NULL)
  UNION ALL
  SELECT 'no two usernames match ignoring case',
         NOT EXISTS (SELECT 1 FROM app_user GROUP BY lower(username) HAVING COUNT(*) > 1)
  UNION ALL
  SELECT 'unique index on lower(username) exists',
         EXISTS (SELECT 1 FROM pg_indexes
                  WHERE tablename = 'app_user' AND indexname = 'uq_app_user_username_lower'
                    AND indexdef LIKE '%UNIQUE%' AND indexdef LIKE '%lower(username)%')
) checks;
