use role sysadmin;
use warehouse compute_wh;

use database frosty_friday_db;
create schema SWTT_SPECIAL_1;

SELECT
  *
FROM
  "FROSTY_FRIDAY_DB"."SWTT_SPECIAL_1"."HYAKUNIN_ISSYU"
LIMIT
  10;

select 
    No
    , UPPER_PHRASE || LOWER_PHRASE as CONTENT
    , AI_CLASSIFY(
        CONTENT,
        ['春','夏', '秋', '冬']
    ):labels[0]::string as season
from 
    HYAKUNIN_ISSYU
order by no;

select count(*) from HYAKUNIN_ISSYU; -- 100

select 
    AI_CLASSIFY(
        UPPER_PHRASE || LOWER_PHRASE,
        ['春','夏', '秋', '冬']
    ):labels[0]::string as season
    , count(*) as count
from 
    HYAKUNIN_ISSYU
group by all
order by count;

-- ai_filter

with analyse as (
select 
    no
    , upper_phrase || ' ' || lower_phrase as content
    , ai_filter(
        prompt('これは春についての文章ですか？:{0}', content)
    ) as is_spring
    , ai_filter(
        prompt('これは夏についての文章ですか？:{0}', content)
    ) as is_summer
    , ai_filter(
        prompt('これは秋についての文章ですか？:{0}', content)
    ) as is_autumn
    , ai_filter(
        prompt('これは冬についての文章ですか？:{0}', content)
    ) as is_winter
    , ai_filter(
        prompt('これは季節についての文章ですか？:{0}', content)
    ) as is_season
 from 
    hyakunin_issyu
) 
-- select * from analyse;

select 
    SUM(CASE WHEN is_spring THEN 1 ELSE 0 END) AS spring_count
    , SUM(CASE WHEN is_summer THEN 1 ELSE 0 END) AS summer_count
    , SUM(CASE WHEN is_autumn THEN 1 ELSE 0 END) AS autumn_count
    , SUM(CASE WHEN is_winter THEN 1 ELSE 0 END) AS winter_count
    , SUM(CASE WHEN is_season THEN 1 ELSE 0 END) AS season_count
from 
    analyse;
;

-- 感情分析をしてみる
select
    no
    , upper_phrase || ' ' || lower_phrase as content
    , ai_sentiment(
        content
    ):categories as feeling_category
from 
    hyakunin_issyu
order by no
;

with sentiment as (
select
    no
    , upper_phrase || ' ' || lower_phrase as content
    , ai_sentiment(
        content
    ):categories[0]:sentiment::string as feeling_category
from 
    hyakunin_issyu
) 
-- select * from sentiment
select feeling_category, count(*) as count, '' as memo  from sentiment
group by all
;
