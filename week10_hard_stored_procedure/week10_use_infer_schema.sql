use role sysadmin;
use warehouse gaku_wh;
create database ff_week_10;
use database ff_week_10;

-- create warehouse
create or replace warehouse ff_week10_xsmall_wh 
    with warehouse_size = XSMALL
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true 
    statement_timeout_in_seconds = 3600
    comment = 'Frosty Friday Week10 検証用'   
;
    
create or replace warehouse ff_week10_small_wh 
    with warehouse_size = XSMALL
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true 
    statement_timeout_in_seconds = 3600
    comment = 'Frosty Friday Week10 検証用'
;
-- 生データを見る用のFile　Format
-- create or replace file format ff_csv_format_
--  type = CSV
-- ;

create or replace file format ff_csv_format
  type = CSV
  skip_header = 1
  null_if = ('\\N', 'NULL', 'NUL', '')
  field_optionally_enclosed_by = '"'
  skip_blank_lines = true -- default false, 空白行をスキップ 
  trim_space = true -- default false, |" Hello world "|  /* loads as */  > Hello world < | "Hello world" |  /* loads as */  >Hello world<
  error_on_column_count_mismatch = true -- default true : 入力ファイルの区切り列（フィールド）の数が対応するテーブルの列の数と一致しない場合に、解析エラーを生成するかどうかを指定するブール値
  replace_invalid_characters = true -- default false
  empty_field_as_null = true -- default true
;

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
create or replace stage ff_week_10_frosty_stage_
    url = 's3://frostyfridaychallenges/challenge_10/'
    file_format = (type = csv)
;
list @ff_week_10_frosty_stage_;
select $1, $2 from @ff_week_10_frosty_stage_/2022-07-01.csv limit 5;
/**
$1	$2
date	trans_amount
2022-07-01 00:00:00	1266
2022-07-01 00:00:00	7412
2022-07-01 00:00:00	7908
2022-07-01 00:00:00	3102
**/


create or replace stage ff_week_10_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_10/'
    file_format = ff_csv_format
;

-- infer_schema用のStage
create or replace stage ff_week_10_frosty_stage_for_inferschema
    url = 's3://frostyfridaychallenges/challenge_10/'
    file_format = ff_csv_format_for_inferschema
;

list @ff_week_10_frosty_stage;

/**
name	size	md5	last_modified
s3://frostyfridaychallenges/challenge_10/2022-07-01.csv	5002	05a4fc4dcf5beba5647895beab73f4dc	Wed, 17 Aug 2022 11:50:14 GMT
s3://frostyfridaychallenges/challenge_10/2022-07-02.csv	14963	50df620b5c38a87a1912703ad2d70e77	Wed, 17 Aug 2022 11:50:13 GMT
s3://frostyfridaychallenges/challenge_10/2022-07-03.csv	9987	b6729493f908406a986af6a29b3a16eb	Wed, 17 Aug 2022 11:50:13 GMT
s3://frostyfridaychallenges/challenge_10/2022-07-04.csv	22429	239c67ae14943b8525874d1b5b27aef5	Wed, 17 Aug 2022 11:50:12 GMT
s3://frostyfridaychallenges/challenge_10/2022-07-05.csv	14974	9cd295fedf9401b82c9f9e0093d3bcfb	Wed, 17 Aug 2022 11:50:12 GMT
s3://frostyfridaychallenges/challenge_10/2022-07-06.csv	7489	5bde10457a7db2fa6c20e475b33c9847	Wed, 17 Aug 2022 11:50:11 GMT
s3://frostyfridaychallenges/challenge_10/2022-07-07.csv	24925	fdcd0e12232b97611538c18f78c97841	Wed, 17 Aug 2022 11:50:10 GMT 
**/

select
    "name"
    , "size"
from 
    table(result_scan(last_query_id()));

list @ff_week_10_frosty_stage_for_inferschema;

select
    $1::string as name
    , $2::number as size
from 
    table(result_scan(last_query_id()));

-- tableを作成
select $1, $2, $3, $4, $5 from @ff_week_10_frosty_stage_ limit 5;
/**
$1	$2	$3	$4	$5
date	trans_amount			
2022-07-06 00:00:00	8402			
2022-07-06 00:00:00	7008			
2022-07-06 00:00:00	2153			
2022-07-06 00:00:00	9085			
**/
alter session set timezone = 'Asia/Tokyo';
select $1, $2, $3, $4, $5, metadata$filename, metadata$file_row_number, metadata$start_scan_time from @ff_week_10_frosty_stage_ limit 5;

select 
--    *
    column_name
    , type
    , nullable
    , order_id
from
    table(infer_schema(
        location=>'@ff_week_10_frosty_stage_for_inferschema'
        , file_format=>'ff_csv_format_for_inferschema'
    ));
/**
COLUMN_NAME	TYPE	NULLABLE	EXPRESSION	FILENAMES	ORDER_ID
date	TIMESTAMP_NTZ	TRUE	$1::TIMESTAMP_NTZ	challenge_10/2022-07-05.csv, challenge_10/2022-07-06.csv, challenge_10/2022-07-03.csv, challenge_10/2022-07-07.csv, challenge_10/2022-07-01.csv, challenge_10/2022-07-02.csv, challenge_10/2022-07-04.csv	0
trans_amount	NUMBER(4, 0)	TRUE	$2::NUMBER(4, 0)	challenge_10/2022-07-06.csv, challenge_10/2022-07-04.csv, challenge_10/2022-07-05.csv, challenge_10/2022-07-02.csv, challenge_10/2022-07-03.csv, challenge_10/2022-07-07.csv, challenge_10/2022-07-01.csv	1
**/


select 
    array_agg(object_construct('COLUMN_NAME', column_name, 'TYPE', type, 'NULLABLE', nullable, 'ORDER_ID', order_id )) 
    -- * にすると16MBを超える場合もあるので、カラムを絞る

    -- https://docs.snowflake.com/en/sql-reference/functions/infer_schema
    -- Using * for ARRAY_AGG(OBJECT_CONSTRUCT()) may result in an error if the returned result is larger than 16MB. 
from
    table(infer_schema(
        location=>'@ff_week_10_frosty_stage_for_inferschema'
        , file_format=>'ff_csv_format_for_inferschema'
    ));
/**
[
  {
    "COLUMN_NAME": "date",
    "NULLABLE": true,
    "ORDER_ID": 0,
    "TYPE": "TIMESTAMP_NTZ"
  },
  {
    "COLUMN_NAME": "trans_amount",
    "NULLABLE": true,
    "ORDER_ID": 1,
    "TYPE": "NUMBER(4, 0)"
  }
]
**/
-- https://qiita.com/friedaji/items/9d25cfb071de5792f0d1
-- SnowflakeのUSING TEMPLATE+INFER SCHEMAの処理にカラムを追加する

select 
    array_append (
    array_append (
    array_append (
        array_agg(object_construct('COLUMN_NAME', column_name, 'TYPE', type, 'NULLABLE', nullable )) 
        , {'COLUMN_NAME':'filename', 'TYPE':'string', 'NULLABLE':true}::variant
    )
        , {'COLUMN_NAME':'file_row_number', 'TYPE':'number', 'NULLABLE':true}::variant

    )
        , {'COLUMN_NAME':'start_scan_time', 'TYPE':'TIMESTAMP_LTZ', 'NULLABLE':true}::variant
    )

    -- * にすると16MBを超える場合もあるので、カラムを絞る

    -- https://docs.snowflake.com/en/sql-reference/functions/infer_schema
    -- Using * for ARRAY_AGG(OBJECT_CONSTRUCT()) may result in an error if the returned result is larger than 16MB. 
from
    table(infer_schema(
        location=>'@ff_week_10_frosty_stage_for_inferschema'
        , file_format=>'ff_csv_format_for_inferschema'
    ));

-- create table
create or replace transient table week10_tbl
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
        location=>'@ff_week_10_frosty_stage_for_inferschema'
        , file_format=>'ff_csv_format_for_inferschema'
        , ignore_case => true -- 大文字小文字が区別されないで、すべての列名は大文字になる
        , max_records_per_file => 10000
    )))
;

desc table week10_tbl;
/**
name	type	kind	null?	default	primary key	unique key	check	expression	comment	policy name	privacy domain
DATE	TIMESTAMP_NTZ(9)	COLUMN	Y		N	N					
TRANS_AMOUNT	NUMBER(4,0)	COLUMN	Y		N	N					
FILENAME	VARCHAR(16777216)	COLUMN	Y		N	N					
FILE_ROW_NUMBER	NUMBER(38,0)	COLUMN	Y		N	N					
START_SCAN_TIME	TIMESTAMP_LTZ(9)	COLUMN	Y		N	N					
**/

/**
https://docs.snowflake.com/en/sql-reference/sql/copy-into-table?utm_source=snowscope&utm_medium=serp&utm_term=COPY%20INTO

COPY INTO table1 FROM @stage1
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
INCLUDE_METADATA = (
    ingestdate = METADATA$START_SCAN_TIME, filename = METADATA$FILENAME);
**/

copy into week10_tbl 
from 
    @ff_week_10_frosty_stage_for_inferschema
match_by_column_name = case_insensitive
include_metadata = (
   filename = METADATA$FILENAME
   , file_row_number = METADATA$FILE_ROW_NUMBER
   , start_scan_time = METADATA$START_SCAN_TIME
)
;
/**
Number of columns in file (2) does not match that of the corresponding table (5), use file format option error_on_column_count_mismatch=false to ignore this error
  ファイル「challenge_10/2022-07-01.csv」、行 3、文字 1
  行 1 2 列から開始、列 "WEEK10_TBL"["TRANS_AMOUNT":2]
  エラーが発生してもロードを継続したい場合は、ON_ERRORオプションに「SKIP_FILE」または「CONTINUE」などの別の値を使用します。ロードのオプションの詳細については、SQLクライアントで「info loading_data」を実行してください。

  file_formatのオプションで、ERROR_ON_COLUMN_COUNT_MISMATCH=true だと、INCLUDE_METADATAはうまく動かない、falseにする必要あり
**/

create or replace procedure dynamic_warehouse_data_load(stage_name string, table_name string)
    returns table(value string)
    language sql
    execute as caller
as
    $$
        declare
            log_array array default ARRAY_CONSTRUCT();
        begin
            
            -- stage上のファイルの情報を取得
            execute immediate 'list @' || :stage_name;
            let result_set_ls resultset := (select $1 as name , $2 as size from table(result_scan(last_query_id())));
            let cur cursor for result_set_ls;

            for t in cur do
                let name string := t.name;
                let size number := t.size;
                if (size < 10240 ) then
                    use warehouse ff_week10_xsmall_wh;
                else
                    use warehouse ff_week10_small_wh;
                end if;
                -- let sql string := 'copy into ' || :table_name || ' from @' || :stage_name || ' files = (''' || split_part(:name, '/', -1) || ''' )';
                -- infer_schema、include_metadata を使う形で作り直し
                let sql string := 'copy into ' || :table_name || ' from @' || :stage_name 
                || ' files = (''' || split_part(:name, '/', -1) || ''' )' 
                || ' match_by_column_name = case_insensitive'
                || ' include_metadata = (filename = METADATA$FILENAME, file_row_number = METADATA$FILE_ROW_NUMBER, start_scan_time = METADATA$START_SCAN_TIME)';
--                log_array := array_append(:log_array, 'sql :' || :sql );
                execute immediate :sql;
            end for;

            let loaded_total number;
            select count(*) into :loaded_total from week10_tbl;
            log_array := array_append(:log_array, 'loaded_total :' || :loaded_total );

            let rs resultset := (select value::string as value from table(flatten(input => :log_array)));
            return table(rs);
        end;
    $$
;
truncate table week10_tbl;
call dynamic_warehouse_data_load('ff_week_10_frosty_stage_for_inferschema', 'week10_tbl');


-- 確認
select query_id, query_text, warehouse_name from table(information_schema.query_history_by_session()) where startswith(query_text, 'copy into week10_tbl from') order by start_time desc limit 100;
