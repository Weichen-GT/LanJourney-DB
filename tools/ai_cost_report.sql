-- =========================================================================
-- AI cost report: which reader behaviors are expensive and which are cheap.
-- Read-only. Run any query on its own (Supabase SQL editor or psql). Each one looks at the last 7 days;
-- change the interval in its first lines to look further back.
--
-- How to read it:
--   behavior   what started the AI calls. A request shows its HTTP method and route:
--                POST /api/v1/articles/rewrite/v3                       pasting an article
--                POST /api/v1/generated-articles/discover                asking for a For You article
--                POST /api/v1/trends/{storyId}/explore                   opening a Trend story as an article
--                POST /api/v1/quiz/quick                                 starting a Quick Test
--                POST /api/v1/quiz/conversation/{sessionId}/reply       the conversation partner's turn
--              and a background job shows 'job: <name>' (e.g. 'job: nightly generation').
--   action     one reader action (one paste, one quiz start, ...). One action can make several AI calls.
--   cost_usd   tokens x the price set in the backend (article-generation.models.prices); an estimate, not
--              the OpenAI bill: cached input tokens are billed lower by OpenAI and are counted at full price.
--              Rows written before the AI cost log (2026-11-15) have no behavior; they show as '(before tagging)'.
-- =========================================================================


-- 1) Cost per behavior: the main answer. Sorted by total spend; avg_usd_per_action is what one use costs.
WITH calls AS (
  SELECT COALESCE(behavior, '(before tagging)') AS behavior,
         COALESCE(action_id, id) AS action,
         cost_usd, input_tokens, output_tokens
  FROM ai_call_log
  WHERE created_at >= now() - interval '7 days'
), actions AS (
  SELECT behavior, action,
         count(*)                   AS calls,
         SUM(cost_usd)              AS usd,
         SUM(input_tokens)          AS input_tokens,
         SUM(output_tokens)         AS output_tokens,
         bool_or(cost_usd IS NULL)  AS some_unpriced
  FROM calls GROUP BY behavior, action
)
SELECT behavior,
       count(*)                                                  AS actions,
       SUM(calls)                                                AS ai_calls,
       ROUND(SUM(usd), 4)                                        AS total_usd,
       ROUND(100 * SUM(usd) / NULLIF(SUM(SUM(usd)) OVER (), 0), 1) AS pct_of_spend,
       ROUND(AVG(usd), 5)                                        AS avg_usd_per_action,
       ROUND(MAX(usd), 5)                                        AS max_usd_per_action,
       ROUND(AVG(input_tokens))                                  AS avg_input_tokens,
       ROUND(AVG(output_tokens))                                 AS avg_output_tokens,
       bool_or(some_unpriced)                                    AS has_unpriced_calls
FROM actions
GROUP BY behavior
ORDER BY total_usd DESC NULLS LAST;


-- 2) Inside each behavior: which AI step costs the most (e.g. a paste = REWRITE_SELECT + REWRITE + ...).
SELECT COALESCE(behavior, '(before tagging)') AS behavior,
       purpose,
       model,
       count(*)                       AS calls,
       count(*) FILTER (WHERE status <> 'OK') AS failed_or_retried,
       ROUND(SUM(cost_usd), 4)        AS total_usd,
       ROUND(AVG(cost_usd), 5)        AS avg_usd_per_call,
       ROUND(AVG(input_tokens))       AS avg_input_tokens,
       ROUND(AVG(output_tokens))      AS avg_output_tokens,
       ROUND(AVG(latency_ms))         AS avg_ms
FROM ai_call_log
WHERE created_at >= now() - interval '7 days'
GROUP BY 1, purpose, model
ORDER BY behavior, total_usd DESC NULLS LAST;


-- 3) Spend per day and behavior: is anything growing?
SELECT date_trunc('day', created_at)::date AS day,
       COALESCE(behavior, '(before tagging)') AS behavior,
       count(DISTINCT COALESCE(action_id, id)) AS actions,
       ROUND(SUM(cost_usd), 4) AS total_usd
FROM ai_call_log
WHERE created_at >= now() - interval '7 days'
GROUP BY 1, 2
ORDER BY 1 DESC, total_usd DESC NULLS LAST;


-- 4) The 20 most expensive single actions, to look at what made them big.
SELECT COALESCE(action_id, id)        AS action,
       MIN(behavior)                  AS behavior,
       MIN(user_id::text)             AS user_id,
       MIN(created_at)                AS started_at,
       count(*)                       AS ai_calls,
       string_agg(DISTINCT purpose, ', ') AS purposes,
       ROUND(SUM(cost_usd), 5)        AS usd
FROM ai_call_log
WHERE created_at >= now() - interval '7 days'
GROUP BY 1
ORDER BY usd DESC NULLS LAST
LIMIT 20;


-- 5) Spend per reader: who costs the most (NULL user = background work not tied to a reader, e.g. Trend).
SELECT user_id,
       count(DISTINCT COALESCE(action_id, id)) AS actions,
       ROUND(SUM(cost_usd), 4)                 AS total_usd,
       ROUND(SUM(cost_usd) / 7, 4)             AS avg_usd_per_day
FROM ai_call_log
WHERE created_at >= now() - interval '7 days'
GROUP BY user_id
ORDER BY total_usd DESC NULLS LAST
LIMIT 20;


-- 6) Gaps to fix. Rows here make the numbers above too low:
--    a model with no price (cost_usd NULL): add it to article-generation.models.prices in the backend;
--    purpose OTHER: a call the code did not name; behavior NULL after the deploy: work started outside
--    a request or a tagged job.
SELECT 'model without a price' AS gap, model AS detail, count(*) AS calls
FROM ai_call_log
WHERE created_at >= now() - interval '7 days' AND cost_usd IS NULL AND input_tokens + output_tokens > 0
GROUP BY model
UNION ALL
SELECT 'unnamed call (purpose OTHER)', COALESCE(behavior, '(no behavior)'), count(*)
FROM ai_call_log
WHERE created_at >= now() - interval '7 days' AND purpose = 'OTHER'
GROUP BY behavior
UNION ALL
SELECT 'untagged call (no behavior)', purpose, count(*)
FROM ai_call_log
WHERE created_at >= now() - interval '7 days' AND behavior IS NULL
  AND created_at >= (SELECT MIN(created_at) FROM ai_call_log WHERE behavior IS NOT NULL)
GROUP BY purpose
ORDER BY gap, calls DESC;
