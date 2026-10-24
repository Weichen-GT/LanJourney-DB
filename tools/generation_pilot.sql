-- Generated articles: pilot monitoring queries (read-only). Run in the Supabase SQL editor.
-- Plan: LanJourney2.0/docs/article-generation-pilot-plan.md. Nothing here shows a reader's own text:
-- the articles are written by the model; the profile answers are never selected.

-- 1) Articles by state (all time)
SELECT status, count(*) AS articles
FROM generated_article
GROUP BY status
ORDER BY status;

-- 2) Per reader, last 28 days: written, opened, completed, and the share completed
SELECT u.email,
       count(*)                                          AS written,
       count(*) FILTER (WHERE a.first_opened_at IS NOT NULL) AS opened,
       count(*) FILTER (WHERE a.status = 'COMPLETED')    AS completed,
       round(100.0 * count(*) FILTER (WHERE a.status = 'COMPLETED') / count(*), 0) AS completed_pct
FROM generated_article a
JOIN app_user u ON u.id = a.user_id
WHERE a.generated_at >= NOW() - INTERVAL '28 days'
GROUP BY u.email
ORDER BY written DESC;

-- 3) New words saved from generated articles per reader per week (last 4 weeks)
SELECT u.email,
       date_trunc('week', um.first_seen_at)::date AS week,
       count(*) AS new_words
FROM user_meaning um
JOIN app_user u ON u.id = um.user_id
WHERE um.source = 'GENERATED' AND um.first_seen_at >= NOW() - INTERVAL '28 days'
GROUP BY 1, 2
ORDER BY 1, 2;

-- 4) Emails: sent, failed, skipped (and why), last 28 days
SELECT status, coalesce(error, '-') AS reason, count(*) AS emails
FROM email_send
WHERE created_at >= NOW() - INTERVAL '28 days'
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- 5) Unsubscribes with their reasons (the free-text comment is the reader's own words: read, do not share)
SELECT u.email, p.unsubscribed_at::date AS day, p.unsubscribe_reason
FROM email_preference p
JOIN app_user u ON u.id = p.user_id
WHERE p.unsubscribed_at IS NOT NULL
ORDER BY p.unsubscribed_at DESC;

-- 6) AI cost: per article (written ones) and per reader, last 28 days
SELECT u.email,
       count(DISTINCT l.generated_article_id)    AS articles,
       round(sum(l.cost_usd)::numeric, 3)        AS usd,
       round((sum(l.cost_usd) / NULLIF(count(DISTINCT l.generated_article_id), 0))::numeric, 4) AS usd_per_article
FROM ai_call_log l
JOIN app_user u ON u.id = l.user_id
WHERE l.created_at >= NOW() - INTERVAL '28 days' AND l.purpose <> 'SAFETY'
GROUP BY u.email
ORDER BY usd DESC;

-- 7) Where the money goes, by purpose, last 7 days
SELECT purpose, count(*) AS calls, round(sum(cost_usd)::numeric, 3) AS usd,
       round(avg(latency_ms)) AS avg_ms,
       count(*) FILTER (WHERE status NOT IN ('OK')) AS not_ok
FROM ai_call_log
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY purpose
ORDER BY usd DESC NULLS LAST;

-- 8) Safety check: flagged or unavailable (category names only, no text), last 28 days
SELECT date_trunc('day', created_at)::date AS day, error AS result, count(*) AS drafts
FROM ai_call_log
WHERE purpose = 'SAFETY' AND created_at >= NOW() - INTERVAL '28 days' AND error IS NOT NULL
GROUP BY 1, 2
ORDER BY 1 DESC;

-- 9) How the vocabulary check ended: passed, relaxed, and drafts that needed repair
SELECT quality, relaxation, count(*) AS articles,
       round(avg((validation_report->>'costUsd')::numeric), 4) AS avg_usd,
       round(avg((validation_report->>'aiCalls')::numeric), 1) AS avg_calls,
       count(*) FILTER (WHERE (validation_report->>'firstDraftPassed')::boolean) AS first_draft_ok
FROM generated_article
GROUP BY 1, 2
ORDER BY 1, 2;

-- 10) The weekly human read: ten articles from the last 7 days, chosen at random
SELECT a.id, a.title, a.topic_label, a.scene, a.quality, a.word_count, left(a.content, 4000) AS content
FROM generated_article a
WHERE a.generated_at >= NOW() - INTERVAL '7 days' AND a.content IS NOT NULL
ORDER BY random()
LIMIT 10;

-- 11) Readers whose emails stopped by themselves (5 sent, no sign of life since)
SELECT u.email, count(*) AS sent_emails, max(s.sent_at)::date AS last_sent
FROM email_send s
JOIN app_user u ON u.id = s.user_id
WHERE s.status = 'SENT'
GROUP BY u.id, u.email
HAVING count(*) >= 5
   AND NOT EXISTS (SELECT 1 FROM generated_article a
                    WHERE a.user_id = u.id AND (a.first_opened_at IS NOT NULL OR a.completed_at IS NOT NULL)
                      AND coalesce(a.completed_at, a.first_opened_at) >= NOW() - INTERVAL '14 days')
ORDER BY sent_emails DESC;
