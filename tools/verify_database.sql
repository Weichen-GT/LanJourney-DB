-- =========================================================================
-- verify_database.sql: read-only health check of any LanJourney database (prod, local).
-- Changes nothing. Run it in the Supabase SQL editor, or:
--   psql "<connection>" -f tools/verify_database.sql
--
-- Result 1: every row must be ok = true.
--           Exception: the last row is false until PART 3 of
--           migrations/2026-10-04_article_generation.sql has been run (after the backend is live).
-- Result 2: counts. Expected on a database loaded from the seed files:
--           words = ranked = 11,067; meanings = 22,041 (a little more if the app added AI meanings);
--           meanings_with_wordnet_id = 20,757. After updates/2026-10-23_idless_cleanup.sql (prod has it):
--           meanings = 21,792 and meanings_with_wordnet_id = 20,967. The two reader counts are whatever you really have.
-- Result 3: spot check of words added by the vocabulary expansion (ranks from the seed files).
-- Keep this file current: add a row to Result 1 whenever a migration adds something to verify.
-- =========================================================================

-- Result 1: checks
SELECT item, ok FROM (
  SELECT 'column user_meaning.source_article_id (P3)' AS item,
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'user_meaning' AND column_name = 'source_article_id') AS ok
  UNION ALL SELECT 'column user_meaning.last_seen_at (P9)',
         EXISTS (SELECT 1 FROM information_schema.columns
                  WHERE table_name = 'user_meaning' AND column_name = 'last_seen_at')
  UNION ALL SELECT 'table ai_call_log (D9)',
         EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ai_call_log')
  UNION ALL SELECT 'table generated_article (B4)',
         EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'generated_article')
  UNION ALL SELECT 'table article_new_word',
         EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'article_new_word')
  UNION ALL SELECT 'table article_topic (A5)',
         EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'article_topic')
  UNION ALL SELECT 'source CHECK allows REWRITE and GENERATED (P4)',
         EXISTS (SELECT 1 FROM pg_constraint
                  WHERE conrelid = 'user_meaning'::regclass AND conname = 'chk_user_meaning_source'
                    AND pg_get_constraintdef(oid) LIKE '%REWRITE%'
                    AND pg_get_constraintdef(oid) LIKE '%GENERATED%')
  UNION ALL SELECT 'every onboarded reader has a vocabulary estimate (C7a)',
         NOT EXISTS (SELECT 1 FROM user_meaning um WHERE um.source = 'ONBOARDING'
                      AND NOT EXISTS (SELECT 1 FROM user_vocab_level u WHERE u.user_id = um.user_id))
  UNION ALL SELECT 'frequency_rank is dense: 1..N, no gaps, no duplicates (C11)',
         (SELECT COUNT(frequency_rank) = MAX(frequency_rank)
             AND COUNT(frequency_rank) = COUNT(DISTINCT frequency_rank) FROM vocabulary)
  UNION ALL SELECT 'exactly 11,067 ranked words (C11)',
         (SELECT COUNT(frequency_rank) = 11067 FROM vocabulary)
  UNION ALL SELECT 'every ranked word has at least one meaning (C11)',
         NOT EXISTS (SELECT 1 FROM vocabulary v WHERE v.frequency_rank IS NOT NULL
                      AND NOT EXISTS (SELECT 1 FROM meaning m WHERE m.vocab_id = v.id))
  UNION ALL SELECT 'no duplicate words, ignoring case',
         NOT EXISTS (SELECT 1 FROM vocabulary GROUP BY LOWER(term) HAVING COUNT(*) > 1)
  UNION ALL SELECT 'the expansion words are ranked: go, limit, injury, hunt, tuna, chassis (C11)',
         (SELECT COUNT(*) = 6 FROM vocabulary
           WHERE LOWER(term) IN ('go','limit','injury','hunt','tuna','chassis')
             AND frequency_rank IS NOT NULL)
  UNION ALL SELECT 'rank 1 is "the"',
         (SELECT LOWER(term) = 'the' FROM vocabulary WHERE frequency_rank = 1)
  UNION ALL SELECT 'no profane word has a rank (C11)',
         NOT EXISTS (SELECT 1 FROM vocabulary WHERE frequency_rank IS NOT NULL
                      AND LOWER(term) IN ('shit','fuck','fucking','bitch','cunt','pussy','dick',
                                          'cock','porn','asshole','bastard','slut','whore','penis','vagina'))
  UNION ALL SELECT 'row level security is on for every table',
         NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND NOT rowsecurity)
  UNION ALL SELECT 'AFTER PART 3: no user_meaning rows with source ARTICLE (P4)',
         NOT EXISTS (SELECT 1 FROM user_meaning WHERE source = 'ARTICLE')
  UNION ALL SELECT 'AFTER PART 3: CHECK no longer allows ARTICLE (P4)',
         NOT EXISTS (SELECT 1 FROM pg_constraint
                      WHERE conrelid = 'user_meaning'::regclass AND conname = 'chk_user_meaning_source'
                        AND pg_get_constraintdef(oid) LIKE '%''ARTICLE''%')
) checks;

-- Result 2: counts
SELECT (SELECT COUNT(*) FROM vocabulary) AS words,
       (SELECT COUNT(frequency_rank) FROM vocabulary) AS ranked,
       (SELECT COUNT(*) FROM meaning) AS meanings,
       (SELECT COUNT(*) FROM meaning WHERE wordnet_sense_id IS NOT NULL) AS meanings_with_wordnet_id,
       (SELECT COUNT(*) FROM user_vocab_level) AS readers_with_estimate,
       (SELECT COUNT(*) FROM user_meaning) AS reader_meanings;

-- Result 3: spot check (expected ranks from the seed files: the 1, go 91, injury 1510, limit 1635,
-- hunt 2370, tuna 7850, chassis 8699; "the" has no WordNet id because function words have none)
SELECT v.term, v.frequency_rank, COUNT(m.id) AS meanings,
       BOOL_AND(m.wordnet_sense_id IS NOT NULL) AS all_have_wordnet_id
FROM vocabulary v JOIN meaning m ON m.vocab_id = v.id
WHERE LOWER(v.term) IN ('the','go','injury','limit','hunt','tuna','chassis')
GROUP BY v.term, v.frequency_rank ORDER BY v.frequency_rank;
