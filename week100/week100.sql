/**


**/

use role sysadmin;
use warehouse gaku_wh;
use database frosty_friday;
create or replace schema week100;

use schema week100;

-- setup code
-- create or replace table images (file_name string, image_bytes string);
-- desc table images;

-- infer_schema用のFileFormat（parse_header = true, error_on_column_count_mismatch = falseが特徴）
create or replace file format ff_csv_format_for_inferschema
  type = CSV
  parse_header = true
  null_if = ('\\N', 'NULL', 'NUL', '')
  field_optionally_enclosed_by = '"'
  skip_blank_lines = true -- default false, 空白行をスキップ 
  trim_space = true -- default false, |" Hello world "|  /* loads as */  > Hello world < | "Hello world" |  /* loads as */  >Hello world<
  error_on_column_count_mismatch = false -- default true : 入力ファイルの区切り列（フィールド）の数が対応するテーブルの列の数と一致しない場合に、解析エラーを生成するかどうかを指定するブール値
  -- copy into include_metadata を使うには、falseにする必要がある
  replace_invalid_characters = true -- default false
  empty_field_as_null = true -- default true
;

-- create stage
create or replace stage ff_week_100_frosty_stage_
    url = 's3://frostyfridaychallenges/challenge_100/'
    file_format = (type = csv)
;

list @ff_week_100_frosty_stage_;
/**
name	size	md5	last_modified
s3://frostyfridaychallenges/challenge_100/images.csv	2213964	0bd41751248da3eaf4eed7dbb8020b02	Fri, 5 Jul 2024 12:05:59 GMT
**/

select $1, $2, $3, $4, $5 from @ff_week_100_frosty_stage_/images.csv;
-- -> カラムは2つ

-- infer_schema用のStage
create or replace stage ff_week_100_frosty_stage_for_inferschema
    url = 's3://frostyfridaychallenges/challenge_100/'
    file_format = ff_csv_format_for_inferschema
;

list @ff_week_100_frosty_stage_for_inferschema;
/**
s3://frostyfridaychallenges/challenge_100/images.csv	2213964	0bd41751248da3eaf4eed7dbb8020b02	Fri, 5 Jul 2024 12:05:59 GMT
**/

-- create table
create or replace transient table week100_tbl
    using template (
select 
    array_cat(
        array_agg(object_construct('COLUMN_NAME', column_name, 'TYPE', type, 'NULLABLE', nullable )) 
        -- * にすると16MBを超える場合もあるので、カラムを絞る

        -- https://docs.snowflake.com/en/sql-reference/functions/infer_schema
        -- Using * for ARRAY_AGG(OBJECT_CONSTRUCT()) may result in an error if the returned result is larger than 16MB.
        , [
            {'COLUMN_NAME':'FILENAME', 'TYPE':'STRING', 'NULLABLE':true}
            , {'COLUMN_NAME':'FILE_ROW_NUMBER', 'TYPE':'NUMBER', 'NULLABLE':true}
            , {'COLUMN_NAME':'START_SCAN_TIME', 'TYPE':'TIMESTAMP_LTZ', 'NULLABLE':true}
        ]::variant
    )
from
    table(infer_schema(
        location=>'@ff_week_100_frosty_stage_for_inferschema'
        , file_format=>'ff_csv_format_for_inferschema'
        , ignore_case => true -- 大文字小文字が区別されないで、すべての列名は大文字になる
        , max_records_per_file => 10000
    )))
;

desc table week100_tbl;
/**
name	type	kind	null?	default	primary key	unique key	check	expression	comment	policy name	privacy domain
FILE_NAME	VARCHAR(16777216)	COLUMN	Y		N	N					
IMAGE_BYTES	VARCHAR(16777216)	COLUMN	Y		N	N					
FILENAME	VARCHAR(16777216)	COLUMN	Y		N	N					
FILE_ROW_NUMBER	NUMBER(38,0)	COLUMN	Y		N	N					
START_SCAN_TIME	TIMESTAMP_LTZ(9)	COLUMN	Y		N	N					
**/

copy into week100_tbl 
from 
    @ff_week_100_frosty_stage_for_inferschema
match_by_column_name = case_insensitive
include_metadata = (
   filename = METADATA$FILENAME
   , file_row_number = METADATA$FILE_ROW_NUMBER
   , start_scan_time = METADATA$START_SCAN_TIME
)
;

-- table を確認（5行なのでLimitはいらない）
select * from public.week100_tbl;
