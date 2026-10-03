-- 2026-10-03: clean up 95 old meanings that had no WordNet id and a non-standard part-of-speech label.
--   * 50 junk senses are DELETED (e.g. "haven" as a verb, "camel" as a verb, "ware" = "aware")
--   * 45 real meanings are RELABELLED: a -> adj, vt/vi -> v, modal verb / aux. -> aux
--   * the other 39 (part_of_speech = 'num') are intentionally left alone
--   * ranks are renumbered 1..n for words that lost a meaning, so "key meaning" (rank <= 2) stays meaningful
-- Source of truth: LanJourney-lib/data/odd_pos_meanings_review.csv
--
-- This is ONE statement (a DO block), so it is all-or-nothing in any SQL editor.
--
-- HOW TO RUN
--   1. Run it as is (dry_run = TRUE). It does everything, then deliberately fails with a message that
--      starts "DRY RUN OK" and lists the numbers -- the failure is what rolls everything back. Nothing is saved.
--      A message starting with anything else (e.g. "expected 50 deletes...") means STOP and send it to me.
--   2. If the numbers are right, change  dry_run CONSTANT BOOLEAN := TRUE  to  FALSE  and run it again.
--      "Success. No rows returned" means it was applied.
--   3. Verify with the two SELECTs at the bottom (run them separately).
-- It also aborts, saving nothing, if a target row is missing/already changed, or if any reader, article,
-- review or quiz row points at a meaning that would be deleted. A copy of every affected word's meanings
-- is kept in meaning_backup_20261003 (see RESTORE at the bottom).

DO $body$
DECLARE
  dry_run CONSTANT BOOLEAN := TRUE;   -- <<< change to FALSE to apply for real
  d INT; r INT; refs INT; before_n INT; after_n INT; empty_n INT; odd_labels TEXT;
BEGIN
  CREATE TEMP TABLE _t (term TEXT, sense_key TEXT, action TEXT, old_pos TEXT, new_pos TEXT) ON COMMIT DROP;
  INSERT INTO _t VALUES
    ('addict', 'sense_3', 'relabel', 'vt', 'v'),
    ('concrete', 'vt_1', 'delete', 'vt', ''),
    ('easy', 'sense_4', 'delete', 'vt', ''),
    ('english', 'sense_4', 'delete', 'vt', ''),
    ('flat', 'sense_12', 'delete', 'vt', ''),
    ('flat', 'sense_13', 'delete', 'vt', ''),
    ('fog', 'vt_1', 'relabel', 'vt', 'v'),
    ('glad', 'vt_1', 'delete', 'vt', ''),
    ('haven', 'vt_1', 'delete', 'vt', ''),
    ('haven', 'vt_2', 'delete', 'vt', ''),
    ('haven', 'vt_3', 'delete', 'vt', ''),
    ('minute', 'sense_10', 'relabel', 'vt', 'v'),
    ('minute', 'sense_11', 'delete', 'vt', ''),
    ('over', 'sense_2', 'delete', 'vt', ''),
    ('parallel', 'sense_6', 'relabel', 'vt', 'v'),
    ('pond', 'sense_2', 'delete', 'vt', ''),
    ('queer', 'sense_4', 'delete', 'vt', ''),
    ('rose', 'sense_5', 'delete', 'vt', ''),
    ('rose', 'sense_6', 'delete', 'vt', ''),
    ('slim', 'vt_1', 'relabel', 'vt', 'v'),
    ('sole', 'vt_1', 'relabel', 'vt', 'v'),
    ('statue', 'vt_1', 'delete', 'vt', ''),
    ('tourist', 'sense_3', 'delete', 'vt', ''),
    ('camel', 'vi_1', 'delete', 'vi', ''),
    ('conference', 'sense_3', 'relabel', 'vi', 'v'),
    ('easy', 'sense_3', 'delete', 'vi', ''),
    ('fable', 'vi_1', 'delete', 'vi', ''),
    ('flat', 'sense_14', 'delete', 'vi', ''),
    ('flat', 'sense_15', 'delete', 'vi', ''),
    ('fog', 'vi_1', 'relabel', 'vi', 'v'),
    ('football', 'sense_2', 'delete', 'vi', ''),
    ('fun', 'sense_3', 'delete', 'vi', ''),
    ('gear', 'sense_6', 'relabel', 'vi', 'v'),
    ('gear', 'sense_7', 'relabel', 'vi', 'v'),
    ('guise', 'verb_2', 'delete', 'vi', ''),
    ('heart', 'sense_9', 'delete', 'vi', ''),
    ('intermediate', 'vi_1', 'relabel', 'vi', 'v'),
    ('pleasure', 'sense_5', 'delete', 'vi', ''),
    ('rose', 'sense_7', 'relabel', 'vi', 'v'),
    ('rose', 'sense_8', 'relabel', 'vi', 'v'),
    ('sheer', 'sense_4', 'relabel', 'vi', 'v'),
    ('silk', 'sense_3', 'delete', 'vi', ''),
    ('slim', 'vi_1', 'relabel', 'vi', 'v'),
    ('tea', 'sense_4', 'delete', 'vi', ''),
    ('tourist', 'sense_4', 'delete', 'vi', ''),
    ('attendant', 'sense_4', 'relabel', 'a', 'adj'),
    ('attendant', 'sense_5', 'delete', 'a', ''),
    ('bias', 'a_1', 'delete', 'a', ''),
    ('chill', 'a_1', 'relabel', 'a', 'adj'),
    ('chill', 'a_2', 'delete', 'a', ''),
    ('component', 'sense_3', 'relabel', 'a', 'adj'),
    ('continent', 'a_1', 'delete', 'a', ''),
    ('desert', 'a_1', 'relabel', 'a', 'adj'),
    ('deviate', 'sense_3', 'delete', 'a', ''),
    ('draft', 'sense_6', 'delete', 'a', ''),
    ('endure', 'sense_4', 'delete', 'a', ''),
    ('exponent', 'a_1', 'delete', 'a', ''),
    ('feat', 'a_1', 'delete', 'a', ''),
    ('fellow', 'a_1', 'relabel', 'a', 'adj'),
    ('hybrid', 'a_1', 'relabel', 'a', 'adj'),
    ('hybrid', 'a_2', 'relabel', 'a', 'adj'),
    ('initiate', 'sense_4', 'delete', 'a', ''),
    ('integrate', 'adjective_1', 'delete', 'a', ''),
    ('intermediary', 'a_1', 'relabel', 'a', 'adj'),
    ('intermediary', 'a_2', 'relabel', 'a', 'adj'),
    ('lag', 'a_1', 'delete', 'a', ''),
    ('mass', 'sense_3', 'relabel', 'a', 'adj'),
    ('mass', 'sense_4', 'delete', 'a', ''),
    ('opponent', 'sense_3', 'delete', 'a', ''),
    ('peak', 'sense_6', 'relabel', 'a', 'adj'),
    ('perspective', 'sense_5', 'relabel', 'a', 'adj'),
    ('pilot', 'sense_8', 'relabel', 'a', 'adj'),
    ('protein', 'sense_3', 'relabel', 'a', 'adj'),
    ('quiver', 'sense_5', 'delete', 'a', ''),
    ('rebel', 'sense_2', 'relabel', 'a', 'adj'),
    ('remnant', 'sense_1', 'delete', 'a', ''),
    ('rival', 'sense_2', 'relabel', 'a', 'adj'),
    ('slant', 'adj_1', 'relabel', 'a', 'adj'),
    ('smash', 'sense_4', 'relabel', 'a', 'adj'),
    ('specialty', 'a_1', 'relabel', 'a', 'adj'),
    ('spot', 'sense_2', 'relabel', 'a', 'adj'),
    ('stagger', 'sense_4', 'delete', 'a', ''),
    ('sublimate', 'adjective_1_1', 'delete', 'a', ''),
    ('summit', 'sense_5', 'relabel', 'a', 'adj'),
    ('taunt', 'a_1', 'delete', 'a', ''),
    ('vacuum', 'a_1', 'relabel', 'a', 'adj'),
    ('vertebrate', 'a_1', 'relabel', 'a', 'adj'),
    ('ware', 'a_1', 'delete', 'a', ''),
    ('weather', 'sense_5', 'relabel', 'a', 'adj'),
    ('may', 'sense_2', 'relabel', 'modal verb', 'aux'),
    ('might', 'modal_verb_1', 'relabel', 'modal verb', 'aux'),
    ('will', 'modal_verb_1', 'relabel', 'modal verb', 'aux'),
    ('may', 'sense_1', 'relabel', 'aux.', 'aux'),
    ('may', 'sense_3', 'relabel', 'aux.', 'aux'),
    ('may', 'sense_4', 'relabel', 'aux.', 'aux');

  CREATE TEMP TABLE _m ON COMMIT DROP AS
  SELECT m.id AS meaning_id, m.vocab_id, t.action, t.new_pos
  FROM _t t
  JOIN vocabulary v ON LOWER(v.term) = LOWER(t.term)
  JOIN meaning m ON m.vocab_id = v.id AND m.sense_key = t.sense_key AND m.part_of_speech = t.old_pos
  WHERE m.wordnet_sense_id IS NULL;

  SELECT count(*) FILTER (WHERE action='delete'), count(*) FILTER (WHERE action='relabel') INTO d, r FROM _m;
  IF d <> 50 OR r <> 45 THEN
    RAISE EXCEPTION 'expected 50 deletes + 45 relabels, matched % + % -- aborting, nothing changed', d, r;
  END IF;

  SELECT (SELECT count(*) FROM user_meaning        WHERE meaning_id IN (SELECT meaning_id FROM _m WHERE action='delete'))
       + (SELECT count(*) FROM article_meaning     WHERE meaning_id IN (SELECT meaning_id FROM _m WHERE action='delete'))
       + (SELECT count(*) FROM meaning_review      WHERE meaning_id IN (SELECT meaning_id FROM _m WHERE action='delete'))
       + (SELECT count(*) FROM daily_quiz_question WHERE meaning_id IN (SELECT meaning_id FROM _m WHERE action='delete'))
       + (SELECT count(*) FROM quiz_item           WHERE meaning_id IN (SELECT meaning_id FROM _m WHERE action='delete'))
    INTO refs;
  IF refs > 0 THEN
    RAISE EXCEPTION '% rows reference meanings that would be deleted -- aborting, nothing changed', refs;
  END IF;

  -- Built-in backup: every meaning of every affected word, exactly as it is right now.
  CREATE TABLE meaning_backup_20261003 AS
  SELECT * FROM meaning WHERE vocab_id IN (SELECT vocab_id FROM _m);
  ALTER TABLE meaning_backup_20261003 ENABLE ROW LEVEL SECURITY;  -- keep it off the public API

  SELECT count(*) INTO before_n FROM meaning;

  UPDATE meaning m SET part_of_speech = x.new_pos
  FROM _m x WHERE x.meaning_id = m.id AND x.action = 'relabel';

  DELETE FROM meaning WHERE id IN (SELECT meaning_id FROM _m WHERE action = 'delete');

  UPDATE meaning m SET rank = q.new_rank
  FROM (SELECT id, ROW_NUMBER() OVER (PARTITION BY vocab_id ORDER BY rank, id) AS new_rank
        FROM meaning
        WHERE vocab_id IN (SELECT vocab_id FROM _m WHERE action = 'delete')) q
  WHERE m.id = q.id AND m.rank <> q.new_rank;

  SELECT count(*) INTO after_n FROM meaning;
  SELECT count(*) INTO empty_n FROM vocabulary v WHERE NOT EXISTS (SELECT 1 FROM meaning m WHERE m.vocab_id = v.id);
  SELECT coalesce(string_agg(part_of_speech || '=' || c, ', '), 'none') INTO odd_labels
    FROM (SELECT part_of_speech, count(*) AS c FROM meaning
          WHERE part_of_speech IN ('a','vt','vi','num','modal verb','aux.') GROUP BY 1 ORDER BY 1) z;

  IF after_n <> before_n - 50 OR empty_n <> 0 THEN
    RAISE EXCEPTION 'unexpected result: before=%, after=%, words_without_meanings=% -- aborting, nothing changed',
      before_n, after_n, empty_n;
  END IF;

  IF dry_run THEN
    RAISE EXCEPTION 'DRY RUN OK (this error is expected; nothing was saved): meanings before=%, after=% (expect before-50), words without meanings=% (expect 0), leftover odd labels: % (expect num=39)',
      before_n, after_n, empty_n, odd_labels;
  END IF;
END
$body$;

-- Verify after a real run (run each separately):
--   SELECT count(*) AS meanings_now FROM meaning;
--   SELECT part_of_speech, count(*) FROM meaning WHERE part_of_speech IN ('a','vt','vi','num','modal verb','aux.') GROUP BY 1;

-- =====================================================================================================
-- RESTORE (only if you applied it and want to undo). Run on its own:
--
--   BEGIN;
--   INSERT INTO meaning SELECT * FROM meaning_backup_20261003 b WHERE b.id NOT IN (SELECT id FROM meaning);
--   UPDATE meaning m SET part_of_speech = b.part_of_speech, rank = b.rank
--     FROM meaning_backup_20261003 b WHERE b.id = m.id;
--   COMMIT;
--
-- Once you are happy with the result (a week or so), remove the backup table:
--   DROP TABLE meaning_backup_20261003;
-- =====================================================================================================
