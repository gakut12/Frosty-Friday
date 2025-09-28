use database gaku_frosty_friday_db;
create or replace schema week125;

-- 単純なSQL
SELECT
  value::NUMBER AS original_number,
  original_number * original_number AS squared
FROM
  TABLE(FLATTEN(INPUT => PARSE_JSON('[1,2,3,4]')));


--　引数化
set number_of_array = '[1,2,3,4]';

SELECT
  value::NUMBER AS original_number,
  original_number * original_number AS squared
FROM
  TABLE(FLATTEN(INPUT => PARSE_JSON($number_of_array)))
;

SELECT
  value::NUMBER AS original_number,
  original_number * original_number AS squared
FROM
  TABLE(FLATTEN(INPUT => [1,2,3,4]))
;

-- jinja化すると・・・

-- utils.sql(jinja) 
-- これは、Snowsightでは動かないので注意
SELECT
  value::NUMBER AS original_number,
  original_number * original_number AS squared
FROM
  TABLE(FLATTEN(INPUT => {{number_of_array}}))
;

-- stageを作成
create or replace stage week125_stage;

show stages;

-- utils.sqlを実行してみる

EXECUTE IMMEDIATE FROM @week125_stage/utils.sql
    USING (number_of_array=>'[1,2,3,4]');

EXECUTE IMMEDIATE FROM @week125_stage/utils_2_use_json_parse.sql
USING (number_of_array=>'[1,2,3,4]');

-- utils.sqlを実行するコードを main.sqlに書く
-- Snowsightでmain.sqlをアップロード
-- main.sqlを実行
EXECUTE IMMEDIATE FROM @week125_stage/main.sql;