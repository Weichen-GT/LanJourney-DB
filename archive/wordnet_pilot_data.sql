-- ============================================================
-- vocabulary + meaning seed data
-- Source : wordnet_term_verified.json
-- Generated: 2026-09-13 12:14:27 by scripts/json_to_sql.py (deterministic)
-- Terms : 8   Meanings: 24
-- Safe to re-run: ON CONFLICT DO NOTHING throughout.
-- ============================================================

BEGIN;

-- good
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'good', FALSE, FALSE, NULL, NULL, '/ɡʊd/', 'Having desirable qualities; beneficial or morally admirable.', 'n,adj,adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'n_1', 'Something beneficial or pleasing; a source of value or happiness.', '指有益处、令人愉快或有价值的事物；幸福或快乐的来源。', 'n', 'For your own good, you should rest.', '为了你好，你应该休息一下。', 1
FROM vocabulary WHERE LOWER(term) = LOWER('good')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'n_2', 'Moral excellence or admirable qualities.', '指道德上的优良或令人钦佩的品质。', 'n', 'There is much good in helping others.', '帮助他人大有益处。', 2
FROM vocabulary WHERE LOWER(term) = LOWER('good')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'n_3', 'That which is pleasing, valuable, or useful.', '指令人愉快、有价值或有用的东西。', 'n', 'Weigh the good against the bad.', '要权衡利与弊。', 3
FROM vocabulary WHERE LOWER(term) = LOWER('good')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_1', 'Having desirable or positive qualities; suitable for a specific purpose.', '具有令人愉快或积极的品质；适合特定的目的。', 'adj', 'She received a good report card.', '她收到了很好的成绩单。', 4
FROM vocabulary WHERE LOWER(term) = LOWER('good')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_2', 'At least; fully as much as a specified amount.', '至少；足有（某个数量）。', 'adj', 'It''s a good mile from here.', '从这里到那儿至少有一英里。', 5
FROM vocabulary WHERE LOWER(term) = LOWER('good')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_3', 'Morally admirable.', '在道德上值得称赞。', 'adj', 'He is a good and honest man.', '他是一个善良诚实的人。', 6
FROM vocabulary WHERE LOWER(term) = LOWER('good')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adv_1', 'In a satisfactory or proper manner; thoroughly.', '以令人满意或适当的方式；彻底地。', 'adv', 'Did you sleep good last night?', '你昨晚睡得好吗？', 7
FROM vocabulary WHERE LOWER(term) = LOWER('good')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adv_2', 'Completely and absolutely.', '完全彻底地。', 'adv', 'We beat them good!', '我们狠狠地打败了他们！', 8
FROM vocabulary WHERE LOWER(term) = LOWER('good')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- said
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'said', FALSE, FALSE, NULL, NULL, '/sɛd/', 'Previously mentioned or spoken of.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_1', 'Previously mentioned or spoken of.', '指之前提到或说过的人或事物。', 'adj', 'The said agreement was signed last week.', '该协议上周已签署。', 1
FROM vocabulary WHERE LOWER(term) = LOWER('said')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- being
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'being', FALSE, FALSE, NULL, NULL, '/ˈbiːɪŋ/', 'Existence, or a living thing.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'noun_1', 'The state or fact of existing.', '指存在的事实或状态。', 'n', 'A new idea is gradually coming into being.', '一个新的想法正在逐渐形成。', 1
FROM vocabulary WHERE LOWER(term) = LOWER('being')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'noun_2', 'A living thing.', '指具有生命的东西。', 'n', 'All beings deserve respect.', '所有生命都值得尊重。', 2
FROM vocabulary WHERE LOWER(term) = LOWER('being')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- going
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'going', FALSE, FALSE, NULL, NULL, '/ˈɡoʊɪŋ/', 'The act of leaving or progressing.', 'n,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'n_1', 'The act of departing; the act of leaving a place.', '离开的行为；离开某个地方的行为。', 'n', 'Her going took everyone by surprise.', '她的离开让所有人感到意外。', 1
FROM vocabulary WHERE LOWER(term) = LOWER('going')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'n_2', 'A euphemistic term for death.', '对死亡的委婉说法。', 'n', 'We mourned his going.', '我们为他的逝去感到悲伤。', 2
FROM vocabulary WHERE LOWER(term) = LOWER('going')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'n_3', 'The manner, rate, or condition of proceeding; progress.', '前进的方式、速度或状况；进展情况。', 'n', 'The going was slow through the mud.', '在泥地里前进得很慢。', 3
FROM vocabulary WHERE LOWER(term) = LOWER('going')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_1', 'In operation; functioning.', '运转中的；运营中的。', 'adj', 'The company is a going concern.', '这家公司是一个正在运营的企业。', 4
FROM vocabulary WHERE LOWER(term) = LOWER('going')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- made
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'made', FALSE, FALSE, NULL, NULL, '/meɪd/', 'Produced or manufactured; or, neatly arranged.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_1', 'Produced by a manufacturing process.', '指通过制造过程生产出来的。', 'adj', 'The furniture is well made and sturdy.', '这件家具做工精良且结实耐用。', 1
FROM vocabulary WHERE LOWER(term) = LOWER('made')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_2', 'Neatly arranged, especially of a bed.', '指（通常指床铺）整洁地铺好。', 'adj', 'The bed was neatly made.', '床铺得整整齐齐。', 2
FROM vocabulary WHERE LOWER(term) = LOWER('made')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_3', 'Successful or assured of success.', '指事业成功或必将成功。', 'adj', 'After that deal, he was a made man.', '那笔交易之后，他就飞黄腾达了。', 3
FROM vocabulary WHERE LOWER(term) = LOWER('made')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- done
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'done', FALSE, FALSE, NULL, NULL, '/dʌn/', 'Finished, or cooked to the right degree.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_1', 'Having finished or arrived at completion.', '指已经完成或达到终点。', 'adj', 'He''s certain to make history before he''s done.', '他完成之前一定会创造历史。', 1
FROM vocabulary WHERE LOWER(term) = LOWER('done')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_2', 'Cooked until ready to serve.', '指烹饪到可以上桌的程度。', 'adj', 'The chicken is done.', '鸡肉已经熟了。', 2
FROM vocabulary WHERE LOWER(term) = LOWER('done')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- getting
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'getting', FALSE, FALSE, NULL, NULL, '/ˈɡetɪŋ/', 'The act of acquiring something.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'n_1', 'The act of acquiring something.', '获得东西的行为；取得的过程。', 'n', 'He''s much more interested in the getting than in the giving.', '他对获得的东西比给予的东西更感兴趣。', 1
FROM vocabulary WHERE LOWER(term) = LOWER('getting')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- looking
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'looking', FALSE, FALSE, NULL, NULL, '/ˈlʊkɪŋ/', 'The act of directing one''s gaze, or appearing to be a certain way.', 'n,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'n_1', 'The act of directing one''s eyes toward something and perceiving it visually.', '用眼睛注视某物并视觉感知它的行为。', 'n', 'Looking at the stars, she felt calm.', '望着星星，她感到很平静。', 1
FROM vocabulary WHERE LOWER(term) = LOWER('looking')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'n_2', 'The act of searching visually.', '用眼睛搜寻的行为。', 'n', 'It took a lot of looking, but we found it.', '找了好一阵子，我们才找到它。', 2
FROM vocabulary WHERE LOWER(term) = LOWER('looking')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank)
SELECT id, 'adj_1', 'Appearing to be as specified.', '看起来像指定的（某种状态）。', 'adj', 'The dog had a sad, droopy-looking face.', '这只狗看起来很伤心，眼睛下垂。', 3
FROM vocabulary WHERE LOWER(term) = LOWER('looking')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

COMMIT;
