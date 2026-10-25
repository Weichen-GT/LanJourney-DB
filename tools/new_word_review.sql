-- =========================================================================
-- Weekly review of the words readers paste that are outside the ranked word list
-- (table article_new_word). Read-only: run each query by hand (Supabase SQL editor or psql).
-- =========================================================================

-- 1. How many such words readers brought, by what the rewrite did with them (last 7 days)
SELECT outcome, COUNT(*) AS rows, COUNT(DISTINCT vocab_id) AS distinct_words
FROM article_new_word
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY outcome
ORDER BY rows DESC;

-- 2. Share of pasted articles that had at least one such word (last 30 days)
SELECT COUNT(DISTINCT n.article_id)::numeric / NULLIF(COUNT(DISTINCT a.article_id), 0) AS share_of_articles
FROM user_article a
LEFT JOIN article_new_word n ON n.article_id = a.article_id
WHERE a.saved_at > NOW() - INTERVAL '30 days';

-- 3. The words that come up most often (candidates to add to the ranked list)
SELECT v.term, COUNT(*) AS times, COUNT(DISTINCT n.user_id) AS readers,
       COUNT(*) FILTER (WHERE n.outcome = 'TAUGHT') AS taught
FROM article_new_word n
JOIN vocabulary v ON v.id = n.vocab_id
GROUP BY v.term
ORDER BY times DESC, v.term
LIMIT 50;

-- 4. Taught words that only have the AI-written definition (no Chinese explanation yet)
SELECT v.term, m.id AS meaning_id, m.definition
FROM article_new_word n
JOIN meaning m ON m.id = n.meaning_id
JOIN vocabulary v ON v.id = n.vocab_id
WHERE n.outcome = 'TAUGHT' AND m.explanation_zh IS NULL
GROUP BY v.term, m.id, m.definition
ORDER BY v.term
LIMIT 100;

-- 5. Words WordNet does not know at all (slang, brand names, typos): rewritten away, never taught
SELECT v.term, COUNT(*) AS times
FROM article_new_word n
JOIN vocabulary v ON v.id = n.vocab_id
WHERE n.outcome = 'NO_WORDNET_ENTRY'
GROUP BY v.term
ORDER BY times DESC, v.term
LIMIT 100;
