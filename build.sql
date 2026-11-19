-- =============================================================
-- BUILD: a complete new LanJourney database in one command.
--
--     psql "<connection string of an EMPTY database>" -f build.sql
--
-- Runs schema.sql, then every seed file in order. Afterwards the database matches prod's schema and
-- vocabulary (11,067 words, 21,792 meanings), with no users. Takes a few minutes (the seeds are ~25 MB).
-- psql only (it uses \ir); the Supabase SQL editor cannot run it.
--
-- It refuses to run on a database that already has the app's tables. To wipe one first, run reset.sql
-- (never on prod), then the seed files -- or drop and recreate the database and run this.
-- =============================================================

\set ON_ERROR_STOP on
\encoding UTF8

DO $$
BEGIN
  IF to_regclass('public.app_user') IS NOT NULL THEN
    RAISE EXCEPTION 'build.sql is for an EMPTY database, and this one already has app_user -- nothing was changed';
  END IF;
END
$$;

\echo == schema
\ir schema.sql
\echo == seed 01: original vocabulary
\ir seed/01_vocabulary_original.sql
\echo == seed 02: WordNet vocabulary
\ir seed/02_vocabulary_wordnet.sql
\echo == seed 03: vocabulary expansion
\ir seed/03_vocabulary_expansion.sql
\echo == seed 04: frequency ranks
\ir seed/04_frequency_rank.sql
\echo == seed 05: meaning fixes
\ir seed/05_meaning_fixes.sql

\echo == done: words, meanings, meanings with a WordNet id (expect 11067, 21792, 20967)
SELECT (SELECT count(*) FROM vocabulary) AS words,
       (SELECT count(*) FROM meaning) AS meanings,
       (SELECT count(*) FROM meaning WHERE wordnet_sense_id IS NOT NULL) AS with_wordnet_id;
