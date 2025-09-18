-- 環境設定
use role sysadmin;
use warehouse compute_wh;

use database frosty_friday_db;
create or replace schema week001;

-- stageの作成
-- s3://frostyfridaychallenges/challenge_1/

create or replace stage week001_stage
    URL='s3://frostyfridaychallenges/challenge_1/';

-- Stage上のファイルを確認
list @week001_stage;


-- ファイルの中身を確認
select
    $1, $2
    , metadata$filename 
    , metadata$file_row_number
from 
    @week001_stage
;

-- テーブルの作成
create or replace table week1_table (
    result text
    , filename text
    , file_row_number number
)
;

-- file formatの作成
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
            @week001_stage
    )
FILE_FORMAT = (FORMAT_NAME = 'week1_csv_format');
;


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