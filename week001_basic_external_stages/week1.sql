/**
Week1 - Baskc External Stages
https://frostyfriday.org/blog/2022/07/14/week-1/

世界有数のホワイト企業であるFrostyFriday株式会社には、分析に使用するcsvデータがS3バケットに配置されています。
今回は、外部STAGEを作成し、この分析用csvデータをテーブルへロードすることです。

S3バケットのURIは、s3://frostyfridaychallenges/challenge_1/　になります。
**/

use role sysadmin;
use warehouse gaku_wh;

-- データベースを作ります
create database gaku_frosty_friday_db;

create schema week001;

create or replace stage week001_ext_stage
  URL='s3://frostyfridaychallenges/challenge_1/';

list @week001_ext_stage;

select 
    $1
    -- , $2
    -- , $3
    , metadata$filename 
    , metadata$file_row_number
from 
    @week001_ext_stage
;

create or replace table week1_table (
    result text
    , filename text
    , file_row_number number
)
;
desc table week1_table;

-- file formatの作成
-- CSV
-- ヘッダは一行目
-- 文字列「NULL」と「null」をnullへ
-- 空白のみはnull
create or replace file format week1_csv_format
  type = CSV
  skip_header = 1
  null_if = ('NULL', 'null')
  empty_field_as_null = true
;

-- データの投入
copy into week1_table ( result, filename, file_row_number)
from 
    ( 
        select 
            $1 
            , metadata$filename 
            , metadata$file_row_number
        from 
            @week001_ext_stage
    )
FILE_FORMAT = (FORMAT_NAME = 'week1_csv_format');
;

-- file_format を使わない場合
-- select * from week1_table where result != 'result' and result != 'NULL';

-- file_format を使う場合
select * from week1_table ;

with source as (
    select 
        result
        , filename
        , file_row_number
    from 
        week1_table 
    where
        result is not null
        and result != 'totally_empty'
)

, final as (
    select 
        listagg(result,' ') WITHIN GROUP (ORDER BY filename,  file_row_number )  as answer
    from source
)
select * from final;

-- use infer_schema
-- 1行目をヘッダとして、スキーマを推測してテーブルを作成

create or replace file format week3_csv_format_2
  type = CSV
  parse_header = true
  null_if = ('NULL', 'null')
  empty_field_as_null = true
;
