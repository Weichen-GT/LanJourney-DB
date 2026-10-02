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
