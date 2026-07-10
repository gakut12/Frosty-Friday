use schema DEMO_DB.PUBLIC;


-- データ準備
CREATE OR REPLACE TABLE sentence_comparison(sentence_1 VARCHAR, sentence_2 VARCHAR);

INSERT INTO sentence_comparison (sentence_1, sentence_2) VALUES
('The cat sat on the', 'The cat sat on thee'),
('Rainbows appear after rain', 'Rainbows appears after rain'),
('She loves chocolate chip cookies', 'She love chocolate chip cookies'),
('Birds fly high in the', 'Birds flies high in the'),
('The sun sets in the', 'The sun set in the'),
('I really like that song', 'I really liked that song'),
('Dogs are truly best friends', 'Dogs are truly best friend'),
('Books are a source of', 'Book are a source of'),
('The moon shines at night', 'The moons shine at night'),
('Walking is good for health', 'Walking is good for the health'),
('Children love to play', 'Children love to play'),
('Music is a universal language', 'Music is a universal language'),
('Winter is coming soon', 'Winter is coming soon'),
('Happiness is a choice', 'Happiness is a choice'),
('Travel broadens the mind', 'Travel broadens the mind'),
('Dogs are our closest companions', 'Cats are solitary creatures'),
('Books are portals to new worlds', 'Movies depict various realities'),
('The moon shines brightly at night', 'The sun blazes hotly at noon'),
('Walking is beneficial for health', 'Running can be hard on knees'),
('Children love to play outside', 'Children love to play'),
('Music transcends cultural boundaries', 'Music is a universal language'),
('Winter is cold and snowy', 'Winter is coming soon'),
('Happiness comes from within', 'Happiness is a choice'),
('Traveling opens up perspectives', 'Travel broadens the mind');

select * from sentence_comparison;


/*
解法1: JAROWINKLER_SIMILARITY　による文字列ベースの比較
*/

select sentence_1, sentence_2, JAROWINKLER_SIMILARITY(sentence_1, sentence_2) as score
from sentence_comparison
order by score desc;

-- 一文字違いのスコア
SELECT JAROWINKLER_SIMILARITY('Rainbows appear after rain', 'Rainbows appears after rain') as JAROWINKLER_SIMILARITY;


-- （参考）文字列ベースの比較で違いがどれだけの文字数あるか比較するEDITDISTANCE
SELECT
EDITDISTANCE('She loves chocolate chip cookies', 'She loves chocolate chip cookies') as semantic_score_1, --0文字
EDITDISTANCE('She loves chocolate chip cookies', 'She love chocolate chip cookies') as semantic_score_2, --1文字
EDITDISTANCE('She loves chocolate chip cookies', 'She lovse chocolate chip cookies') as semantic_score_3 --2文字
;

select sentence_1, sentence_2, EDITDISTANCE(sentence_1, sentence_2) as score
from sentence_comparison
order by score desc;

/*
埋め込みベースの意味的類似度手法
*/
-- AI_EMBED関数
-- VECTOR_COSINE_SIMILARITY
WITH emb AS (
  SELECT
    sentence_1,
    sentence_2,
    AI_EMBED('snowflake-arctic-embed-l-v2.0', sentence_1) AS v1,
    AI_EMBED('snowflake-arctic-embed-l-v2.0', sentence_2) AS v2
  FROM sentence_comparison
)
SELECT
  sentence_1,
  sentence_2,
  CAST(ROUND(VECTOR_COSINE_SIMILARITY(v1, v2) * 100, 0) AS INT) AS VECTOR_COSINE_SIMILARITY
FROM emb
ORDER BY VECTOR_COSINE_SIMILARITY DESC;


-- ai_similarity
select
  sentence_1,
  sentence_2,
  CAST(ROUND(ai_similarity(sentence_1, sentence_2) * 100, 0) AS INT) AS ai_similarity,
from sentence_comparison
ORDER BY ai_similarity DESC;


/*
2つ以上のセットの類似性の推定 Minhash
*/

-- 1) 行に番号をふる（ペアID）
WITH pairs AS (
  SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS pair_id, sentence_1, sentence_2
  FROM sentence_comparison
),

-- 2) 前処理（小文字化 & 句読点除去）
clean AS (
  SELECT
    pair_id,
    LOWER(REGEXP_REPLACE(sentence_1, '[^\\w\\s]', '')) AS s1,
    LOWER(REGEXP_REPLACE(sentence_2, '[^\\w\\s]', '')) AS s2
  FROM pairs
),

-- 3) 単語に分割（それぞれ“集合”化の前段）
tokens AS (
  SELECT pair_id, 's1' AS side, t.value::string AS token
  FROM clean, LATERAL FLATTEN(input => SPLIT(s1, ' ')) t
  WHERE t.value IS NOT NULL AND t.value <> ''
  UNION ALL
  SELECT pair_id, 's2' AS side, t.value::string AS token
  FROM clean, LATERAL FLATTEN(input => SPLIT(s2, ' ')) t
  WHERE t.value IS NOT NULL AND t.value <> ''
),

-- 4) 各文章ごと（pair_id×side）に MinHash 署名を作成
sketch AS (
  SELECT
    pair_id,
    side,
    MINHASH(100, token) AS mh   -- k=100（精度↑なら200,256など）
  FROM tokens
  GROUP BY pair_id, side
)

-- 5) 同じ pair_id の2つの署名を集約して近似Jaccardを算出
SELECT
  p.sentence_1,
  p.sentence_2,
  APPROXIMATE_JACCARD_INDEX(mh)*100 AS jaccard_sim
FROM sketch
JOIN pairs p USING (pair_id)
GROUP BY p.sentence_1, p.sentence_2, pair_id
ORDER BY jaccard_sim DESC;
