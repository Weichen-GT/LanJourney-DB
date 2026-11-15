-- =========================================================================
-- Article word check (read-only): does a saved article keep its promise to the reader?
--
--   psql "$DATABASE_URL" -v article=<article uuid> -v reader=<user uuid> -f tools/article_word_check.sql
--
-- Three answers:
--   1. unknown_in_text  words in the text that the reader does not know and the article does not
--                        teach or explain (should be empty; names it cannot tell apart, numbers and
--                        word forms the simple ending rules below miss show up here too, so read it)
--   2. taught_not_in_text  words the sidebar lists that the text does not contain (should be empty)
--   3. counts            how many new words and new meanings the article taught, and its names
--
-- "Knows" means: a user_vocabulary row, or a user_meaning row with status past Learning (5+), for
-- the word. Word forms are matched by a few simple ending rules, not a real lemmatizer.
-- =========================================================================

WITH words AS (
  SELECT DISTINCT lower(w) AS w
  FROM article a, regexp_split_to_table(a.title || ' ' || a.content, '[^A-Za-z]+') w
  WHERE a.id = :'article' AND length(w) > 1
),
known AS (
  SELECT lower(v.term) AS term FROM user_vocabulary uv JOIN vocabulary v ON v.id = uv.vocab_id
  WHERE uv.user_id = :'reader'
  UNION
  SELECT lower(v.term) FROM user_meaning um JOIN meaning m ON m.id = um.meaning_id
  JOIN vocabulary v ON v.id = m.vocab_id
  WHERE um.user_id = :'reader' AND um.status >= 5
),
explained AS (
  SELECT lower(v.term) AS term FROM article_meaning am JOIN meaning m ON m.id = am.meaning_id
  JOIN vocabulary v ON v.id = m.vocab_id WHERE am.article_id = :'article'
  UNION
  SELECT lower(p) FROM article_term t, regexp_split_to_table(t.term, '[^A-Za-z]+') p
  WHERE t.article_id = :'article' AND p <> ''
),
function_words(term) AS (
  VALUES ('the'),('a'),('an'),('and'),('or'),('but'),('of'),('to'),('in'),('on'),('at'),('for'),('by'),
         ('with'),('from'),('as'),('is'),('are'),('was'),('were'),('be'),('been'),('being'),('has'),
         ('have'),('had'),('it'),('its'),('they'),('their'),('them'),('he'),('his'),('she'),('her'),
         ('we'),('our'),('you'),('your'),('this'),('that'),('these'),('those'),('not'),('no'),('there'),
         ('who'),('what'),('when'),('where'),('which'),('whether'),('would'),('will'),('may'),('can'),
         ('could'),('should'),('do'),('did'),('does'),('if'),('than'),('then'),('so'),('too'),('into'),
         ('about'),('after'),('before'),('between'),('again'),('also'),('any'),('every'),('all'),('s')
),
forms AS (
  SELECT w, ARRAY[w, regexp_replace(w,'s$',''), regexp_replace(w,'es$',''), regexp_replace(w,'ies$','y'),
                  regexp_replace(w,'ed$',''), regexp_replace(w,'d$',''), regexp_replace(w,'ied$','y'),
                  regexp_replace(w,'ing$',''), regexp_replace(w,'ing$','e'), regexp_replace(w,'ly$',''),
                  regexp_replace(w,'er$',''), regexp_replace(w,'r$',''),
                  regexp_replace(w,'(.)\1ed$','\1'), regexp_replace(w,'(.)\1ing$','\1')] AS f
  FROM words
)
SELECT 'unknown_in_text' AS check_name,
       count(*) AS n,
       string_agg(w, ', ' ORDER BY w) AS words
FROM forms
WHERE NOT EXISTS (SELECT 1 FROM known k WHERE k.term = ANY (f))
  AND NOT EXISTS (SELECT 1 FROM explained e WHERE e.term = ANY (f))
  AND NOT EXISTS (SELECT 1 FROM function_words fw WHERE fw.term = w)
UNION ALL
SELECT 'taught_not_in_text',
       count(*),
       string_agg(v.term, ', ' ORDER BY v.term)
FROM article_meaning am JOIN meaning m ON m.id = am.meaning_id JOIN vocabulary v ON v.id = m.vocab_id
JOIN article a ON a.id = am.article_id
WHERE am.article_id = :'article'
  AND (a.title || ' ' || a.content) !~* ('(^|[^a-z])' || v.term)
UNION ALL
SELECT 'counts: new words / new meanings / names',
       count(*),
       count(*) FILTER (WHERE NOT prior) || ' new words, ' || count(*) FILTER (WHERE prior)
         || ' new meanings, ' || (SELECT count(*) FROM article_term t WHERE t.article_id = :'article')
         || ' names and terms'
FROM (
  SELECT EXISTS (
           SELECT 1 FROM user_meaning u2 JOIN meaning m2 ON m2.id = u2.meaning_id
           WHERE u2.user_id = :'reader' AND m2.vocab_id = m.vocab_id AND m2.id <> m.id
             AND u2.source_article_id IS DISTINCT FROM :'article') AS prior
  FROM article_meaning am JOIN meaning m ON m.id = am.meaning_id
  WHERE am.article_id = :'article'
) t;
