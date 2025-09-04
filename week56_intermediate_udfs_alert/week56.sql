use role sysadmin;
use warehouse gaku_wh;
use database gaku_frosty_friday_db;
create or replace schema week56;

create or replace stage week56_stage
    url='s3://frostyfridaychallenges/challenge_56/'
    DIRECTORY = (ENABLE = TRUE)
;

list @week56_stage;
/**
s3://frostyfridaychallenges/challenge_56/survey_results.csv	112	11b9dd9b2ec1c57980b8bd2036614ba2	Thu, 27 Jul 2023 21:33:23 GMT
s3://frostyfridaychallenges/challenge_56/survey_results_2.csv	80	8f93f73925e55e769b990cf98518e550	Fri, 28 Jul 2023 07:19:14 GMT
**/

-- ファイルの取込
select $1, $2, $3, $4, $5 from @week56_stage/survey_results.csv;
-- > $1, $2 だけがある。$2に絵文字が入っている
-- > 1行目は、ヘッダーで、id, reaction となっている

select $1, $2, $3, $4, $5 from @week56_stage/survey_results_2.csv;
-- > $1, $2 だけがある。$2に絵文字が入っている
-- > 1行目は、ヘッダーで、id, reaction となっている

create or replace file format csv_format_parse_header
  type = CSV
  parse_header = true
;

create or replace table week56_survey_results
using template (
    select 
        array_cat (
            array_agg(object_construct('COLUMN_NAME', column_name, 'TYPE', type, 'NULLABLE', nullable))
            -- * にすると16MBを超える場合もあるので、カラムを絞る
            , [
            {'COLUMN_NAME':'FILENAME', 'TYPE':'STRING', 'NULLABLE':true}
            , {'COLUMN_NAME':'FILE_ROW_NUMBER', 'TYPE':'NUMBER', 'NULLABLE':true}
            , {'COLUMN_NAME':'START_SCAN_TIME', 'TYPE':'TIMESTAMP_LTZ', 'NULLABLE':true}
        ]::variant
    )
    from table (
        infer_schema (
            location => '@week56_stage'
            , files => 'survey_results.csv'
            , file_format => 'csv_format_parse_header'
            , ignore_case => true
        )
    )
);

desc table week56_survey_results;

create or replace file format csv_format_parse_header_with_colum_count_mismatch
  type = CSV
  parse_header = true
  error_on_column_count_mismatch=false
;

copy into week56_survey_results 
from 
    @week56_stage
match_by_column_name = case_insensitive
files = ('survey_results.csv')
file_format = (FORMAT_NAME = 'csv_format_parse_header_with_colum_count_mismatch')
include_metadata = (
   filename = METADATA$FILENAME
   , file_row_number = METADATA$FILE_ROW_NUMBER
   , start_scan_time = METADATA$START_SCAN_TIME
)
;

select * from week56_survey_results;
select distinct(reaction) from week56_survey_results;

-- PIPE演算子を使うと・・・
select * from week56_survey_results
->> select reaction from $1 group by reaction;

select reaction, length(reaction), '[' || reaction || ']' from week56_survey_results;
select trim(reaction) as reaction2, length(reaction2) from week56_survey_results;

select * from week56_survey_results
->> select distinct(trim(reaction)) as reaction from $1 group by reaction;
-- 前後の空白を除去して、重複を排除。絵文字は3つに

CREATE OR REPLACE FUNCTION EMOJI_TO_TEXT_CASE(str STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
  CASE str
    WHEN '😀' THEN ':grinning:'
    WHEN '☹️' THEN ':sad:'
    WHEN '😑' THEN ':neutral:'
    ELSE null
  END
$$;

CREATE OR REPLACE FUNCTION EMOJI_TO_TEXT_SQL(str STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
  REPLACE(
    REPLACE(
      REPLACE(str, '😀', ':grinning:'),
        '☹️', ':sad:'),
      '😑', ':neutral:')
$$;

select * from week56_survey_results
->> select trim(reaction) as reaction from $1
->> select reaction, EMOJI_TO_TEXT_CASE(reaction) as reaction_text_1, EMOJI_TO_TEXT_SQL(reaction) as reaction_text_2 from $1 group by reaction;

-- ここで　survey_results_2.csv　を取り込む

copy into week56_survey_results 
from 
    @week56_stage
match_by_column_name = case_insensitive
files = ('survey_results_2.csv')
file_format = (FORMAT_NAME = 'csv_format_parse_header_with_colum_count_mismatch')
include_metadata = (
   filename = METADATA$FILENAME
   , file_row_number = METADATA$FILE_ROW_NUMBER
   , start_scan_time = METADATA$START_SCAN_TIME
)
;

select * from week56_survey_results
->> select trim(reaction) as reaction from $1
->> select reaction, EMOJI_TO_TEXT_CASE(reaction) as reaction_text_1, EMOJI_TO_TEXT_SQL(reaction) as reaction_text_2 from $1 group by reaction;

-- EMOJI_TO_TEXT_SQLだと、🚀がそのまま🚀になるので、本件にはそぐわない

select 
    trim(reaction) as reaction2
    , EMOJI_TO_TEXT_CASE(reaction2) as reaction_text 
from 
    week56_survey_results 
group by reaction2;


-- 通知先をメール
-- 通知先をSlackで（Webhook）

-- https://api.slack.com/apps/new へアクセスする
-- create apps をする
-- 左メニューの incoming webhookをクリックし、
-- https://hooks.slack.com/services/T********/B**********/K************************
-- を取得する

CREATE OR REPLACE SECRET my_slack_webhook_secret
  TYPE = GENERIC_STRING
  SECRET_STRING = 'T*****/B***********/K************************';

CREATE OR REPLACE NOTIFICATION INTEGRATION my_slack_webhook_int
  TYPE=WEBHOOK
  ENABLED=TRUE
  WEBHOOK_URL='https://hooks.slack.com/services/SNOWFLAKE_WEBHOOK_SECRET'
  WEBHOOK_SECRET=gaku_frosty_friday_db.week56.my_slack_webhook_secret
  WEBHOOK_BODY_TEMPLATE='{"text": "SNOWFLAKE_WEBHOOK_MESSAGE"}'
  WEBHOOK_HEADERS=('Content-Type'='application/json');


-- デコなメッセージを送る
CREATE OR REPLACE NOTIFICATION INTEGRATION my_slack_webhook_int_deco_info
  TYPE=WEBHOOK
  ENABLED=TRUE
  WEBHOOK_URL='https://hooks.slack.com/services/SNOWFLAKE_WEBHOOK_SECRET'
  WEBHOOK_SECRET=my_slack_webhook_secret
  WEBHOOK_BODY_TEMPLATE='{"channel": "_gaku_t",
    "attachments":[
      {
         "fallback":"FrostyFryday Week56 Enoji Alert",
         "pretext":"FrostyFryday Week56 Enoji Alert",
         "color":"warning",
         "fields":[
            {
               "title":"FrostyFryday Week56 Enoji Alert",
               "value":"SNOWFLAKE_WEBHOOK_MESSAGE"
            }
         ]
      }
      ]
    }'
  WEBHOOK_HEADERS=('Content-Type'='application/json')
;

CALL SYSTEM$SEND_SNOWFLAKE_NOTIFICATION(
  SNOWFLAKE.NOTIFICATION.TEXT_PLAIN(
    SNOWFLAKE.NOTIFICATION.SANITIZE_WEBHOOK_CONTENT('my message deco ( alart )')
  ),
  SNOWFLAKE.NOTIFICATION.INTEGRATION('my_slack_webhook_int_deco_info')
);


-- aleatを作る
-- Create the alert
create or replace alert ALERT_NEW_EMOJI
  warehouse = gaku_wh
  -- schedule = 'USING CRON 0 10 * * 1 UTC' --10AM every Monday
  schedule = '1 minute'
if (
  exists (
    select 
        trim(reaction) as reaction2
        , EMOJI_TO_TEXT_CASE(reaction2) as reaction_text 
    from 
        week56_survey_results 
    where
        reaction_text is null
    group by reaction2
  )
)
then
    CALL SYSTEM$SEND_SNOWFLAKE_NOTIFICATION(
      SNOWFLAKE.NOTIFICATION.TEXT_PLAIN(
        SNOWFLAKE.NOTIFICATION.SANITIZE_WEBHOOK_CONTENT('emoji alert')
      ),
    SNOWFLAKE.NOTIFICATION.INTEGRATION('my_slack_webhook_int_deco_info')
    )
;

alter alert ALERT_NEW_EMOJI resume;

use role accountadmin;
GRANT EXECUTE ALERT ON ACCOUNT TO ROLE SYSADMIN;

use role sysadmin;
alter alert ALERT_NEW_EMOJI resume;
desc alert ALERT_NEW_EMOJI;
alter alert ALERT_NEW_EMOJI suspend;
