BEGIN;
DO $$ BEGIN IF (SELECT count(*) FROM user_meaning um JOIN meaning m ON m.id=um.meaning_id JOIN vocabulary v ON v.id=m.vocab_id WHERE LOWER(v.term) IN ('county','tried','paid','turned','seeing','limited','spent','gas','throughout','killing','spending','developing','focused','destroyed','spoke','dealing','scottish','tight','matt','childhood','document','facing','riding','meanwhile','percentage','tested','attended','bone','parking','strongly','reaching','happiness','illinois','entering','min','racist','sexy','comfort','deck','mum','abandoned','annoying','ownership','maintained','drove','rep','crossing','guidance','iowa','hiding','footage','implementation','massachusetts','anime','backed','classified','lover','missouri','mounted','realise','focusing','measured','racism','venue','baker','stealing','briefly','evaluation','holder','legally','developer','patience','nightmare','sandy','cole','dominated','victor','trophy','elderly','graduated','fascinating','stuart','washing','authorized','unfortunate','worrying','poorly','provider','acknowledged','breeding','pastor','shaking','quantum','bailey','interactive','traveled','warming','uncertainty','functioning','helmet','voltage','qualifying','reasoning','dash','distinctive','documented','straw','wicked','kitty','sequel','coupled','frustrating','merger','boarding','comedian','rapper','binary','limiting','quarterback','supervisor','trio','inability','satisfying','garlic','necessity','terribly','aftermath','combining','lad','lining','sadness','forehead','ninja','compilation','devastating','feminism','spinal','therapeutic','heroic','hut','poisoning','vanilla','practiced','strengthening','timothy','forwards','righteous','encouragement','faction','goalkeeper','hopeful','probable','starving','tucker','allergic','newborn','parental','unwanted','peach','cancellation','recycling','rover','remotely','erotic','covenant','lecturer','unarmed','grilled','instability','prophecy','respectful')) > 0 THEN RAISE EXCEPTION 'readers have progress on these words; aborting'; END IF; END $$;
DELETE FROM meaning WHERE vocab_id IN (SELECT id FROM vocabulary WHERE LOWER(term) IN ('county','tried','paid','turned','seeing','limited','spent','gas','throughout','killing','spending','developing','focused','destroyed','spoke','dealing','scottish','tight','matt','childhood','document','facing','riding','meanwhile','percentage','tested','attended','bone','parking','strongly','reaching','happiness','illinois','entering','min','racist','sexy','comfort','deck','mum','abandoned','annoying','ownership','maintained','drove','rep','crossing','guidance','iowa','hiding','footage','implementation','massachusetts','anime','backed','classified','lover','missouri','mounted','realise','focusing','measured','racism','venue','baker','stealing','briefly','evaluation','holder','legally','developer','patience','nightmare','sandy','cole','dominated','victor','trophy','elderly','graduated','fascinating','stuart','washing','authorized','unfortunate','worrying','poorly','provider','acknowledged','breeding','pastor','shaking','quantum','bailey','interactive','traveled','warming','uncertainty','functioning','helmet','voltage','qualifying','reasoning','dash','distinctive','documented','straw','wicked','kitty','sequel','coupled','frustrating','merger','boarding','comedian','rapper','binary','limiting','quarterback','supervisor','trio','inability','satisfying','garlic','necessity','terribly','aftermath','combining','lad','lining','sadness','forehead','ninja','compilation','devastating','feminism','spinal','therapeutic','heroic','hut','poisoning','vanilla','practiced','strengthening','timothy','forwards','righteous','encouragement','faction','goalkeeper','hopeful','probable','starving','tucker','allergic','newborn','parental','unwanted','peach','cancellation','recycling','rover','remotely','erotic','covenant','lecturer','unarmed','grilled','instability','prophecy','respectful'));
-- ============================================================
-- vocabulary + meaning seed data
-- Source : redo_171_final.json
-- Generated: 2026-10-01 19:44:16 by scripts/json_to_sql.py (deterministic)
-- Terms : 171   Meanings: 259
-- Safe to re-run: ON CONFLICT DO NOTHING throughout.
-- ============================================================


-- county
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'county', FALSE, FALSE, NULL, NULL, '/ˈkaʊnti/', 'A region or district used for administrative purposes.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'In the United Kingdom, a region divided for local government.', '在英国，郡是指为了地方政府管理而划分的区域。', 'n', 'The county council is responsible for local services.', '郡议会负责提供地方服务。', 1, 'n#8563758'
FROM vocabulary WHERE LOWER(term) = LOWER('county')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- tried
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'tried', FALSE, FALSE, NULL, NULL, '/ˈtraɪd/', 'Tested and proven to be reliable or effective.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Having been tested and shown to be effective or accurate.', '经过测试并且被证明是有效或准确的。', 'adj', 'This is a tried and true method for baking bread.', '这是烘烤面包的经过验证的可靠方法。', 1, 'a#1900263'
FROM vocabulary WHERE LOWER(term) = LOWER('tried')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- paid
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'paid', FALSE, FALSE, NULL, NULL, '/peɪd/', 'Receiving compensation for work or services.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Receiving money or compensation for work or services.', '指为工作或服务而获得报酬。', 'adj', 'She has a paid job as a teacher.', '她是一名教师，有一份带薪工作。', 1, 'a#1712702'
FROM vocabulary WHERE LOWER(term) = LOWER('paid')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- turned
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'turned', FALSE, FALSE, NULL, NULL, '/tɜːrnd/', 'Positioned or rotated.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Rotated or moved around a central point.', '围绕中心点旋转或移动。', 'adj', 'The wheel turned smoothly.', '轮子平稳地转动。', 1, 'a#2476609'
FROM vocabulary WHERE LOWER(term) = LOWER('turned')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- seeing
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'seeing', FALSE, FALSE, NULL, NULL, '/ˈsiːɪŋ/', 'The ability to perceive with the eyes.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The ability to see; the process of using your eyes to notice something.', '用眼睛观察和辨认事物，视觉能力。', 'n', 'Seeing is believing.', '眼见为实。', 1, 'n#5718807'
FROM vocabulary WHERE LOWER(term) = LOWER('seeing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- limited
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'limited', FALSE, FALSE, NULL, NULL, '/ˈlɪmɪtɪd/', 'Restricted in size, amount, or extent; not complete or unlimited.', 'adj,n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Restricted in size, amount, or extent; not general.', '指范围或数量受到限制，不是普遍的。', 'adj', 'The company has a limited budget for advertising.', '公司用于广告的预算有限。', 1, 'a#1417858'
FROM vocabulary WHERE LOWER(term) = LOWER('limited')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Subject to restrictions or limitations.', '指受到限制或约束。', 'adj', 'There are limited options for travel during the holiday.', '在节假日期间，旅行选择有限。', 2, 'a#2009566'
FROM vocabulary WHERE LOWER(term) = LOWER('limited')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_3', 'Including only a portion or part of something.', '指只包含一部分，不是全部。', 'adj', 'The study included a limited number of participants.', '这项研究包括了少量的参与者。', 3, 'a#531396'
FROM vocabulary WHERE LOWER(term) = LOWER('limited')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A fast train or bus that makes only a few scheduled stops.', '指只在少数站点停车的快速火车或巴士。', 'n', 'He caught the limited to Chicago.', '他搭上了去芝加哥的特快列车。', 4, NULL
FROM vocabulary WHERE LOWER(term) = LOWER('limited')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- spent
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'spent', FALSE, FALSE, NULL, NULL, '/spɛnt/', 'Depleted of energy or resources.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Depleted of energy, force, or strength.', '形容某物或人失去了能量、力量或体力。', 'adj', 'The soil was spent after years of farming.', '多年的耕种后，这片土地失去了肥力。', 1, 'a#929382'
FROM vocabulary WHERE LOWER(term) = LOWER('spent')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- gas
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'gas', FALSE, FALSE, NULL, NULL, '/ɡæs/', 'A substance in a gaseous state or a flammable fuel.', 'n,v'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A state of matter that lacks a fixed shape or volume and can expand indefinitely.', '气体是一种物质状态，没有固定的形状或体积，可以无限膨胀。', 'n', 'The gas filled the entire balloon.', '气体充满了整个气球。', 1, 'n#14504664'
FROM vocabulary WHERE LOWER(term) = LOWER('gas')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'A volatile, flammable mixture of hydrocarbons derived from petroleum, used as fuel.', '指从石油中提取的、易燃易爆的碳氢化合物混合物，主要用作燃料。', 'n', 'He filled his car with gas.', '他给他的车加了油。', 2, 'n#14711074'
FROM vocabulary WHERE LOWER(term) = LOWER('gas')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_1', 'To attack someone with poison gas.', '用毒气攻击某人。', 'v', 'The soldiers gassed the enemy.', '士兵用毒气攻击了敌人。', 3, 'v#1127799'
FROM vocabulary WHERE LOWER(term) = LOWER('gas')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- throughout
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'throughout', FALSE, FALSE, NULL, NULL, '/θruˈaʊt/', 'During the whole of a period, extent, or space.', 'adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_1', 'During the whole of a period, extent, or space.', '表示在某个时间段、范围或空间内，持续存在或发生。', 'adv', 'Rain fell throughout the entire day.', '整天都在下雨。', 1, 'r#103637'
FROM vocabulary WHERE LOWER(term) = LOWER('throughout')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- killing
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'killing', FALSE, FALSE, NULL, NULL, '/ˈkɪlɪŋ/', 'An act or event resulting in death, or a large profit.', 'n,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'An event that results in someone''s death.', '指导致某人死亡的事件。', 'n', 'The killing shocked the entire community.', '这起死亡事件震惊了整个社区。', 1, 'n#7376176'
FROM vocabulary WHERE LOWER(term) = LOWER('killing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'A large profit, especially one made quickly.', '指巨大的利润，特别是快速获得的利润。', 'n', 'The company made a killing on the new product.', '公司在新产品上赚了很多钱。', 2, 'n#13280696'
FROM vocabulary WHERE LOWER(term) = LOWER('killing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Very funny; causing a lot of laughter.', '非常有趣，能引起很多笑声。', 'adj', 'He told a killing joke that made everyone laugh.', '他说了一个非常有趣的笑话，逗笑了大家。', 3, 'a#1270449'
FROM vocabulary WHERE LOWER(term) = LOWER('killing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- spending
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'spending', FALSE, FALSE, NULL, NULL, '/ˈspendɪŋ/', 'The act of spending money.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'The act of spending or disbursing money.', '指花费或支出金钱的行为。', 'n', 'We need to reduce our spending.', '我们需要减少我们的开支。', 1, 'n#1124470'
FROM vocabulary WHERE LOWER(term) = LOWER('spending')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'Money paid out; an amount spent.', '已支付的钱；花费的金额。', 'n', 'Their spending on entertainment was high.', '他们在娱乐方面的花费很高。', 2, 'n#13296311'
FROM vocabulary WHERE LOWER(term) = LOWER('spending')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- developing
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'developing', FALSE, FALSE, NULL, NULL, '/dɪˈveləpɪŋ/', 'Relating to societies undergoing industrialization.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Relating to countries or societies that are in the process of industrializing and becoming more modern.', '指那些正在经历工业化和变得更加现代化的国家或社会。', 'adj', 'The developing nation needs foreign investment to grow its economy.', '这个发展中国家需要外国投资来发展其经济。', 1, 'a#1305479'
FROM vocabulary WHERE LOWER(term) = LOWER('developing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- focused
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'focused', FALSE, FALSE, NULL, NULL, '/ˈfoʊkəst/', 'Adjusted to produce a clear, sharp image; in focus.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Clearly defined and sharp; in focus.', '清晰且锐利的；对焦的。', 'adj', 'The photographer adjusted the lens to get a focused image.', '摄影师调整镜头以获得清晰的图像。', 1, 'a#786415'
FROM vocabulary WHERE LOWER(term) = LOWER('focused')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- destroyed
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'destroyed', FALSE, FALSE, NULL, NULL, '/dɪˈstrɔɪd/', 'Utterly ruined or devastated.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Utterly ruined or devastated; spoiled or demolished.', '完全被毁坏或摧毁的；被破坏或拆毁的。', 'adj', 'The hurricane left the town completely destroyed.', '飓风使这个小镇完全被摧毁了。', 1, 'a#737862'
FROM vocabulary WHERE LOWER(term) = LOWER('destroyed')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Ruined morally or spiritually; crushed in spirit.', '在精神或心灵上被摧毁、击垮。', 'adj', 'He seemed like a destroyed man after the scandal.', '丑闻过后，他像是一个精神崩溃的人。', 2, 'a#1454181'
FROM vocabulary WHERE LOWER(term) = LOWER('destroyed')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- spoke
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'spoke', FALSE, FALSE, NULL, NULL, '/spoʊk/', 'A rod or member joining the hub to the rim of a wheel.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The part of a wheel that connects the center (hub) to the outer edge (rim).', '轮子中央部分（轮毂）和外缘（轮辋）之间的连接部件。', 'n', 'The mechanic replaced a broken spoke on the bicycle wheel.', '机械师更换了自行车轮子上断裂的一根辐条。', 1, 'n#4290516'
FROM vocabulary WHERE LOWER(term) = LOWER('spoke')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- dealing
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'dealing', FALSE, FALSE, NULL, NULL, '/ˈdiːlɪŋ/', 'The way one behaves or conducts business with others.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The way you behave and interact with people, especially in terms of honesty and fairness.', '指你与人交往的方式，尤其是在诚实和公平方面。', 'n', 'Her dealings with customers were always polite and respectful.', '她与客户的交往总是礼貌而得体。', 1, 'n#1137693'
FROM vocabulary WHERE LOWER(term) = LOWER('dealing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- scottish
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'scottish', FALSE, FALSE, NULL, NULL, '/ˈskɒtɪʃ/', 'Relating to Scotland or its people, culture, or language.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Relating to Scotland, its people, culture, or the Scottish dialect or Gaelic language.', '与苏格兰及其人民、文化或苏格兰方言、盖尔语相关的。', 'adj', 'She enjoys Scottish folk music.', '她喜欢苏格兰民谣。', 1, 'a#3036161'
FROM vocabulary WHERE LOWER(term) = LOWER('scottish')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- tight
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'tight', FALSE, FALSE, NULL, NULL, '/taɪt/', 'Closely constricted or firmly held.', 'adj,adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Constricting or closely fitted; not loose.', '形容东西很紧，没有松动空间。', 'adj', 'Her jeans were too tight and uncomfortable.', '她的牛仔裤太紧了，很不舒服。', 1, 'a#1450193'
FROM vocabulary WHERE LOWER(term) = LOWER('tight')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_1', 'Firmly or closely; with a strong grip.', '形容紧紧地抓住或握住。', 'adv', 'Hold tight to the railing.', '紧紧抓住栏杆。', 2, 'r#86892'
FROM vocabulary WHERE LOWER(term) = LOWER('tight')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- matt
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'matt', FALSE, FALSE, NULL, NULL, '/mæt/', 'Lacking shine or gloss; having a dull appearance.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Having a dull, non-glossy surface; not shiny.', '指表面没有光泽，看起来比较暗淡。', 'adj', 'The photograph had a matt finish, softening the colors.', '这张照片有哑光效果，使色彩变得柔和。', 1, 'a#284838'
FROM vocabulary WHERE LOWER(term) = LOWER('matt')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- childhood
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'childhood', FALSE, FALSE, NULL, NULL, '/ˈtʃaɪldhʊd/', 'The period of one''s life when one is a child.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The period of time in a person''s life when they are a child.', '指一个人童年时期，通常指从出生到青少年之间的时光。', 'n', 'She has many happy memories of her childhood.', '她有很多关于童年的美好回忆。', 1, 'n#15172057'
FROM vocabulary WHERE LOWER(term) = LOWER('childhood')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- document
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'document', FALSE, FALSE, NULL, NULL, '/ˈdɒkjʊmənt/', 'An official record or piece of writing providing information.', 'n,v'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'An official record or piece of writing that provides important information.', '这是一份正式的记录或书面文件，提供重要的信息。', 'n', 'The government released a document detailing the new policy.', '政府发布了一份详细说明新政策的文件。', 1, 'n#6481744'
FROM vocabulary WHERE LOWER(term) = LOWER('document')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'Anything that represents a person''s thoughts or ideas using symbols.', '任何用符号代表一个人思想或想法的东西。', 'n', 'The painting is a document of her feelings.', '这幅画是她当时情感的记录。', 2, 'n#3222161'
FROM vocabulary WHERE LOWER(term) = LOWER('document')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_1', 'To record details about something carefully and thoroughly.', '详细而彻底地记录关于某事的信息。', 'v', 'Scientists documented the effects of climate change.', '科学家记录了气候变化的影响。', 3, 'v#1004342'
FROM vocabulary WHERE LOWER(term) = LOWER('document')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- facing
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'facing', FALSE, FALSE, NULL, NULL, '/ˈfeɪsɪŋ/', 'A decorative or protective lining applied to a garment.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A strip of material sewn to the edge of clothing for decoration or to reinforce it.', '缝在衣服边缘的一条材料，用于装饰或加强边缘。', 'n', 'The dress had a delicate lace facing.', '这条裙子有精致的蕾丝贴边。', 1, 'n#3320750'
FROM vocabulary WHERE LOWER(term) = LOWER('facing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- riding
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'riding', FALSE, FALSE, NULL, NULL, '/ˈraɪdɪŋ/', 'The activity of riding a horse or traveling on horseback.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The sport of riding a horse, involving controlling its movements.', '指骑马这项运动，包括控制马匹的动作。', 'n', 'She enjoys riding horses in the countryside.', '她喜欢在乡下骑马。', 1, 'n#451320'
FROM vocabulary WHERE LOWER(term) = LOWER('riding')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- meanwhile
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'meanwhile', FALSE, FALSE, NULL, NULL, '/ˈmiːnˌwaɪl/', 'During the intervening time; at the same time but in another place.', 'adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_1', 'Happening at the same time but in a different place.', '同时发生，但地点不同。', 'adv', 'Meanwhile, the meeting continued in the conference room.', '与此同时，会议在会议室继续进行。', 1, 'r#65584'
FROM vocabulary WHERE LOWER(term) = LOWER('meanwhile')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- percentage
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'percentage', FALSE, FALSE, NULL, NULL, '/pərˈsɛntɪdʒ/', 'A proportion related to a whole, typically expressed as a fraction of 100.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A proportion in relation to a whole, usually expressed as parts per hundred.', '表示一个整体的比例，通常以百分比的形式表示。', 'n', 'The percentage of students who passed was 80%.', '通过考试的学生的百分比是80%。', 1, 'n#13839738'
FROM vocabulary WHERE LOWER(term) = LOWER('percentage')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'A share of profits, earnings, or interest owed to someone.', '属于或应属于个人或群体的资产；份额。', 'n', 'He wanted his percentage of the profits.', '他想要利润中的那份份额。', 2, 'n#13306199'
FROM vocabulary WHERE LOWER(term) = LOWER('percentage')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- tested
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'tested', FALSE, FALSE, NULL, NULL, '/ˈtɛstɪd/', 'Proven to be effective or reliable through testing.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Having been tried and shown to be effective or correct.', '经过测试并被证明是有效或正确的。', 'adj', 'This is a tested approach to solving the problem.', '这是一个经过验证的解决问题的方法。', 1, 'a#1900263'
FROM vocabulary WHERE LOWER(term) = LOWER('tested')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- attended
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'attended', FALSE, FALSE, NULL, NULL, '/əˈtɛndɪd/', 'Accompanied by music or other performers.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Accompanied by music or other performers.', '指伴随着音乐或其他表演者的状态。', 'adj', 'This attended arrangement calls for piano accompaniment.', '这个带伴奏的改编版本需要钢琴伴奏。', 1, 'a#2259797'
FROM vocabulary WHERE LOWER(term) = LOWER('attended')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- bone
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'bone', FALSE, FALSE, NULL, NULL, '/boʊn/', 'A hard tissue making up the skeleton.', 'n,v,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A hard, solid tissue forming the skeleton of vertebrates.', '构成脊椎动物骨骼的坚硬、固体组织。', 'n', 'The doctor examined her broken bone.', '医生检查了她骨折的骨头。', 1, 'n#5277400'
FROM vocabulary WHERE LOWER(term) = LOWER('bone')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'The porous calcified substance from which bones are made.', '构成骨头的多孔钙化物质。', 'n', 'Bone is composed mainly of calcium phosphate.', '骨头主要由磷酸钙构成。', 2, 'n#14782027'
FROM vocabulary WHERE LOWER(term) = LOWER('bone')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_3', 'A pale shade of white resembling bleached bone.', '一种像漂白骨头一样的白色色调。', 'n', 'The walls were painted a bone color.', '墙壁被涂成了骨白色。', 3, 'n#4968508'
FROM vocabulary WHERE LOWER(term) = LOWER('bone')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'v_1', 'Study intensively, as before an exam.', '在考试前进行深入学习。', 'v', 'I need to bone up on history before the test.', '我需要在考试前复习一下历史。', 4, 'v#607178'
FROM vocabulary WHERE LOWER(term) = LOWER('bone')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'v_2', 'Remove the bones from.', '去除骨头。', 'v', 'Bone the chicken before frying it.', '油炸鸡肉之前先去骨。', 5, 'v#197798'
FROM vocabulary WHERE LOWER(term) = LOWER('bone')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Made of or consisting of bone.', '由骨头组成的或含有骨头的。', 'adj', 'He collected antique bone buttons.', '他收集古董骨质纽扣。', 6, 'a#296790'
FROM vocabulary WHERE LOWER(term) = LOWER('bone')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- parking
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'parking', FALSE, FALSE, NULL, NULL, '/ˈpɑːrkɪŋ/', 'An area where vehicles can be left.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'An area where cars and other vehicles can be left.', '指车辆可以停放的区域。', 'n', 'We need to find some parking near the stadium.', '我们需要在体育馆附近找一些停车位。', 1, 'n#13800883'
FROM vocabulary WHERE LOWER(term) = LOWER('parking')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- strongly
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'strongly', FALSE, FALSE, NULL, NULL, '/ˈstrɔːŋli/', 'In a forceful or intense manner.', 'adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_1', 'In a forceful or emphatic way; with great intensity.', '用一种强有力或强调的方式；带有很大的强度。', 'adv', 'She strongly believes in the importance of education.', '她坚信教育的重要性。', 1, 'r#178775'
FROM vocabulary WHERE LOWER(term) = LOWER('strongly')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- reaching
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'reaching', FALSE, FALSE, NULL, NULL, '/ˈriːtʃɪŋ/', 'The act of extending a limb or body part.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The action of extending your arm or leg to touch or grab something.', '指伸出胳膊或腿去触摸或抓住某物这个动作。', 'n', 'Reaching for the top shelf hurt her shoulder.', '伸手去拿最上层的架子弄伤了她的肩膀。', 1, 'n#342069'
FROM vocabulary WHERE LOWER(term) = LOWER('reaching')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- happiness
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'happiness', FALSE, FALSE, NULL, NULL, '/ˈhæpɪnəs/', 'A state of well-being and joyful emotion.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A state of well-being characterized by emotions ranging from contentment to intense joy.', '一种幸福的状态，包含从满足到强烈的喜悦等各种情感。', 'n', 'She felt a deep happiness after seeing her family.', '看到家人后，她感到一种深深的幸福。', 1, 'n#14010908'
FROM vocabulary WHERE LOWER(term) = LOWER('happiness')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'Emotions experienced when in a state of well-being.', '当处于幸福状态时所体验到的情感。', 'n', 'Their happiness was evident in their smiles.', '他们的幸福从笑容中可见一斑。', 2, 'n#7541996'
FROM vocabulary WHERE LOWER(term) = LOWER('happiness')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- illinois
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'illinois', FALSE, FALSE, NULL, NULL, '/ˌɪlɪˈnɔɪs/', 'A member of an Algonquian people who originally lived in the Illinois region of North America.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A member of an Algonquian people who originally lived in the Illinois region of North America.', '指居住在北美伊利诺伊地区的一个阿尔冈昆部落的成员。', 'n', 'The Illinois people were known for skilled craftsmanship.', '伊利诺伊部落以其精湛的工艺而闻名。', 1, 'n#9677320'
FROM vocabulary WHERE LOWER(term) = LOWER('illinois')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- entering
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'entering', FALSE, FALSE, NULL, NULL, '/ˈɛntərɪŋ/', 'The act of going or coming into a place.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The action of moving into or inward.', '指向内部移动的动作。', 'n', 'Entering the tunnel felt dark and mysterious.', '进入隧道的感觉又黑又神秘。', 1, 'n#7384725'
FROM vocabulary WHERE LOWER(term) = LOWER('entering')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- min
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'min', FALSE, FALSE, NULL, NULL, '/mɪn/', 'A unit of time equal to 60 seconds, or one sixtieth of an hour.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A unit of time equal to 60 seconds, or one sixtieth of an hour.', '一分钟是60秒，或者一小时的六十分之一。', 'n', 'He finished the race in under 20 min.', '他在不到20分钟内完成了比赛。', 1, 'n#15259561'
FROM vocabulary WHERE LOWER(term) = LOWER('min')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- racist
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'racist', FALSE, FALSE, NULL, NULL, '/ˈreɪsɪst/', 'Prejudiced against or discriminating based on race.', 'n,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who believes that one racial group is superior to others.', '指那些相信某个种族比其他种族更优越的人。', 'n', 'He was labeled a racist for his comments.', '他因发表歧视性言论而被贴上种族主义者的标签。', 1, 'n#10522535'
FROM vocabulary WHERE LOWER(term) = LOWER('racist')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Showing or based on racial intolerance.', '表现出或基于种族偏见。', 'adj', 'The racist remarks were deeply offensive to many.', '这些种族主义言论深深地冒犯了许多人。', 2, 'a#1934682'
FROM vocabulary WHERE LOWER(term) = LOWER('racist')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- sexy
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'sexy', FALSE, FALSE, NULL, NULL, '/ˈsɛksi/', 'Arousing or intending to arouse sexual interest or desire.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Attractive in a way that suggests sexual desire or interest.', '指某人或某物具有吸引力，让人产生性方面的兴趣。', 'adj', 'She wore a sexy dress to the party.', '她穿了一条性感的裙子去参加派对。', 1, 'a#2138452'
FROM vocabulary WHERE LOWER(term) = LOWER('sexy')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- comfort
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'comfort', FALSE, FALSE, NULL, NULL, '/ˈkʌmfərt/', 'A state of ease and relaxation, or the act of providing solace.', 'n,v'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A state of being relaxed and free from pain or worry.', '指一种放松、舒适的状态，没有痛苦或担忧。', 'n', 'She found comfort in a warm bath.', '她在温暖的浴缸里找到了舒适。', 1, 'n#14468845'
FROM vocabulary WHERE LOWER(term) = LOWER('comfort')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'The act of consoling someone who is suffering.', '指安慰那些正在遭受痛苦的人的行为。', 'n', 'His words offered great comfort to her.', '他的话语给了她极大的安慰。', 2, 'n#1214157'
FROM vocabulary WHERE LOWER(term) = LOWER('comfort')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_1', 'To give someone emotional strength and support.', '指给予某人情感上的力量和支持。', 'v', 'Her friends comforted her after the loss.', '朋友们在她失去亲人后安慰了她。', 3, 'v#1818782'
FROM vocabulary WHERE LOWER(term) = LOWER('comfort')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- deck
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'deck', FALSE, FALSE, NULL, NULL, '/dɛk/', 'A platform or pack of cards, or to decorate something.', 'n,v'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'Any of various platforms built into a vessel.', '指船、轮船等船体上方的平台。', 'n', 'Passengers strolled along the deck of the ship.', '乘客们在船的甲板上散步。', 1, 'n#3172332'
FROM vocabulary WHERE LOWER(term) = LOWER('deck')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'A slang term for a small packet of an illegal drug.', '（俚语）指一包非法毒品。', 'n', 'He was arrested for selling decks on the street.', '他因在街上贩卖毒品而被捕。', 2, 'n#3172644'
FROM vocabulary WHERE LOWER(term) = LOWER('deck')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_3', 'A pack of 52 playing cards.', '指一副52张扑克牌。', 'n', 'He shuffled the deck and dealt the cards.', '他洗牌并发牌。', 3, 'n#7973335'
FROM vocabulary WHERE LOWER(term) = LOWER('deck')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_1', 'To be beautiful to look at; to adorn.', '（文学用语）使...显得美丽；装点。', 'v', 'Flowers decked the garden with vibrant color.', '鲜花把花园装点得色彩缤纷。', 4, 'v#2754802'
FROM vocabulary WHERE LOWER(term) = LOWER('deck')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_2', 'Decorate.', '装饰，布置。', 'v', 'We should deck the halls for Christmas.', '我们应该为圣诞节装饰大厅。', 5, 'v#1683875'
FROM vocabulary WHERE LOWER(term) = LOWER('deck')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_3', 'Knock down with force.', '（俚语）击倒，打倒。', 'v', 'He decked his opponent with a powerful punch.', '他用一记重拳击倒了他的对手。', 6, 'v#1415000'
FROM vocabulary WHERE LOWER(term) = LOWER('deck')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- mum
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'mum', FALSE, FALSE, NULL, NULL, '/mʌm/', 'An informal term for mother or a state of silence.', 'n,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'An informal way of saying ''mother''.', '一种非正式的称呼母亲的方式。', 'n', 'My mum is a great cook.', '我妈妈厨艺很好。', 1, 'n#10297825'
FROM vocabulary WHERE LOWER(term) = LOWER('mum')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'The obligation to remain silent; secrecy.', '保持沉默的义务；保密。', 'n', 'Mum''s the word!', '嘘！保密！', 2, 'n#4659702'
FROM vocabulary WHERE LOWER(term) = LOWER('mum')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Remaining silent when expected to speak.', '在应该说话时保持沉默的。', 'adj', 'The witness remained mum during the trial.', '审判期间，证人一直保持沉默。', 3, NULL
FROM vocabulary WHERE LOWER(term) = LOWER('mum')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- abandoned
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'abandoned', FALSE, FALSE, NULL, NULL, '/əˈbændənd/', 'left deserted or without care.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Left deserted or without inhabitants; no longer used or occupied.', '指被主人或居民遗弃的，不再使用或居住的。', 'adj', 'The abandoned house stood empty for years.', '那座废弃的房子已经空置多年。', 1, 'a#1315959'
FROM vocabulary WHERE LOWER(term) = LOWER('abandoned')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- annoying
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'annoying', FALSE, FALSE, NULL, NULL, '/əˈnɔɪɪŋ/', 'Causing irritation or annoyance.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Causing irritation or annoyance; unpleasant.', '让人感到烦躁或不愉快，令人讨厌。', 'adj', 'The constant buzzing was really annoying.', '那持续不断的嗡嗡声真的让人很烦。', 1, 'a#90253'
FROM vocabulary WHERE LOWER(term) = LOWER('annoying')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- ownership
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'ownership', FALSE, FALSE, NULL, NULL, '/ˈoʊnərʃɪp/', 'The state of legally owning or having control of property.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The relationship between someone who owns something and the thing they own, including the right to give it to someone else.', '所有者和他们所拥有的东西之间的关系，包括将它转移给别人的权利。', 'n', 'The company has full ownership of the patents.', '该公司拥有这些专利的完全所有权。', 1, 'n#13261412'
FROM vocabulary WHERE LOWER(term) = LOWER('ownership')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- maintained
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'maintained', FALSE, FALSE, NULL, NULL, '/ˈmeɪnˌteɪnd/', 'kept in good condition or continued in use.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'kept in good condition; well-cared for.', '指某物被妥善保养，保持良好状态。', 'adj', 'The museum maintained the paintings in perfect condition.', '博物馆将这些画作保持在完美状态。', 1, 'a#741059'
FROM vocabulary WHERE LOWER(term) = LOWER('maintained')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- drove
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'drove', FALSE, FALSE, NULL, NULL, '/droʊv/', 'A group of animals moving together.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A group of animals, such as a herd or flock, moving together.', '一群动物，比如牛群或鸟群，一起移动。', 'n', 'The drove of sheep followed the shepherd up the hill.', '羊群跟着牧羊人走上山。', 1, 'n#8201253'
FROM vocabulary WHERE LOWER(term) = LOWER('drove')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- rep
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'rep', FALSE, FALSE, NULL, NULL, '/rep/', 'An informal abbreviation of representative.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'An informal way to say ''representative''.', '“rep”是“representative”的非正式缩写，指代表、代理人。', 'n', 'She''s our company''s rep at the conference.', '她是我们在会议上的公司代表。', 1, 'n#9975423'
FROM vocabulary WHERE LOWER(term) = LOWER('rep')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- crossing
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'crossing', FALSE, FALSE, NULL, NULL, '/ˈkrɑːsɪŋ/', 'The act of traveling across something.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The action of going or traveling from one side to the other.', '指从一侧移动到另一侧的动作。', 'n', 'Their crossing of the desert took almost a week.', '他们穿越沙漠花了将近一周时间。', 1, 'n#298358'
FROM vocabulary WHERE LOWER(term) = LOWER('crossing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- guidance
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'guidance', FALSE, FALSE, NULL, NULL, '/ˈɡaɪdəns/', 'Help or advice in making a decision or taking an action.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'Advice or information offered to help someone make a choice or take action.', '指为了帮助某人做出选择或采取行动而提供的建议或信息。', 'n', 'She sought guidance from her teacher about her career.', '她向老师寻求关于职业发展的建议。', 1, 'n#6663446'
FROM vocabulary WHERE LOWER(term) = LOWER('guidance')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- iowa
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'iowa', FALSE, FALSE, NULL, NULL, '/ˈaɪoʊə/', 'A Native American people who originally lived in Iowa, Minnesota, and Missouri.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A Native American people originally living in Iowa, Minnesota, and Missouri.', '指原居住在爱荷华、明尼苏达和密苏里州的苏族人。', 'n', 'The Iowa tribe has a rich history and culture.', '爱荷华部落拥有丰富的历史和文化。', 1, 'n#9677453'
FROM vocabulary WHERE LOWER(term) = LOWER('iowa')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- hiding
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'hiding', FALSE, FALSE, NULL, NULL, '/ˈhaɪdɪŋ/', 'The act of concealing oneself or keeping something secret.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The act of keeping something secret.', '指隐藏或保守秘密的行为。', 'n', 'Hiding the evidence only made the investigation harder.', '隐藏证据只会让调查更加困难。', 1, 'n#1050836'
FROM vocabulary WHERE LOWER(term) = LOWER('hiding')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- footage
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'footage', FALSE, FALSE, NULL, NULL, '/ˈfʊtɪdʒ/', 'Recorded video or film, often used in documentaries or news reports.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'Recorded video or film, often used in documentaries or news reports.', '指拍摄好的视频或电影，通常用于纪录片或新闻报道。', 'n', 'The news report included dramatic footage of the storm.', '新闻报道中包含了关于风暴的震撼视频片段。', 1, 'n#3383439'
FROM vocabulary WHERE LOWER(term) = LOWER('footage')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- implementation
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'implementation', FALSE, FALSE, NULL, NULL, '/ˌɪmplɪmenˈteɪʃən/', 'The act of carrying out a plan or order.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The act of doing something to achieve a goal or follow instructions.', '指为了达成目标或执行指令而采取的行动。', 'n', 'The project''s implementation was successful.', '项目的实施非常成功。', 1, 'n#1129700'
FROM vocabulary WHERE LOWER(term) = LOWER('implementation')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- massachusetts
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'massachusetts', FALSE, FALSE, NULL, NULL, '/ˌmæsəˈtʃuːsɪts/', 'A Native American people and their language formerly inhabiting Massachusetts Bay.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A Native American people who formerly lived around Massachusetts Bay.', '指的是曾经居住在马萨诸塞湾地区的阿尔冈昆部落的人民。', 'n', 'The history of the Massachusetts people is often overlooked.', '马萨诸塞特人的历史常常被忽视。', 1, 'n#9680078'
FROM vocabulary WHERE LOWER(term) = LOWER('massachusetts')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- anime
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'anime', FALSE, FALSE, NULL, NULL, '/ˈænɪmeɪ/', 'A style of Japanese animation with distinctive art and often mature themes.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'Japanese animation characterized by stylized colorful art and often adult themes.', '指日本开发的动画风格，以程式化的彩色美术和经常包含成人主题为特征。', 'n', 'She enjoys watching anime after school.', '她放学后喜欢看动漫。', 1, 'n#6629056'
FROM vocabulary WHERE LOWER(term) = LOWER('anime')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- backed
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'backed', FALSE, FALSE, NULL, NULL, '/ˈbækt/', 'Having a back or backing.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Having a back or backing, often of a particular material or design.', '指某物有背部或衬托层，通常是特定材质。', 'adj', 'The exercise mat was backed with non-slip rubber.', '这块健身垫背面衬有防滑橡胶材料。', 1, 'a#201618'
FROM vocabulary WHERE LOWER(term) = LOWER('backed')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- classified
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'classified', FALSE, FALSE, NULL, NULL, '/ˈklæsɪfaɪd/', 'Arranged or sorted into classes or categories.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Arranged or sorted into groups or categories.', '按照类别或组别进行排列或分类。', 'adj', 'The specimens were neatly classified by species.', '这些标本按物种被整齐分类。', 1, 'a#416228'
FROM vocabulary WHERE LOWER(term) = LOWER('classified')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Marked as secret and not available to the public.', '被标记为秘密，不对公众开放。', 'adj', 'The documents were classified for national security.', '这些文件因为国家安全而被列为机密。', 2, 'a#416747'
FROM vocabulary WHERE LOWER(term) = LOWER('classified')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- lover
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'lover', FALSE, FALSE, NULL, NULL, '/ˈlʌvər/', 'A person who loves someone or is loved by someone.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who feels love for another person, or who is loved by someone.', '指对另一个人有爱意的人，或者被某人所爱的人。', 'n', 'He was rumored to be her secret lover.', '据传他是她的秘密情人。', 1, 'n#9645472'
FROM vocabulary WHERE LOWER(term) = LOWER('lover')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- missouri
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'missouri', FALSE, FALSE, NULL, NULL, '/məˈzʊri/', 'A Siouan-speaking Native American people who historically lived in Missouri.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A Native American people who historically lived along the Missouri River in Missouri.', '密苏里人是居住在密苏里河沿岸的苏族人。', 'n', 'The Missouri tribe had a rich culture and history.', '密苏里部落拥有丰富的文化和历史。', 1, 'n#9680663'
FROM vocabulary WHERE LOWER(term) = LOWER('missouri')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- mounted
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'mounted', FALSE, FALSE, NULL, NULL, '/ˈmaʊntɪd/', 'Attached to or supported by a structure.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Attached to a support or structure, ready for use.', '指被安装在支架或其他结构上，以便使用的状态。', 'adj', 'The telescope was mounted on a sturdy tripod.', '望远镜被安装在一个坚固的三脚架上。', 1, 'a#160532'
FROM vocabulary WHERE LOWER(term) = LOWER('mounted')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- realise
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'realise', FALSE, FALSE, NULL, NULL, '/ˈriːəlaɪz/', 'To obtain as profit from a sale or business transaction.', 'v'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_1', 'To earn money from a business deal or job.', '通过商业交易或工作来赚取金钱。', 'v', 'She realised a handsome profit on the sale.', '她从这笔买卖中赚取了丰厚的利润。', 1, 'v#2294200'
FROM vocabulary WHERE LOWER(term) = LOWER('realise')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- focusing
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'focusing', FALSE, FALSE, NULL, NULL, '/ˈfoʊkəsɪŋ/', 'The act of concentrating attention or energy on something.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The concentration of attention or energy on a particular subject or task.', '指注意力或精力的集中，专注于某件事或任务。', 'n', 'She is focusing on finishing her thesis this month.', '她这个月正专注于完成她的论文。', 1, 'n#5712641'
FROM vocabulary WHERE LOWER(term) = LOWER('focusing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- measured
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'measured', FALSE, FALSE, NULL, NULL, '/ˈmɛʒərd/', 'Carefully planned or executed.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Carefully thought out in advance; deliberate.', '形容事先经过深思熟虑、有计划性的。', 'adj', 'He gave a measured response to the difficult question.', '他对那个棘手的问题给出了谨慎的回答。', 1, 'a#1340892'
FROM vocabulary WHERE LOWER(term) = LOWER('measured')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- racism
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'racism', FALSE, FALSE, NULL, NULL, '/ˈreɪsɪzəm/', 'The belief that some races are superior to others, often resulting in prejudice and discrimination.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The belief that one''s own race is superior to others, often leading to prejudice and discrimination.', '认为自己所属种族天生优于其他种族的信念，常导致偏见和歧视。', 'n', 'His racism led him to discriminate in hiring.', '他的种族主义导致他在招聘中进行歧视。', 1, 'n#6213493'
FROM vocabulary WHERE LOWER(term) = LOWER('racism')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- venue
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'venue', FALSE, FALSE, NULL, NULL, '/ˈvɛnjuː/', 'The place where an event or meeting happens.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The place where an event or meeting happens.', '指某个活动或会议举行的地点。', 'n', 'The concert venue was packed with excited fans.', '音乐会场馆挤满了兴奋的粉丝。', 1, 'n#8695366'
FROM vocabulary WHERE LOWER(term) = LOWER('venue')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- baker
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'baker', FALSE, FALSE, NULL, NULL, '/ˈbeɪkər/', 'A person who makes and sells baked goods.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who bakes goods for sale in a bakery or other business.', '指在面包店或其他商业场所制作糕点、面包等食品的人。', 'n', 'The baker made a delicious chocolate cake for the party.', '面包师为聚会做了一个美味的巧克力蛋糕。', 1, 'n#9853011'
FROM vocabulary WHERE LOWER(term) = LOWER('baker')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- stealing
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'stealing', FALSE, FALSE, NULL, NULL, '/ˈstiːlɪŋ/', 'The act of taking something from someone unlawfully.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The act of taking something from someone without their permission and against the law.', '指未经允许、非法地从别人那里拿走东西的行为。', 'n', 'The store installed cameras to prevent stealing.', '商店安装了摄像头以防止盗窃。', 1, 'n#782543'
FROM vocabulary WHERE LOWER(term) = LOWER('stealing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- briefly
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'briefly', FALSE, FALSE, NULL, NULL, '/ˈbriːfli/', 'For a short time or in a concise way.', 'adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_1', 'For a short time; lasting only a moment.', '表示时间很短，只持续了一小会儿。', 'adv', 'She briefly visited her hometown.', '她短暂地回了一趟家乡。', 1, 'r#93232'
FROM vocabulary WHERE LOWER(term) = LOWER('briefly')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- evaluation
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'evaluation', FALSE, FALSE, NULL, NULL, '/ɪˌvæljuˈeɪʃən/', 'The process of determining the value or worth of something.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The process of finding out how valuable or important something is.', '确定某物价值或重要性的过程。', 'n', 'The teacher gave an evaluation of the students'' work.', '老师对学生的作业进行了评估。', 1, 'n#876484'
FROM vocabulary WHERE LOWER(term) = LOWER('evaluation')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- holder
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'holder', FALSE, FALSE, NULL, NULL, '/ˈhoʊldər/', 'A person or device that holds or possesses something.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A device or fixture designed to hold or support an object.', '指用来固定或支撑物品的装置。', 'n', 'She hung her coat on the towel holder.', '她把外套挂在毛巾架上。', 1, 'n#3530634'
FROM vocabulary WHERE LOWER(term) = LOWER('holder')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'A person who possesses or controls something.', '指拥有或控制某物的人。', 'n', 'He is the holder of the world record.', '他是世界纪录的保持者。', 2, 'n#10199809'
FROM vocabulary WHERE LOWER(term) = LOWER('holder')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_3', 'A person in possession of a financial instrument, such as a bond or note.', '指持有票据、债券或产权证明书的人。', 'n', 'The holder of this bond earns regular interest.', '这张债券的持有人可获得定期利息。', 3, 'n#10199542'
FROM vocabulary WHERE LOWER(term) = LOWER('holder')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- legally
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'legally', FALSE, FALSE, NULL, NULL, '/ˈliːɡəli/', 'In accordance with the law.', 'adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_1', 'In a way that follows the rules and laws of a country.', '符合国家法律法规的方式。', 'adv', 'They legally married after obtaining the necessary documents.', '他们取得必要文件后合法结婚了。', 1, 'r#253289'
FROM vocabulary WHERE LOWER(term) = LOWER('legally')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- developer
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'developer', FALSE, FALSE, NULL, NULL, '/dɪˈveləpər/', 'A person or company that develops land, typically for building houses or businesses.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who creates or prepares land for building houses or businesses.', '指开发房地产的人，通常为住宅或商业用途准备土地。', 'n', 'The developer built a new shopping center downtown.', '这位开发商在市中心建造了一个新的购物中心。', 1, 'n#10029716'
FROM vocabulary WHERE LOWER(term) = LOWER('developer')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- patience
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'patience', FALSE, FALSE, NULL, NULL, '/ˈpeɪʃəns/', 'The capacity to accept or tolerate delay, trouble, or suffering.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The ability to remain calm and understanding when dealing with delays or someone''s mistakes.', '指在面对延误或他人失误时，能够保持冷静和理解的能力。', 'n', 'Teaching children requires a lot of patience.', '教孩子需要很多耐心。', 1, 'n#4647895'
FROM vocabulary WHERE LOWER(term) = LOWER('patience')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- nightmare
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'nightmare', FALSE, FALSE, NULL, NULL, '/ˈnaɪtmɛər/', 'A very unpleasant dream.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A very bad or frightening experience, like a bad dream.', '一种非常糟糕或可怕的经历，就像一场噩梦。', 'n', 'The project was a nightmare to complete.', '这个项目完成起来简直是一场噩梦。', 1, 'n#13959709'
FROM vocabulary WHERE LOWER(term) = LOWER('nightmare')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- sandy
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'sandy', FALSE, FALSE, NULL, NULL, '/ˈsændi/', 'Resembling or containing sand.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Consisting of, covered with, or resembling sand.', '由沙子构成、覆盖着沙子，或像沙子一样的。', 'adj', 'The beach was covered in sandy soil.', '沙滩上覆盖着沙质土壤。', 1, 'a#245055'
FROM vocabulary WHERE LOWER(term) = LOWER('sandy')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Of hair color; pale yellowish to yellowish brown.', '指头发颜色，呈淡黄色至黄褐色。', 'adj', 'She has sandy brown hair.', '她有一头沙棕色的头发。', 2, 'a#143308'
FROM vocabulary WHERE LOWER(term) = LOWER('sandy')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- cole
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'cole', FALSE, FALSE, NULL, NULL, '/koʊl/', 'A hardy cabbage with coarse, curly leaves.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A type of cabbage that has tough, curly leaves and does not form a head.', '这是一种卷叶甘蓝，叶子粗糙卷曲，不会形成球状的叶球。', 'n', 'She planted cole in her garden last spring.', '她去年春天在花园里种了卷叶甘蓝。', 1, 'n#11897445'
FROM vocabulary WHERE LOWER(term) = LOWER('cole')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- dominated
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'dominated', FALSE, FALSE, NULL, NULL, '/ˈdɒmɪneɪtɪd/', 'Controlled or ruled by superior authority or power.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Controlled or ruled by a more powerful person or force.', '指被更强大的人或力量所控制或支配的。', 'adj', 'The company was dominated by a single, powerful executive.', '这家公司被一位强势的高管所掌控。', 1, 'a#601830'
FROM vocabulary WHERE LOWER(term) = LOWER('dominated')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- victor
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'victor', FALSE, FALSE, NULL, NULL, '/ˈvɪktər/', 'A person who wins a contest, competition, or battle.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who wins a contest, competition, or battle.', '指在比赛、竞争或战斗中获胜的人。', 'n', 'She was the victor of the city marathon.', '她是这场城市马拉松的胜利者。', 1, 'n#10772598'
FROM vocabulary WHERE LOWER(term) = LOWER('victor')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- trophy
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'trophy', FALSE, FALSE, NULL, NULL, '/ˈtroʊfi/', 'An award given to commemorate a victory or achievement.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A prize given to someone who has won a competition or achieved something important, especially in sports or war.', '这是颁发给在比赛中获胜或取得重要成就的人的奖品，尤其是在体育或战争中。', 'n', 'The team proudly displayed their trophy after winning the championship.', '球队在赢得冠军后自豪地展示了他们的奖杯。', 1, 'n#6722381'
FROM vocabulary WHERE LOWER(term) = LOWER('trophy')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- elderly
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'elderly', FALSE, FALSE, NULL, NULL, '/ˈeldərli/', 'Advanced in years; old.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Old or advanced in age.', '年纪大的，年老的。', 'adj', 'The elderly woman enjoyed reading in the garden.', '那位年长的女士喜欢在花园里读书。', 1, 'a#1648667'
FROM vocabulary WHERE LOWER(term) = LOWER('elderly')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- graduated
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'graduated', FALSE, FALSE, NULL, NULL, '/ˈɡrædʒuˌeɪtɪd/', 'Divided or marked into degrees or stages.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Having markings or divisions indicating degrees or measurements.', '带有表示度量或刻度标记的。', 'adj', 'The graduated cylinder showed the exact water level.', '量筒上的刻度显示了精确的水位。', 1, 'a#3159654'
FROM vocabulary WHERE LOWER(term) = LOWER('graduated')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- fascinating
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'fascinating', FALSE, FALSE, NULL, NULL, '/ˈfæsɪˌneɪtɪŋ/', 'Evoking intense interest as if by a spell.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Able to attract and keep someone''s attention.', '能够吸引并保持某人的注意力。', 'adj', 'The documentary was a fascinating look at wildlife.', '这部纪录片对野生动物的观察非常引人入胜。', 1, 'a#1347019'
FROM vocabulary WHERE LOWER(term) = LOWER('fascinating')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- stuart
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'stuart', FALSE, FALSE, NULL, NULL, '/ˈstuːərt/', 'A member of the royal family that ruled Scotland and England.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A member of the royal Stuart family, which ruled Scotland and England.', '指苏格兰和英格兰的斯图亚特王朝的成员。', 'n', 'King Charles II was a Stuart.', '查理二世国王是斯图亚特家族的一员。', 1, 'n#10684894'
FROM vocabulary WHERE LOWER(term) = LOWER('stuart')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- washing
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'washing', FALSE, FALSE, NULL, NULL, '/ˈwɑːʃɪŋ/', 'The act of cleaning something with soap and water.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The process of cleaning something, usually with soap and water.', '用肥皂和水清洗东西的过程。', 'n', 'Washing the dishes took longer than expected.', '洗碗花的时间比预期长。', 1, 'n#256577'
FROM vocabulary WHERE LOWER(term) = LOWER('washing')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- authorized
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'authorized', FALSE, FALSE, NULL, NULL, '/ˈɔːθəraɪzd/', 'Given power or right to act; sanctioned.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Given power or permission by someone in authority.', '由有权势的人授予权力或允许。', 'adj', 'The authorized representative signed the contract.', '授权代表签署了合同。', 1, 'a#179875'
FROM vocabulary WHERE LOWER(term) = LOWER('authorized')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- unfortunate
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'unfortunate', FALSE, FALSE, NULL, NULL, '/ʌnˈfɔːrtʃənət/', 'Marked by bad luck or suffering; regrettable.', 'adj,n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Experiencing bad luck or misfortune; resulting in negative consequences.', '经历不幸或厄运，导致负面结果。', 'adj', 'It was unfortunate that the flight was canceled.', '航班取消真是不幸的事情。', 1, 'a#1053161'
FROM vocabulary WHERE LOWER(term) = LOWER('unfortunate')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Regrettable or unsuitable; expressing something inappropriate.', '令人遗憾或不合适；表达不恰当的事情。', 'adj', 'His unfortunate comment offended many people.', '他那不恰当的评论冒犯了很多人。', 2, 'a#1004966'
FROM vocabulary WHERE LOWER(term) = LOWER('unfortunate')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A person who suffers misfortune.', '遭受不幸的人。', 'n', 'He was an unfortunate who lost his job in the recession.', '他是一个在经济衰退中失业的不幸者。', 3, NULL
FROM vocabulary WHERE LOWER(term) = LOWER('unfortunate')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- worrying
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'worrying', FALSE, FALSE, NULL, NULL, '/ˈwɜːriɪŋ/', 'Causing anxiety or concern.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Causing feelings of worry, anxiety, or distress.', '让人感到担忧、焦虑或不安。', 'adj', 'The worrying news made her feel very upset.', '令人担忧的消息让她感到非常不安。', 1, 'a#1192929'
FROM vocabulary WHERE LOWER(term) = LOWER('worrying')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- poorly
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'poorly', FALSE, FALSE, NULL, NULL, '/ˈpʊərli/', 'In an unsatisfactory or inadequate manner.', 'adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_1', 'In an unsatisfactory or inadequate way; not well.', '以一种不令人满意或不足道的方式；不太好。', 'adv', 'He performed poorly on the test.', '他在考试中表现得不太好。', 1, 'r#11978'
FROM vocabulary WHERE LOWER(term) = LOWER('poorly')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- provider
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'provider', FALSE, FALSE, NULL, NULL, '/prəˈvaɪdər/', 'Someone who supplies a service or commodity, or provides for someone''s needs.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person or company that supplies a particular service or commodity.', '指提供某种服务或商品的个人或公司。', 'n', 'The internet provider offers fast and reliable service.', '互联网服务提供商提供快速可靠的服务。', 1, 'n#10696710'
FROM vocabulary WHERE LOWER(term) = LOWER('provider')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- acknowledged
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'acknowledged', FALSE, FALSE, NULL, NULL, '/əkˈnɒlɪdʒd/', 'recognized or generally accepted.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Formally recognized or admitted as true or valid.', '被正式承认或接受为真实或有效的。', 'adj', 'She is the acknowledged expert in this field.', '她是该领域的公认专家。', 1, 'a#27360'
FROM vocabulary WHERE LOWER(term) = LOWER('acknowledged')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- breeding
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'breeding', FALSE, FALSE, NULL, NULL, '/ˈbriːdɪŋ/', 'The quality of being refined and well-mannered, or the process of producing offspring.', 'n,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'Elegance and refinement in manner and expression.', '指举止和表达方式的优雅和精致。', 'n', 'She had breeding and grace that commanded respect.', '她举止优雅，令人敬佩。', 1, 'n#4820771'
FROM vocabulary WHERE LOWER(term) = LOWER('breeding')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'Good upbringing, especially knowledge of social behavior.', '良好的教养，特别是对社会行为的了解。', 'n', 'Her breeding showed in her impeccable manners.', '她的良好教养体现在她无可挑剔的礼仪上。', 2, 'n#4929077'
FROM vocabulary WHERE LOWER(term) = LOWER('breeding')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_3', 'The process of helping someone grow up to be an accepted member of the community.', '帮助某人成长为社区公认成员的教养过程。', 'n', 'Breeding a child well requires patience and guidance.', '教养孩子需要耐心和引导。', 3, 'n#1131853'
FROM vocabulary WHERE LOWER(term) = LOWER('breeding')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Producing offspring or set aside for producing offspring.', '产生后代或专门用于产生后代的。', 'adj', 'The breeding stock was carefully selected.', '繁殖种群经过精心挑选。', 4, 'a#1084756'
FROM vocabulary WHERE LOWER(term) = LOWER('breeding')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- pastor
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'pastor', FALSE, FALSE, NULL, NULL, '/ˈpæstər/', 'A religious leader who conducts worship services.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A religious leader who conducts worship services.', '指主持宗教仪式和服务的宗教领袖。', 'n', 'The pastor gave a sermon to the congregation.', '牧师向会众布道。', 1, 'n#10003102'
FROM vocabulary WHERE LOWER(term) = LOWER('pastor')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- shaking
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'shaking', FALSE, FALSE, NULL, NULL, '/ˈʃeɪkɪŋ/', 'The act of causing something to move with quick, back-and-forth movements.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The action of making something move back and forth or up and down quickly.', '使某物快速地上下或前后移动的动作。', 'n', 'The earthquake caused violent shaking throughout the city.', '地震导致全市剧烈震动。', 1, 'n#348006'
FROM vocabulary WHERE LOWER(term) = LOWER('shaking')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- quantum
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'quantum', FALSE, FALSE, NULL, NULL, '/ˈkwɒntəm/', 'A discrete quantity of energy or other physical property.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A discrete, minimal amount of a physical property, such as energy.', '在量子理论中，物理属性（如能量）的最小离散单位。', 'n', 'The photon carries a single quantum of energy.', '光子携带一个能量量子。', 1, 'n#5864332'
FROM vocabulary WHERE LOWER(term) = LOWER('quantum')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- bailey
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'bailey', FALSE, FALSE, NULL, NULL, '/ˈbeɪli/', 'A courtyard or outer wall of a castle.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The open area or courtyard within a castle, often surrounded by walls.', '城堡内的一个开放区域或庭院，通常被墙壁包围。', 'n', 'The soldiers gathered in the bailey before the attack.', '士兵们在攻击前聚集在庭院里。', 1, 'n#2778818'
FROM vocabulary WHERE LOWER(term) = LOWER('bailey')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- interactive
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'interactive', FALSE, FALSE, NULL, NULL, '/ˌɪntərˈæktɪv/', 'capable of having an effect on each other.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Capable of acting on or influencing each other.', '指事物之间可以相互影响，互相作用。', 'adj', 'The interactive display allowed children to learn through play.', '这个互动式显示屏让孩子们在玩耍中学习。', 1, 'a#1953056'
FROM vocabulary WHERE LOWER(term) = LOWER('interactive')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- traveled
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'traveled', FALSE, FALSE, NULL, NULL, '/ˈtrævəld/', 'Having experience of many places through travel.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Having been to many places; experienced in travel.', '形容一个人去过很多地方，并且因此有了丰富的旅行经验。', 'adj', 'She was a well-traveled woman with many stories to tell.', '她是一位旅行经历丰富的女士，有很多故事可以讲。', 1, 'a#639231'
FROM vocabulary WHERE LOWER(term) = LOWER('traveled')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- warming
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'warming', FALSE, FALSE, NULL, NULL, '/ˈwɔːrmɪŋ/', 'The process of becoming warmer or the sensation of heat.', 'n,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The process of becoming warmer; a rising temperature.', '指温度逐渐升高，变得更暖的过程。', 'n', 'The global warming trend is a serious concern.', '全球变暖的趋势是一个严重的问题。', 1, 'n#13513079'
FROM vocabulary WHERE LOWER(term) = LOWER('warming')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'Warm weather following a freeze, during which snow and ice melt.', '指冰冻之后出现的温暖天气，冰雪因此融化。', 'n', 'A sudden warming melted the snow on the roads.', '突然的回暖融化了路上的积雪。', 2, 'n#11502540'
FROM vocabulary WHERE LOWER(term) = LOWER('warming')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Imparting heat; producing warmth.', '指使物体变暖，产生温暖感觉的。', 'adj', 'The warming fire made the room cozy.', '温暖的炉火使房间变得舒适。', 3, 'a#2540264'
FROM vocabulary WHERE LOWER(term) = LOWER('warming')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- uncertainty
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'uncertainty', FALSE, FALSE, NULL, NULL, '/ʌnˈsɜːrtɪni/', 'a state of being unsure or dependent on chance.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A state of being unsettled, doubtful, or relying on chance.', '指一种不确定、犹豫不决或依赖偶然状态。', 'n', 'There was uncertainty about the election results.', '选举结果存在不确定性。', 1, 'n#4764142'
FROM vocabulary WHERE LOWER(term) = LOWER('uncertainty')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- functioning
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'functioning', FALSE, FALSE, NULL, NULL, '/ˈfʌŋkʃənɪŋ/', 'Performing or able to perform a task or function.', 'adj,n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Working or able to work in the way it should.', '能够正常工作或运转，符合其预期功能。', 'adj', 'The functioning elevator made getting to the top easy.', '正常运行的电梯使到达顶层变得轻松。', 1, 'a#1095249'
FROM vocabulary WHERE LOWER(term) = LOWER('functioning')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The way something operates or works.', '某事物运作或运行的方式。', 'n', 'The device''s functioning improved after the repair.', '设备的运行状况在维修后有所改善。', 2, 'n#13546752'
FROM vocabulary WHERE LOWER(term) = LOWER('functioning')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- helmet
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'helmet', FALSE, FALSE, NULL, NULL, '/ˈhɛlmɪt/', 'A protective covering for the head.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A protective head covering made of a hard material, worn for safety.', '一种由坚硬材料制成的头盔，用于保护头部安全。', 'n', 'He wore a helmet while riding his bicycle.', '他骑自行车时戴着头盔。', 1, 'n#3518281'
FROM vocabulary WHERE LOWER(term) = LOWER('helmet')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- voltage
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'voltage', FALSE, FALSE, NULL, NULL, '/ˈvɒltɪdʒ/', 'The electrical potential difference between two points in a circuit.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The difference in electrical potential between two points, measured in volts.', '两点之间的电势差，以伏特为单位。', 'n', 'The voltage of the battery is 12 volts.', '这节电池的电压是12伏特。', 1, 'n#11543971'
FROM vocabulary WHERE LOWER(term) = LOWER('voltage')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- qualifying
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'qualifying', FALSE, FALSE, NULL, NULL, '/ˈkwɒlɪfaɪɪŋ/', 'The act of meeting a requirement or passing a test to gain eligibility.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The act of successfully completing a test or meeting a requirement.', '指成功地通过考试或满足要求，从而获得参与或进入下一阶段的资格。', 'n', 'His qualifying score allowed him to enter the competition.', '他的达标成绩让他获得了参赛资格。', 1, 'n#66395'
FROM vocabulary WHERE LOWER(term) = LOWER('qualifying')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- reasoning
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'reasoning', FALSE, FALSE, NULL, NULL, '/ˈriːzənɪŋ/', 'The process of thinking logically and drawing conclusions.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The process of thinking in a clear, logical way.', '指清晰、有逻辑地思考的过程。', 'n', 'Careful reasoning helped her solve the puzzle.', '仔细的思考帮助她解决了谜题。', 1, 'n#5780353'
FROM vocabulary WHERE LOWER(term) = LOWER('reasoning')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- dash
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'dash', FALSE, FALSE, NULL, NULL, '/dæʃ/', 'To move or act with sudden haste or to break something into pieces.', 'n,v'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A quick run, often for exercise or enjoyment.', '一种快速的跑步，通常是为了锻炼或娱乐。', 'n', 'The kids went for a quick dash around the park.', '孩子们在公园里快速跑了一圈。', 1, 'n#295296'
FROM vocabulary WHERE LOWER(term) = LOWER('dash')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'A short, competitive race, typically at high speed.', '一种简短的、通常是高速的竞赛跑。', 'n', 'He won the 100-meter dash in record time.', '他以破纪录的成绩赢得了100米短跑比赛。', 2, 'n#7484183'
FROM vocabulary WHERE LOWER(term) = LOWER('dash')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_1', 'To run or move very quickly and often suddenly.', '快速地或突然地跑或移动。', 'v', 'She dashed across the street to catch the bus.', '她冲过马路去赶公交车。', 3, 'v#2065423'
FROM vocabulary WHERE LOWER(term) = LOWER('dash')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- distinctive
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'distinctive', FALSE, FALSE, NULL, NULL, '/dɪˈstɪŋktɪv/', 'Serving to distinguish; characteristic.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Having a quality that makes something easily recognizable or different from others.', '指某事物具有独特的品质，使其容易被辨认出来，并且与其它事物不同。', 'adj', 'The building''s distinctive architecture made it a landmark.', '这座建筑独特的建筑风格使其成为地标。', 1, 'a#358636'
FROM vocabulary WHERE LOWER(term) = LOWER('distinctive')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- documented
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'documented', FALSE, FALSE, NULL, NULL, '/ˈdɒkjəmɛntɪd/', 'Supported by documents or evidence.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Having evidence or records to support something; verified by documents.', '有文件或记录来支持某事；通过文件验证。', 'adj', 'The historian presented a documented account of the battle.', '历史学家提供了关于这场战役的详细记录。', 1, 'a#789846'
FROM vocabulary WHERE LOWER(term) = LOWER('documented')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- straw
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'straw', FALSE, FALSE, NULL, NULL, '/strɔː/', 'A fibrous stem of certain grasses, used for various purposes.', 'n,adj,v'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'Plant fiber used for making baskets, hats, or as animal feed.', '一种植物纤维，用于制作篮子、帽子，或作为动物饲料。', 'n', 'Farmers used straw to feed their cows during the winter.', '农民冬天用稻草喂养他们的牛。', 1, 'n#14984078'
FROM vocabulary WHERE LOWER(term) = LOWER('straw')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'The material consisting of seed coverings and small pieces of stem or leaves separated from the seeds.', '种子外壳和从种子中分离出来的茎或叶的小碎片组成的材料。', 'n', 'The field was covered in straw after the harvest.', '收割后，田地里覆盖着稻草。', 2, 'n#14830069'
FROM vocabulary WHERE LOWER(term) = LOWER('straw')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Having a pale yellow color similar to straw.', '呈现出类似稻草的淡黄色。', 'adj', 'The sun bleached her hair a pale straw color.', '阳光把她的头发晒成了淡稻草色。', 3, 'a#385354'
FROM vocabulary WHERE LOWER(term) = LOWER('straw')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_1', 'To cover something with straw.', '用稻草覆盖某物。', 'v', 'Farmers straw the stable floor every winter.', '农民每年冬天都会在马厩地面铺上稻草。', 4, 'v#1611244'
FROM vocabulary WHERE LOWER(term) = LOWER('straw')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- wicked
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'wicked', FALSE, FALSE, NULL, NULL, '/ˈwɪkɪd/', 'morally wrong or evil; extremely unpleasant.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Morally bad in principle or practice.', '在原则或行为上是不道德、邪恶的。', 'adj', 'His wicked actions hurt many innocent people.', '他邪恶的行为伤害了许多无辜的人。', 1, 'a#2523798'
FROM vocabulary WHERE LOWER(term) = LOWER('wicked')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Guilty of having committed sinful or unrighteous acts.', '犯下罪恶或不义行为的。', 'adj', 'The prophets warned that the wicked would be punished.', '先知们警告说，作恶之人将受到惩罚。', 2, 'a#2044938'
FROM vocabulary WHERE LOWER(term) = LOWER('wicked')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_3', 'Intensely or extremely bad, unpleasant, or severe.', '程度极其严重或令人不快的。', 'adj', 'The storm caused wicked damage along the coast.', '这场风暴给沿海地区造成了严重的破坏。', 3, 'a#1516947'
FROM vocabulary WHERE LOWER(term) = LOWER('wicked')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- kitty
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'kitty', FALSE, FALSE, NULL, NULL, '/ˈkɪti/', 'A young cat, especially a female one.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A young cat, especially a female cat.', '指小猫，通常是雌性猫。', 'n', 'The little kitty loves to play with yarn.', '这只小猫喜欢和毛线玩。', 1, 'n#2125600'
FROM vocabulary WHERE LOWER(term) = LOWER('kitty')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- sequel
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'sequel', FALSE, FALSE, NULL, NULL, '/ˈsiːkwəl/', 'something that follows or is continued from something else.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'Something that follows an earlier event or action.', '指在先前的事情或行动之后发生的事情。', 'n', 'The second chapter is a sequel to the first.', '第二章是第一章的后续。', 1, 'n#7310125'
FROM vocabulary WHERE LOWER(term) = LOWER('sequel')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- coupled
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'coupled', FALSE, FALSE, NULL, NULL, '/ˈkʌpld/', 'Joined or connected as a pair.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Joined or connected together, especially as a pair.', '作为一对连接或组合在一起的。', 'adj', 'The two pendulums are coupled by a spring.', '这两个摆通过一根弹簧连接在一起。', 1, 'a#2486686'
FROM vocabulary WHERE LOWER(term) = LOWER('coupled')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Connected by a link, as railway cars or trailer trucks.', '通过连接器连接在一起，例如火车车厢或拖车。', 'adj', 'The coupled railcars moved slowly along the track.', '连接在一起的车厢沿着轨道缓慢移动。', 2, 'a#569425'
FROM vocabulary WHERE LOWER(term) = LOWER('coupled')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- frustrating
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'frustrating', FALSE, FALSE, NULL, NULL, '/ˈfrʌstreɪtɪŋ/', 'Causing annoyance and disappointment.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Causing discouragement by making progress difficult.', '使人感到沮丧，因为阻碍了前进。', 'adj', 'The slow internet connection was frustrating.', '缓慢的网络连接让人感到沮丧。', 1, 'a#871066'
FROM vocabulary WHERE LOWER(term) = LOWER('frustrating')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- merger
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'merger', FALSE, FALSE, NULL, NULL, '/ˈmɜːrdʒər/', 'The combination of two or more companies into one.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The joining together of two or more businesses to form one larger company.', '指两家或多家公司合并成一家更大的公司。', 'n', 'The merger created a new industry leader.', '这次合并创造了一个新的行业领导者。', 1, 'n#1240989'
FROM vocabulary WHERE LOWER(term) = LOWER('merger')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- boarding
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'boarding', FALSE, FALSE, NULL, NULL, '/ˈbɔːrdɪŋ/', 'The process of passengers and crew getting onto a vehicle.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The act of passengers and crew getting aboard a ship or aircraft.', '乘客和船员登上船只或飞机的行为。', 'n', 'Boarding the plane was a chaotic experience.', '登上飞机是一次混乱的经历。', 1, 'n#59157'
FROM vocabulary WHERE LOWER(term) = LOWER('boarding')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'A structure made of boards.', '由木板构成的结构。', 'n', 'The shed was built from old wooden boarding.', '这个棚子是用旧木板搭建的。', 2, 'n#2860645'
FROM vocabulary WHERE LOWER(term) = LOWER('boarding')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- comedian
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'comedian', FALSE, FALSE, NULL, NULL, '/ˈkɒmɪdiən/', 'A performer who entertains by telling jokes or performing comical acts.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who entertains an audience by telling jokes and performing funny actions.', '指通过讲笑话和表演滑稽动作来娱乐观众的专业表演者。', 'n', 'The comedian made the audience laugh with his silly jokes.', '这位喜剧演员用他滑稽的笑话逗笑了观众。', 1, 'n#9959604'
FROM vocabulary WHERE LOWER(term) = LOWER('comedian')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- rapper
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'rapper', FALSE, FALSE, NULL, NULL, '/ˈræpər/', 'A musician who performs rap music.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who performs rap music, often improvising lyrics.', '指表演说唱音乐的人，通常即兴创作歌词。', 'n', 'The young rapper quickly gained a large following.', '这位年轻的说唱歌手很快获得了大量的粉丝。', 1, 'n#10527075'
FROM vocabulary WHERE LOWER(term) = LOWER('rapper')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- binary
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'binary', FALSE, FALSE, NULL, NULL, '/ˈbaɪnəri/', 'Relating to or using only two symbols, typically 0 and 1.', 'n,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A system of two stars that revolve around each other under their mutual gravitation.', '一个由两颗恒星组成的系统，它们在彼此的引力作用下相互旋转。', 'n', 'The telescope detected a binary star system.', '望远镜探测到一个双星系统。', 1, 'n#9243977'
FROM vocabulary WHERE LOWER(term) = LOWER('binary')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'A pre-compiled, pre-linked program that is ready to run under a given operating system.', '一个预先编译并链接好的程序，可以直接在特定的操作系统上运行。', 'n', 'The software developer created a binary for Windows.', '软件开发人员为Windows创建了一个二进制文件。', 2, 'n#6583139'
FROM vocabulary WHERE LOWER(term) = LOWER('binary')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Of or pertaining to a number system having 2 as its base.', '指以2为基数的数字系统。', 'adj', 'The computer uses a binary number system.', '计算机使用二进制数字系统。', 3, 'a#2675405'
FROM vocabulary WHERE LOWER(term) = LOWER('binary')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Consisting of two units, components, elements, or terms.', '由两个部分、成分、元素或术语组成的。', 'adj', 'Water is a binary compound of hydrogen and oxygen.', '水是由氢和氧组成的二元化合物。', 4, 'a#2224672'
FROM vocabulary WHERE LOWER(term) = LOWER('binary')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- limiting
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'limiting', FALSE, FALSE, NULL, NULL, '/ˈlɪmɪtɪŋ/', 'restricting or defining the scope of something.', 'adj,n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'The grammatical relation that exists when a word qualifies the meaning of a phrase.', '当一个词限定短语的含义时，所存在的语法关系。', 'n', 'Linguists use the term limiting to describe such modification.', '语言学家用“限定”这个术语来描述这种修饰关系。', 1, 'n#13823013'
FROM vocabulary WHERE LOWER(term) = LOWER('limiting')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Restricting the scope or freedom of action.', '限制范围或行动自由的。', 'adj', 'There are limiting beliefs holding her back.', '有一些限制性的信念阻碍着她。', 2, 'a#2011119'
FROM vocabulary WHERE LOWER(term) = LOWER('limiting')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Strictly limiting the reference of a modified word or phrase.', '严格限制被修饰的词语或短语的指代范围。', 'adj', 'The limiting clause narrowed the search.', '限制性条款缩小了搜索范围。', 3, 'a#2011481'
FROM vocabulary WHERE LOWER(term) = LOWER('limiting')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- quarterback
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'quarterback', FALSE, FALSE, NULL, NULL, '/ˈkwɔːrtərˌbæk/', 'The player who directs the offensive play in American football.', 'n,v'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A player in American football who leads the offensive team.', '橄榄球比赛中，领导进攻组的球员。', 'n', 'The quarterback threw a long pass to the receiver.', '四分卫向接球手投掷了一个长传球。', 1, 'n#10518401'
FROM vocabulary WHERE LOWER(term) = LOWER('quarterback')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_1', 'To play the position of quarterback in a football game.', '担任四分卫的角色，进行橄榄球比赛。', 'v', 'He will quarterback for the team this season.', '他将在本赛季担任该队的四分卫。', 2, 'v#1078763'
FROM vocabulary WHERE LOWER(term) = LOWER('quarterback')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- supervisor
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'supervisor', FALSE, FALSE, NULL, NULL, '/ˈsuːpərvɪzər/', 'A person who manages or directs others.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who oversees and directs the work of others.', '一个负责监督和指导他人工作的负责人。', 'n', 'The supervisor checked our progress on the project.', '主管检查了我们对项目的进展。', 1, 'n#10696316'
FROM vocabulary WHERE LOWER(term) = LOWER('supervisor')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- trio
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'trio', FALSE, FALSE, NULL, NULL, '/ˈtriːoʊ/', 'A group of three people or things.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The cardinal number three; the sum of one and two.', '表示基数三，即一加二之和。', 'n', 'In dominoes, a trio has three dots.', '在多米诺骨牌游戏中，三点牌被称为trio。', 1, 'n#13766184'
FROM vocabulary WHERE LOWER(term) = LOWER('trio')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- inability
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'inability', FALSE, FALSE, NULL, NULL, '/ɪnˈæbɪləti/', 'The state of being unable to do something.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The state of lacking the ability, especially mental ability, to do something.', '指缺乏做某事的能力，尤其是精神上的能力。', 'n', 'His inability to concentrate made studying difficult.', '他无法集中注意力，导致学习困难。', 1, 'n#5652767'
FROM vocabulary WHERE LOWER(term) = LOWER('inability')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- satisfying
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'satisfying', FALSE, FALSE, NULL, NULL, '/ˈsætɪsfaɪɪŋ/', 'Providing contentment or pleasure.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Giving a feeling of contentment and fulfillment; pleasing.', '让人感到满足和快乐，令人满意。', 'adj', 'The delicious meal was incredibly satisfying.', '这顿美味的饭菜非常令人满意。', 1, 'a#2088709'
FROM vocabulary WHERE LOWER(term) = LOWER('satisfying')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- garlic
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'garlic', FALSE, FALSE, NULL, NULL, '/ˈɡɑːrlɪk/', 'A bulbous herb used as a seasoning.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A bulbous herb native to central Asia, cultivated worldwide for its strong-flavored, edible bulb.', '一种原产于中亚的鳞茎草本植物，因其味道浓烈、可食用的鳞茎而被广泛种植。', 'n', 'Garlic grows well in cool, sunny climates.', '大蒜在凉爽、阳光充足的气候中生长良好。', 1, 'n#12455280'
FROM vocabulary WHERE LOWER(term) = LOWER('garlic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'The edible bulb of this plant, used as a pungent seasoning in cooking.', '这种植物可食用的鳞茎，用作烹饪中味道浓烈的调味料。', 'n', 'I added garlic to the pasta sauce.', '我把大蒜加到了意大利面酱里。', 2, 'n#7834253'
FROM vocabulary WHERE LOWER(term) = LOWER('garlic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- necessity
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'necessity', FALSE, FALSE, NULL, NULL, '/nɪˈsɛsɪti/', 'Something essential or indispensable.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The state of being absolutely necessary or essential.', '指某事物是绝对必要或不可或缺的状态。', 'n', 'Clean water is a necessity for survival.', '清洁的水是生存的必需品。', 1, 'n#14474157'
FROM vocabulary WHERE LOWER(term) = LOWER('necessity')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- terribly
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'terribly', FALSE, FALSE, NULL, NULL, '/ˈtɛrəbli/', 'Intensifying an adjective or adverb, or describing something done poorly.', 'adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_1', 'Used to intensify another adjective or adverb; very.', '用来加强另一个形容词或副词的程度，表示非常。', 'adv', 'The movie was terribly exciting.', '这部电影非常激动人心。', 1, 'r#55488'
FROM vocabulary WHERE LOWER(term) = LOWER('terribly')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- aftermath
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'aftermath', FALSE, FALSE, NULL, NULL, '/ˈæftərˌmæθ/', 'The consequences or results of an event, especially a catastrophic one.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The results or effects of an event, often a disaster.', '指事件，特别是灾难性事件发生后的结果或影响。', 'n', 'The aftermath of the storm was widespread damage.', '暴风雨后的影响是广泛的破坏。', 1, 'n#11431724'
FROM vocabulary WHERE LOWER(term) = LOWER('aftermath')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- combining
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'combining', FALSE, FALSE, NULL, NULL, '/kəmˈbaɪnɪŋ/', 'The process of uniting or merging things.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'An act or process of merging or joining things together.', '指将事物联合或合并在一起的行为或过程。', 'n', 'Combining the two companies created an industry giant.', '将两家公司合并，造就了一个行业巨头。', 1, 'n#7388403'
FROM vocabulary WHERE LOWER(term) = LOWER('combining')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- lad
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'lad', FALSE, FALSE, NULL, NULL, '/læd/', 'A boy or young man.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A boy or man; a familiar term of address to a young male.', '指年轻男子或男孩，一种亲切的称呼方式。', 'n', 'He was a cheerful lad.', '他是个活泼开朗的男孩。', 1, 'n#9927483'
FROM vocabulary WHERE LOWER(term) = LOWER('lad')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'A male child (a familiar term of address to a boy).', '指男孩，一种亲切的称呼。', 'n', 'Come here, lad.', '过来吧，孩子。', 2, 'n#9890635'
FROM vocabulary WHERE LOWER(term) = LOWER('lad')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- lining
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'lining', FALSE, FALSE, NULL, NULL, '/ˈlaɪnɪŋ/', 'A material used to cover or protect a surface.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A layer of material that protects the inner surface of something.', '指用来保护内部表面的材料层。', 'n', 'The lining of the box protected the fragile items.', '箱子的内衬保护了易碎的物品。', 1, 'n#3679093'
FROM vocabulary WHERE LOWER(term) = LOWER('lining')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- sadness
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'sadness', FALSE, FALSE, NULL, NULL, '/ˈsædnəs/', 'A feeling of unhappiness or sorrow.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'Feelings of unhappiness, disappointment, and grief.', '指不快乐、失望和悲伤的情绪。', 'n', 'The movie''s ending filled her with sadness.', '这部电影的结局让她充满了悲伤。', 1, 'n#7547828'
FROM vocabulary WHERE LOWER(term) = LOWER('sadness')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'The state of being sad.', '一种悲伤的状态。', 'n', 'She felt a deep sadness after the loss.', '失去后，她感到深深的悲伤。', 2, 'n#14012536'
FROM vocabulary WHERE LOWER(term) = LOWER('sadness')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_3', 'A quality of excessive mournfulness and lack of cheerfulness.', '一种过度悲伤和缺乏快乐的品质。', 'n', 'The poem captured the sadness of the era.', '这首诗捕捉了那个时代的悲伤。', 3, 'n#4638827'
FROM vocabulary WHERE LOWER(term) = LOWER('sadness')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- forehead
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'forehead', FALSE, FALSE, NULL, NULL, '/ˈfɔːrheɪd/', 'The part of the face above the eyes.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The part of your face above your eyes.', '额头是你的脸部眼睛上方的部分。', 'n', 'She wiped the sweat from her forehead.', '她把额头上的汗擦掉了。', 1, 'n#5610303'
FROM vocabulary WHERE LOWER(term) = LOWER('forehead')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- ninja
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'ninja', FALSE, FALSE, NULL, NULL, '/ˈnɪndʒə/', 'A skilled warrior trained in espionage, assassination, and martial arts.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A skilled warrior from Japan, trained in martial arts and often hired for secret missions.', '日本的一位武术家，接受过武术训练，通常被雇佣执行秘密任务。', 'n', 'The movie featured a ninja who was an expert in stealth.', '这部电影中的忍者精通隐蔽行动。', 1, 'n#10378588'
FROM vocabulary WHERE LOWER(term) = LOWER('ninja')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- compilation
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'compilation', FALSE, FALSE, NULL, NULL, '/ˌkɒmpɪˈleɪʃən/', 'a collection of related information or things.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'a collection of related information or things, often gathered from various sources.', '指从不同来源收集的相关信息或事物的集合。', 'n', 'The website is a compilation of user-submitted photos.', '这个网站是用户提交照片的汇编。', 1, 'n#6605303'
FROM vocabulary WHERE LOWER(term) = LOWER('compilation')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'the process of assembling and organizing information.', '指收集和整理信息的过程。', 'n', 'Data compilation took longer than we expected.', '数据整理花费的时间比我们预期的更长。', 2, 'n#1016673'
FROM vocabulary WHERE LOWER(term) = LOWER('compilation')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- devastating
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'devastating', FALSE, FALSE, NULL, NULL, '/ˈdɛvəˌsteɪtɪŋ/', 'Sharply critical or devastatingly effective, especially in speech, criticism, or argument.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Sharp and critical; able to strongly criticize or damage someone''s reputation.', '犀利且批判性的；能够强烈批评或损害某人的名誉。', 'adj', 'The critic''s devastating review hurt the play''s popularity.', '这位评论家的严厉评论损害了这部戏剧的受欢迎程度。', 1, 'a#2002147'
FROM vocabulary WHERE LOWER(term) = LOWER('devastating')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- feminism
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'feminism', FALSE, FALSE, NULL, NULL, '/ˈfɛmɪˌnɪzəm/', 'The belief in social, economic, and political equality for women.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A belief system that supports equal rights and opportunities for women.', '一种信仰体系，主张为女性争取平等的权利和机会。', 'n', 'Feminism challenges traditional gender roles.', '女权主义挑战了传统的性别角色。', 1, 'n#5976640'
FROM vocabulary WHERE LOWER(term) = LOWER('feminism')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- spinal
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'spinal', FALSE, FALSE, NULL, NULL, '/ˈspaɪnəl/', 'Relating to the spine or spinal cord.', 'adj,n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Of or relating to the spine or spinal cord.', '与脊椎或脊髓有关的。', 'adj', 'He suffered a spinal injury in the accident.', '他在事故中遭受了脊髓损伤。', 1, 'a#2895760'
FROM vocabulary WHERE LOWER(term) = LOWER('spinal')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'Anesthesia of the lower half of the body caused by injury to the spinal cord or by injecting an anesthetic.', '由于脊髓损伤或在脊髓周围注射麻醉剂而导致身体下半身麻醉的状态。', 'n', 'She underwent spinal anesthesia for the surgery.', '她接受了脊髓麻醉进行手术。', 2, 'n#14052887'
FROM vocabulary WHERE LOWER(term) = LOWER('spinal')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- therapeutic
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'therapeutic', FALSE, FALSE, NULL, NULL, '/ˌθɛrəˈpjuːtɪk/', 'Relating to or promoting healing and health.', 'adj,n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Tending to cure or restore to health.', '有治愈或恢复健康作用的。', 'adj', 'The therapeutic benefits of exercise are well-known.', '运动的治疗效果是众所周知的。', 1, 'a#1169487'
FROM vocabulary WHERE LOWER(term) = LOWER('therapeutic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Relating to or involved in therapy.', '与治疗相关的或涉及治疗的。', 'adj', 'A therapeutic approach to treating anxiety.', '一种治疗焦虑的方法。', 2, 'a#2925526'
FROM vocabulary WHERE LOWER(term) = LOWER('therapeutic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A medicine or therapy that cures disease or relieves pain.', '一种治愈疾病或缓解疼痛的药物或疗法。', 'n', 'She found the therapeutic massage very relaxing.', '她觉得这种理疗按摩非常放松。', 3, 'n#4081594'
FROM vocabulary WHERE LOWER(term) = LOWER('therapeutic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- heroic
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'heroic', FALSE, FALSE, NULL, NULL, '/hɪˈroʊɪk/', 'Impressive or inspiring, often relating to bravery or grandeur.', 'adj,n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Displaying qualities of courage, selflessness, and nobility.', '表现出英雄般的品质，例如勇敢、无私和高尚。', 'adj', 'The soldiers showed heroic bravery in battle.', '士兵们在战斗中表现出英勇的勇气。', 1, 'a#252000'
FROM vocabulary WHERE LOWER(term) = LOWER('heroic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Remarkable and impressive, often in size or scale.', '令人印象深刻，通常指规模很大或非常突出。', 'adj', 'The building was of heroic proportions.', '这座建筑规模宏大。', 2, 'a#1388944'
FROM vocabulary WHERE LOWER(term) = LOWER('heroic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A verse form suitable for epic or elevated themes.', '一种适合用于史诗或崇高主题的诗歌形式。', 'n', 'The poem was written in heroic verse.', '这首诗是用英雄体写成的。', 3, NULL
FROM vocabulary WHERE LOWER(term) = LOWER('heroic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- hut
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'hut', FALSE, FALSE, NULL, NULL, '/hʌt/', 'a small, simple, often makeshift dwelling or shelter.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A small, simple, often makeshift dwelling or shelter.', '一种小而简陋的住所或避难所，通常是用临时搭建的材料建造的。', 'n', 'The shepherd lived in a small hut on the hillside.', '牧羊人在山坡上的一间小木屋里生活。', 1, 'n#3552234'
FROM vocabulary WHERE LOWER(term) = LOWER('hut')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- poisoning
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'poisoning', FALSE, FALSE, NULL, NULL, '/ˈpɔɪzənɪŋ/', 'The physiological state caused by a poison or the act of poisoning someone.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The harmful physical condition caused by exposure to a poison or toxic substance.', '身体因毒素或有毒物质而产生的有害状态。', 'n', 'The doctor treated the patient for poisoning.', '医生为病人治疗中毒。', 1, 'n#14533314'
FROM vocabulary WHERE LOWER(term) = LOWER('poisoning')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'The deliberate act of giving poison to someone or an animal to cause death.', '蓄意给某人或动物下毒，致其死亡的行为。', 'n', 'He was charged with the poisoning of his neighbor''s dog.', '他被指控给邻居家的狗投毒。', 2, 'n#225605'
FROM vocabulary WHERE LOWER(term) = LOWER('poisoning')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- vanilla
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'vanilla', FALSE, FALSE, NULL, NULL, '/vəˈnɪlə/', 'A flavoring or extract derived from vanilla beans, or relating to the flavor of vanilla.', 'n,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'Any of several tropical climbing orchids of the genus Vanilla, grown for their fragrant seed pods.', '香草属的热带攀援兰科植物，因其芳香的种荚而被栽培。', 'n', 'The vanilla plant thrives in warm, humid climates.', '香草植物在温暖潮湿的气候中生长良好。', 1, 'n#12107056'
FROM vocabulary WHERE LOWER(term) = LOWER('vanilla')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'A flavoring made from vanilla beans steeped in alcohol, or an imitation of it.', '用酒精浸泡香草豆制成的调味料，或其仿制品。', 'n', 'She added a teaspoon of vanilla extract to the batter.', '她在面糊中加入了一茶匙香草精。', 2, 'n#7844783'
FROM vocabulary WHERE LOWER(term) = LOWER('vanilla')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_3', 'The distinctive fragrant flavor characteristic of vanilla beans.', '香草豆特有的芳香味道。', 'n', 'The ice cream had a rich vanilla flavor.', '这款冰淇淋有浓郁的香草味。', 3, 'n#5724409'
FROM vocabulary WHERE LOWER(term) = LOWER('vanilla')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Flavored with vanilla.', '用香草调味的。', 'adj', 'He ordered a scoop of vanilla ice cream.', '他点了一勺香草冰淇淋。', 4, 'a#2833957'
FROM vocabulary WHERE LOWER(term) = LOWER('vanilla')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Plain and ordinary, without any special features.', '普通平淡，没有任何特别之处。', 'adj', 'This phone is just the vanilla model, nothing special.', '这款手机只是普通基础型号，没什么特别的。', 5, 'a#1798634'
FROM vocabulary WHERE LOWER(term) = LOWER('vanilla')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- practiced
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'practiced', FALSE, FALSE, NULL, NULL, '/ˈpræktɪst/', 'Having or showing skill and expertise through training and experience.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Having or showing skill or expertise gained through training and experience.', '通过训练和经验获得的技能或专长。', 'adj', 'She is a practiced pianist with years of training.', '她是一位经过多年训练的熟练钢琴家。', 1, 'a#2234002'
FROM vocabulary WHERE LOWER(term) = LOWER('practiced')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- strengthening
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'strengthening', FALSE, FALSE, NULL, NULL, '/ˈstrɛŋθənɪŋ/', 'The process of becoming or making something stronger.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The process of becoming stronger or more secure.', '变得更强壮或更稳固的过程。', 'n', 'Months of therapy went into strengthening her left arm.', '她经过几个月的治疗来增强左臂的力量。', 1, 'n#7441824'
FROM vocabulary WHERE LOWER(term) = LOWER('strengthening')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- timothy
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'timothy', FALSE, FALSE, NULL, NULL, '/ˈtɪməθi/', 'A grass used for hay, common in northern regions.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A tall grass with cylindrical seed spikes, widely grown for hay in northern regions.', '一种长有圆柱形穗的高大草本植物，常在北方地区种植用作干草。', 'n', 'Farmers grow timothy grass to feed their livestock.', '农民种植提摩西草来喂养家畜。', 1, 'n#12151066'
FROM vocabulary WHERE LOWER(term) = LOWER('timothy')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- forwards
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'forwards', FALSE, FALSE, NULL, NULL, '/ˈfɔːrwərdz/', 'Toward the front or ahead.', 'adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_1', 'At, to, or toward the front.', '朝前方，向前方位置。', 'adv', 'She stepped forwards to greet the guests.', '她向前走了一步，迎接宾客。', 1, 'r#74907'
FROM vocabulary WHERE LOWER(term) = LOWER('forwards')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_2', 'In a forward direction; onward.', '向前方向移动；继续前进。', 'adv', 'The train lurched forwards as it started moving.', '火车启动时猛地向前一冲。', 2, 'r#67665'
FROM vocabulary WHERE LOWER(term) = LOWER('forwards')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- righteous
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'righteous', FALSE, FALSE, NULL, NULL, '/ˈraɪtʃəs/', 'Conforming to moral principles; morally right.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Conforming to moral principles or accepted standards of justice; virtuous.', '符合道德原则或公认的正义标准；正直的。', 'adj', 'The righteous man lived a life of integrity.', '那个正直的人一生诚实守信。', 1, 'a#2043985'
FROM vocabulary WHERE LOWER(term) = LOWER('righteous')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Morally justified; deserving of approval.', '在道德上有正当理由的；值得认可的。', 'adj', 'He felt righteous indignation at the injustice.', '他对这种不公正感到义愤填膺。', 2, 'a#1553236'
FROM vocabulary WHERE LOWER(term) = LOWER('righteous')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- encouragement
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'encouragement', FALSE, FALSE, NULL, NULL, '/ɪnˈkʌrɪdʒmənt/', 'The act of giving support or hope.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A statement or action that shows approval and support.', '表示赞同和支持的言语或行动。', 'n', 'Her encouragement helped me finish the race.', '她的鼓励帮助我完成了比赛。', 1, 'n#6704187'
FROM vocabulary WHERE LOWER(term) = LOWER('encouragement')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- faction
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'faction', FALSE, FALSE, NULL, NULL, '/ˈfækʃən/', 'A group with a particular aim or character.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A small, often secretive clique that seeks power through scheming or intrigue.', '一个秘密的小团体，常通过阴谋诡计谋求权力。', 'n', 'The rebel faction plotted to overthrow the government.', '这个反叛派系密谋推翻政府。', 1, 'n#8258719'
FROM vocabulary WHERE LOWER(term) = LOWER('faction')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- goalkeeper
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'goalkeeper', FALSE, FALSE, NULL, NULL, '/ˈɡoʊlˌkiːpər/', 'A player who defends the goal in sports like soccer or hockey.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'The player positioned to stop the ball or puck from entering the goal.', '足球或冰球比赛中，负责阻止球进入球门的队员。', 'n', 'The goalkeeper made a fantastic save.', '守门员扑出了一个精彩的球。', 1, 'n#10153521'
FROM vocabulary WHERE LOWER(term) = LOWER('goalkeeper')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- hopeful
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'hopeful', FALSE, FALSE, NULL, NULL, '/ˈhoʊpfəl/', 'Feeling or expressing hope; likely to be successful.', 'adj,n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Feeling or expressing hope; full of hope.', '心怀希望或表达希望的；充满希望的。', 'adj', 'She was hopeful about her exam results.', '她对自己的考试成绩抱有希望。', 1, 'a#1231403'
FROM vocabulary WHERE LOWER(term) = LOWER('hopeful')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Likely to turn out well; promising.', '很有可能有好结果的；前景看好的。', 'adj', 'The new project looks very hopeful.', '这个新项目看起来很有希望。', 2, 'a#177648'
FROM vocabulary WHERE LOWER(term) = LOWER('hopeful')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'An ambitious and aspiring young person.', '有抱负、渴望成功的年轻人。', 'n', 'He''s one of the hopefuls in the upcoming election.', '他是即将举行的选举中的一位有望获胜者。', 3, NULL
FROM vocabulary WHERE LOWER(term) = LOWER('hopeful')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- probable
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'probable', FALSE, FALSE, NULL, NULL, '/ˈprɑːbəbəl/', 'Likely to happen or be true, but not certain.', 'adj,n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Likely to happen or be true, but not certain.', '很有可能发生或为真，但尚不确定。', 'adj', 'There''s a probable chance of rain tomorrow.', '明天很可能会下雨。', 1, 'a#1416084'
FROM vocabulary WHERE LOWER(term) = LOWER('probable')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Seeming likely to occur in the future.', '看起来很可能在未来发生的。', 'adj', 'The probable outcome is a long, difficult negotiation.', '可能的结果是一场漫长而艰难的谈判。', 2, 'a#1414991'
FROM vocabulary WHERE LOWER(term) = LOWER('probable')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who is likely to be selected or chosen.', '很有可能被选中或录用的人。', 'n', 'She''s a probable candidate for the job.', '她很可能是这份工作的候选人。', 3, 'n#10477590'
FROM vocabulary WHERE LOWER(term) = LOWER('probable')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- starving
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'starving', FALSE, FALSE, NULL, NULL, '/ˈstɑːrvɪŋ/', 'Experiencing or showing the effects of extreme hunger.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Experiencing extreme hunger; in urgent need of food.', '极度饥饿，急需食物。', 'adj', 'The starving child needed immediate help.', '那个饥饿的孩子需要立即的帮助。', 1, 'a#2309019'
FROM vocabulary WHERE LOWER(term) = LOWER('starving')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- tucker
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'tucker', FALSE, FALSE, NULL, NULL, '/ˈtʌkər/', 'To exhaust or wear out completely.', 'v,n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'verb_1', 'To wear out completely; to exhaust.', '使精疲力尽，耗尽体力。', 'v', 'The long hike really tuckered me out.', '那次长途徒步让我累得精疲力尽。', 1, 'v#75174'
FROM vocabulary WHERE LOWER(term) = LOWER('tucker')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who sews tucks (folds) into fabric.', '在布料上缝制褶皱的裁缝工人。', 'n', 'The tucker carefully stitched the hem of the dress.', '这位裁缝小心地缝好了裙子的下摆。', 2, 'n#10752405'
FROM vocabulary WHERE LOWER(term) = LOWER('tucker')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'A detachable piece of linen or lace worn over the bust of a low-cut dress.', '一种可拆卸的亚麻或蕾丝饰物，佩戴在低领连衣裙的胸前。', 'n', 'She added a delicate lace tucker to her gown.', '她在礼服上加了一个精致的蕾丝胸饰。', 3, 'n#4502478'
FROM vocabulary WHERE LOWER(term) = LOWER('tucker')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- allergic
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'allergic', FALSE, FALSE, NULL, NULL, '/əˈlɜːrdʒɪk/', 'Suffering from or characterized by an allergy.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Caused by or relating to an allergic reaction.', '由过敏反应引起的或与之相关的。', 'adj', 'He had an allergic reaction to the peanuts.', '他对花生过敏，产生了过敏反应。', 1, 'a#2623070'
FROM vocabulary WHERE LOWER(term) = LOWER('allergic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Having an allergy to a specific substance.', '对某种特定物质有过敏反应的。', 'adj', 'Many children are allergic to pollen.', '许多孩子对花粉过敏。', 2, 'a#2369499'
FROM vocabulary WHERE LOWER(term) = LOWER('allergic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- newborn
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'newborn', FALSE, FALSE, NULL, NULL, '/ˈnuːˌbɔːrn/', 'A recently born baby or something recently created.', 'n,adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'A baby from birth to about four weeks old.', '出生到大约四周大的婴儿。', 'n', 'The hospital welcomed several newborns today.', '医院今天迎接了几个新生儿。', 1, 'n#10372747'
FROM vocabulary WHERE LOWER(term) = LOWER('newborn')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Recently born.', '刚出生的。', 'adj', 'She held the newborn infant gently.', '她轻轻地抱着这个新生儿。', 2, 'a#1653626'
FROM vocabulary WHERE LOWER(term) = LOWER('newborn')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_2', 'Recently created or come into existence.', '最近出现或产生的。', 'adj', 'The company just launched a newborn product line.', '该公司刚推出了一个全新的产品线。', 3, 'a#1646166'
FROM vocabulary WHERE LOWER(term) = LOWER('newborn')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- parental
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'parental', FALSE, FALSE, NULL, NULL, '/pəˈrɛntəl/', 'Relating to or characteristic of a parent.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Relating to, or showing the care typical of, a parent.', '与父母有关，或表现出父母般的关怀。', 'adj', 'The school requires parental consent for field trips.', '学校要求家长同意才能参加校外活动。', 1, 'a#1726746'
FROM vocabulary WHERE LOWER(term) = LOWER('parental')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- unwanted
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'unwanted', FALSE, FALSE, NULL, NULL, '/ʌnˈwɑːntɪd/', 'Not wanted or needed.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Not wanted, needed, or welcome.', '不需要、不受欢迎的。', 'adj', 'We donated the unwanted clothes to charity.', '我们把不需要的衣服捐给了慈善机构。', 1, 'a#2537893'
FROM vocabulary WHERE LOWER(term) = LOWER('unwanted')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- peach
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'peach', FALSE, FALSE, NULL, NULL, '/piːtʃ/', 'A sweet, juicy fruit or, informally, an attractive woman.', 'n,v'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'An especially attractive or appealing woman.', '特别有吸引力或迷人的女性。', 'n', 'He thought she was a real peach.', '他觉得她是个大美人。', 1, 'n#10633512'
FROM vocabulary WHERE LOWER(term) = LOWER('peach')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'A round, juicy fruit with fuzzy skin and sweet yellow or whitish flesh.', '一种表皮有绒毛、果肉甜美呈黄色或白色的多汁圆形水果。', 'n', 'She ate a delicious peach for breakfast.', '她早餐吃了一个美味的桃子。', 2, 'n#7766980'
FROM vocabulary WHERE LOWER(term) = LOWER('peach')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'v_1', 'To inform against someone to the authorities; to betray.', '向当局告发某人；出卖某人。', 'v', 'Don''t peach on your friends!', '不要告发你的朋友！', 3, NULL
FROM vocabulary WHERE LOWER(term) = LOWER('peach')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- cancellation
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'cancellation', FALSE, FALSE, NULL, NULL, '/ˌkænsəˈleɪʃən/', 'The act of calling off an arrangement or revoking something.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'The act of calling off a planned event or arrangement.', '取消已计划的活动或安排的行为。', 'n', 'The cancellation of the flight was due to bad weather.', '航班是因恶劣天气而取消的。', 1, 'n#233253'
FROM vocabulary WHERE LOWER(term) = LOWER('cancellation')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'A formal statement that revokes or voids something.', '正式撤销或宣告某事无效的声明。', 'n', 'His cancellation of the contract was legally binding.', '他取消合同的声明具有法律约束力。', 2, 'n#7221802'
FROM vocabulary WHERE LOWER(term) = LOWER('cancellation')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- recycling
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'recycling', FALSE, FALSE, NULL, NULL, '/ˈriːsaɪklɪŋ/', 'Materials that are used or discarded and can be processed for reuse.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'Materials that are used or discarded and can be processed for reuse.', '指被使用过或丢弃的、可以被重新处理用于制造新产品的材料。', 'n', 'We sort our paper and plastic for recycling.', '我们将纸张和塑料分类，以便回收利用。', 1, 'n#14606023'
FROM vocabulary WHERE LOWER(term) = LOWER('recycling')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- rover
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'rover', FALSE, FALSE, NULL, NULL, '/ˈroʊvər/', 'Someone who travels or wanders from place to place.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_1', 'Someone who leads a wandering, unsettled life.', '指过着四处游荡、居无定所生活的人。', 'n', 'He was a rover, never staying in one place for long.', '他是个漂泊者，很少在一个地方久留。', 1, 'n#10785347'
FROM vocabulary WHERE LOWER(term) = LOWER('rover')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'n_2', 'An adult member of the Boy Scouts movement.', '英国童子军组织中的成年成员（罗浮童子军）。', 'n', 'The rover helped the younger scouts with their activities.', '这位罗浮童子军帮助年幼的童子军开展活动。', 2, 'n#10560541'
FROM vocabulary WHERE LOWER(term) = LOWER('rover')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- remotely
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'remotely', FALSE, FALSE, NULL, NULL, '/rɪˈmoʊtli/', 'To a slight or distant degree; in a remote manner.', 'adv'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adv_1', 'In a distant or detached way; from afar.', '指从远处，或以一种疏远、不直接的方式。', 'adv', 'She works remotely from her home office.', '她在家庭办公室远程工作。', 1, 'r#442738'
FROM vocabulary WHERE LOWER(term) = LOWER('remotely')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- erotic
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'erotic', FALSE, FALSE, NULL, NULL, '/ɪˈrɒtɪk/', 'Relating to or tending to arouse sexual desire.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Designed to cause sexual feelings; sexually stimulating.', '指能引起性欲的，具有性刺激作用的。', 'adj', 'The film contained some erotic scenes.', '这部电影含有一些情色场景。', 1, 'a#2139460'
FROM vocabulary WHERE LOWER(term) = LOWER('erotic')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- covenant
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'covenant', FALSE, FALSE, NULL, NULL, '/ˈkʌvənənt/', 'A formal agreement or contract, especially between nations or with God.', 'n,v'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A formal, written agreement between two or more parties, often nations.', '两国或多方之间达成的正式书面协议或盟约。', 'n', 'The two nations signed a covenant to maintain peace.', '两国签署了一项维护和平的盟约。', 1, 'n#6785061'
FROM vocabulary WHERE LOWER(term) = LOWER('covenant')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_2', 'In the Bible, an agreement between God and his people, involving promises and required behavior.', '在《圣经》中，上帝与其子民之间立下的盟约，包含应许与应尽的义务。', 'n', 'The Old Testament describes God''s covenant with Abraham.', '《旧约》描述了上帝与亚伯拉罕立下的圣约。', 2, 'n#6537579'
FROM vocabulary WHERE LOWER(term) = LOWER('covenant')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'v_1', 'To enter into a covenant.', '订立协议或盟约。', 'v', 'The parties covenanted to share resources fairly.', '双方约定共同公平分享资源。', 3, NULL
FROM vocabulary WHERE LOWER(term) = LOWER('covenant')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- lecturer
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'lecturer', FALSE, FALSE, NULL, NULL, '/ˈlɛktʃərər/', 'A person who delivers lectures, often at a university.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A person who gives lectures, especially at a university.', '在大学等机构讲授课程或讲座的人。', 'n', 'The lecturer spoke passionately about ancient history.', '这位讲师热情地讲述了古代历史。', 1, 'n#10271919'
FROM vocabulary WHERE LOWER(term) = LOWER('lecturer')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- unarmed
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'unarmed', FALSE, FALSE, NULL, NULL, '/ʌnˈɑːrmd/', 'Not having or using weapons.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Not having or using weapons; without arms.', '指没有携带或使用武器，处于没有武装的状态。', 'adj', 'The police found the suspect unarmed and hiding.', '警察发现嫌疑人没有携带武器，正藏身躲避。', 1, 'a#144185'
FROM vocabulary WHERE LOWER(term) = LOWER('unarmed')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- grilled
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'grilled', FALSE, FALSE, NULL, NULL, '/ɡrɪld/', 'Cooked by radiant heat, typically over a grill.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Cooked using radiant heat, like from a grill.', '用烤架或类似方式以辐射热烹饪的。', 'adj', 'We had grilled chicken for dinner.', '我们晚餐吃了烤鸡。', 1, 'a#619652'
FROM vocabulary WHERE LOWER(term) = LOWER('grilled')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- instability
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'instability', FALSE, FALSE, NULL, NULL, '/ˌɪnstəˈbɪləti/', 'A state of being unstable or unreliable.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'A situation where things are not settled or secure; a lack of stability.', '指事物不稳定、不安全的状态，缺乏稳定性。', 'n', 'The country faced political instability after the elections.', '选举过后，该国陷入了政治动荡。', 1, 'n#13999106'
FROM vocabulary WHERE LOWER(term) = LOWER('instability')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- prophecy
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'prophecy', FALSE, FALSE, NULL, NULL, '/ˈprɑːfəsi/', 'A prediction of the future, often believed to be divinely inspired.', 'n'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'noun_1', 'Knowledge or insight into events that will happen in the future, often believed to come from a god or other supernatural power.', '对未来事件的预知或洞察，通常被认为来自神灵或超自然力量。', 'n', 'The ancient oracle offered a prophecy about the kingdom''s fate.', '古老的神谕预言了王国的命运。', 1, 'n#5783404'
FROM vocabulary WHERE LOWER(term) = LOWER('prophecy')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

-- respectful
INSERT INTO vocabulary (term, is_phrase, is_abbreviation, full_form, irregular_forms, pronunciation, definition_en, part_of_speech) VALUES (
  'respectful', FALSE, FALSE, NULL, NULL, '/rɪˈspɛktfəl/', 'Showing or deserving respect.', 'adj'
) ON CONFLICT DO NOTHING;
INSERT INTO meaning (vocab_id, sense_key, definition, explanation_zh, part_of_speech, example_sentence, example_sentence_zh, rank, wordnet_sense_id)
SELECT id, 'adj_1', 'Showing or expressing respect; polite and considerate.', '表现出尊重和礼貌，待人周到。', 'adj', 'He gave a respectful nod to the teacher.', '他恭敬地向老师点了点头。', 1, 'a#2001040'
FROM vocabulary WHERE LOWER(term) = LOWER('respectful')
ON CONFLICT (vocab_id, sense_key) DO NOTHING;

COMMIT;
