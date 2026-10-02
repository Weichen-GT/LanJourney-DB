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
