-- =========================================================================
-- On-demand article ("Discover" button on the For You page): every database change for the
-- feature, in one file. Design: LanJourney2.0/docs/daily-article-generation.md, section
-- "On-demand articles".
--
-- No migration runner (ddl-auto=validate): run by hand on PROD (no staging since 2026-10-23),
-- BEFORE deploying the backend from the on-demand-article branch (the backend fails to
-- start if a column or table it expects is missing). The 2026-10-04_article_generation.sql file
-- must already have run (this file changes generated_article). Every statement is safe to re-run.
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
-- generated_article.origin -- where the article came from. SEND = written for an email send
-- (the nightly job); ON_DEMAND = the reader pressed Discover. The email schedule and the
-- "missed send" rule look at SEND articles only, so a Discover article never delays or
-- replaces the next email. Existing rows are all SEND.
-- -------------------------------------------------------------------------
ALTER TABLE generated_article
  ADD COLUMN IF NOT EXISTS origin TEXT NOT NULL DEFAULT 'SEND'
  CHECK (origin IN ('SEND', 'ON_DEMAND'));

-- -------------------------------------------------------------------------
-- article_request -- one press of the Discover button. The page asks for the result until the
-- request is READY or FAILED. It is also the daily-limit ledger: the requests of the reader's
-- local day (local_date) that are not FAILED are what the limit counts. One PENDING request per
-- reader at a time (the partial unique index), so a double click cannot start two articles.
-- generated_article_id has no ON DELETE CASCADE: an expired article keeps its row anyway.
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS article_request (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
  status               TEXT NOT NULL DEFAULT 'PENDING'
                         CHECK (status IN ('PENDING', 'READY', 'FAILED')),
  generated_article_id UUID REFERENCES generated_article (id) ON DELETE SET NULL,
  failure              TEXT,
  local_date           DATE NOT NULL,
  requested_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at          TIMESTAMPTZ
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_article_request_one_pending
  ON article_request (user_id) WHERE status = 'PENDING';
CREATE INDEX IF NOT EXISTS idx_article_request_user_day
  ON article_request (user_id, local_date);
CREATE INDEX IF NOT EXISTS idx_article_request_requested_at
  ON article_request (requested_at);
ALTER TABLE article_request ENABLE ROW LEVEL SECURITY;

COMMIT;


-- =========================================================================
-- PART 2: verify (read-only). Every row must show ok = true.
-- =========================================================================
SELECT check_name, ok FROM (
  SELECT 'generated_article.origin exists, NOT NULL, default SEND' AS check_name,
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'generated_article' AND column_name = 'origin'
                    AND is_nullable = 'NO' AND column_default LIKE '%SEND%') AS ok
  UNION ALL
  SELECT 'generated_article.origin only allows SEND and ON_DEMAND',
         EXISTS (SELECT 1 FROM pg_constraint
                  WHERE conrelid = 'generated_article'::regclass AND contype = 'c'
                    AND pg_get_constraintdef(oid) LIKE '%origin%'
                    AND pg_get_constraintdef(oid) LIKE '%ON_DEMAND%')
  UNION ALL
  SELECT 'every existing generated_article row is SEND',
         NOT EXISTS (SELECT 1 FROM generated_article WHERE origin <> 'SEND')
  UNION ALL
  SELECT 'article_request table exists with its columns',
         (SELECT COUNT(*) FROM information_schema.columns
           WHERE table_name = 'article_request'
             AND column_name IN ('id', 'user_id', 'status', 'generated_article_id',
                                 'failure', 'local_date', 'requested_at', 'finished_at')) = 8
  UNION ALL
  SELECT 'article_request is deleted with the reader (user_id ON DELETE CASCADE)',
         EXISTS (SELECT 1 FROM pg_constraint
                  WHERE conrelid = 'article_request'::regclass AND contype = 'f'
                    AND confrelid = 'app_user'::regclass AND confdeltype = 'c')
  UNION ALL
  SELECT 'article_request.generated_article_id is ON DELETE SET NULL',
         EXISTS (SELECT 1 FROM pg_constraint
                  WHERE conrelid = 'article_request'::regclass AND contype = 'f'
                    AND confrelid = 'generated_article'::regclass AND confdeltype = 'n')
  UNION ALL
  SELECT 'article_request status only allows PENDING, READY, FAILED',
         EXISTS (SELECT 1 FROM pg_constraint
                  WHERE conrelid = 'article_request'::regclass AND contype = 'c'
                    AND pg_get_constraintdef(oid) LIKE '%PENDING%'
                    AND pg_get_constraintdef(oid) LIKE '%READY%'
                    AND pg_get_constraintdef(oid) LIKE '%FAILED%')
  UNION ALL
  SELECT 'article_request has the one-pending-per-reader unique index',
         EXISTS (SELECT 1 FROM pg_indexes
                  WHERE tablename = 'article_request'
                    AND indexname = 'uq_article_request_one_pending'
                    AND indexdef LIKE '%UNIQUE%' AND indexdef LIKE '%PENDING%')
  UNION ALL
  SELECT 'article_request has its two lookup indexes',
         (SELECT COUNT(*) FROM pg_indexes
           WHERE tablename = 'article_request'
             AND indexname IN ('idx_article_request_user_day',
                               'idx_article_request_requested_at')) = 2
  UNION ALL
  SELECT 'Row Level Security is on for article_request',
         EXISTS (SELECT 1 FROM pg_tables
                  WHERE schemaname = 'public' AND tablename = 'article_request' AND rowsecurity)
) checks;
