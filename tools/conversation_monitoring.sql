-- Conversation quiz: monitoring and weekly review queries (read-only).
-- Design: LanJourney2.0/docs/conversation-quiz-safety.md section 6. Run in the Supabase SQL editor.
-- Message text is kept 30 days and is NULL after that; the flag, verdict and scores stay.

-- 1) Conversations and messages per day (last 14 days), and how many were flagged
SELECT date_trunc('day', m.created_at)::date AS day,
       count(DISTINCT m.session_id)                      AS conversations,
       count(*) FILTER (WHERE m.role = 'USER')           AS learner_messages,
       count(*) FILTER (WHERE m.flag IS NOT NULL)        AS flagged_messages
FROM conversation_message m
WHERE m.created_at >= NOW() - INTERVAL '14 days'
GROUP BY 1
ORDER BY 1 DESC;

-- 2) Flags by type per day (last 14 days)
SELECT date_trunc('day', created_at)::date AS day, flag, count(*) AS messages
FROM conversation_message
WHERE flag IS NOT NULL AND created_at >= NOW() - INTERVAL '14 days'
GROUP BY 1, 2
ORDER BY 1 DESC, 2;

-- 3) Strike points per reader, last 24 hours (the block level is 6) and last 7 days
SELECT s.user_id,
       sum(CASE m.flag WHEN 'OFF_TOPIC' THEN 1 WHEN 'INJECTION' THEN 1 WHEN 'MODERATION' THEN 2 ELSE 0 END)
         FILTER (WHERE m.created_at >= NOW() - INTERVAL '24 hours') AS points_24h,
       sum(CASE m.flag WHEN 'OFF_TOPIC' THEN 1 WHEN 'INJECTION' THEN 1 WHEN 'MODERATION' THEN 2 ELSE 0 END) AS points_7d,
       count(*) FILTER (WHERE m.flag = 'SELF_HARM') AS self_harm_messages
FROM conversation_message m
JOIN quiz_session s ON s.id = m.session_id
WHERE m.flag IS NOT NULL AND m.created_at >= NOW() - INTERVAL '7 days'
GROUP BY s.user_id
ORDER BY points_24h DESC NULLS LAST, points_7d DESC
LIMIT 50;

-- 4) The flagged messages to read in the weekly review (newest first; text is NULL after 30 days)
SELECT m.created_at, s.user_id, m.flag, left(m.text, 200) AS text
FROM conversation_message m
JOIN quiz_session s ON s.id = m.session_id
WHERE m.flag IS NOT NULL AND m.created_at >= NOW() - INTERVAL '7 days'
ORDER BY m.created_at DESC
LIMIT 100;

-- 5) A random sample of 20 ordinary conversations to read (the other half of the weekly review)
SELECT m.session_id, m.turn, m.role, left(m.text, 200) AS text, m.verdict, m.score
FROM conversation_message m
WHERE m.session_id IN (
        SELECT id FROM quiz_session
        WHERE mode = 'CONVERSATION' AND status = 'COMPLETED'
          AND started_at >= NOW() - INTERVAL '7 days'
        ORDER BY random() LIMIT 20)
ORDER BY m.session_id, m.turn;

-- 6) Outcomes: how conversations end and how the words do (last 14 days)
SELECT t.state, t.path, count(*) AS words, round(avg(t.best_score)) AS avg_best_score
FROM conversation_target t
JOIN quiz_session s ON s.id = t.session_id
WHERE s.started_at >= NOW() - INTERVAL '14 days'
GROUP BY 1, 2
ORDER BY 1, 2;

-- 7) Grader verdicts of learner messages (last 14 days): is the mix drifting after a change?
SELECT verdict, count(*) AS messages, round(avg(score)) AS avg_score
FROM conversation_message
WHERE role = 'USER' AND flag IS NULL AND verdict IS NOT NULL
  AND created_at >= NOW() - INTERVAL '14 days'
GROUP BY 1
ORDER BY 2 DESC;

-- 8) How many conversations started today across all readers (the global daily cap is 2000)
SELECT count(*) AS conversations_started_today
FROM quiz_session
WHERE mode = 'CONVERSATION' AND started_at >= date_trunc('day', NOW() AT TIME ZONE 'UTC') AT TIME ZONE 'UTC';
