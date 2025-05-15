use role sysadmin;
use warehouse gaku_wh;

use database frosty_friday;
create or replace schema week3;

create or replace stage week3_ext_stage
  URL='s3://frostyfridaychallenges/challenge_3/';

list @week3_ext_stage;

select 
    $1
    , $2
    , $3
    , $4
    , $5
    , metadata$filename 
    , metadata$file_row_number
from 
    @week3_ext_stage/keywords.csv
;

-- pattern1 no use infer_schema()

create or replace table week3_keyword_table_1 (
    keyword text
    , added_by text
    , nonsense text
    , file_name text
    , file_row_number number
)
;

select * from week3_keyword_table_1;

create or replace file format week3_csv_format_1
  type = CSV
  skip_header = 1
;

copy into week3_keyword_table_1 ( keyword, added_by, nonsense, file_name,  file_row_number)
from 
    ( 
        select 
            $1 
            , $2
            , $3
            , metadata$filename 
            , metadata$file_row_number
        from 
            @week3_ext_stage
    )
    FILES=('keywords.csv')
    FILE_FORMAT = (FORMAT_NAME = 'week3_csv_format_1');

select * from week3_keyword_table_1;


list @week3_ext_stage;
-- week3_* というパターン

select 
    $1
    , $2
    , $3
    , $4
    , $5
    , $6
    , $7
    , $8
    , metadata$filename 
    , metadata$file_row_number
from 
    @week3_ext_stage/week3_data1.csv
;

create or replace table week3_data_table_1 (
    id number
    , first_name text
    , last_name text
    , catch_phrase text
    , timestamp date
    , file_name text
    , file_row_number number
)
;

copy into week3_data_table_1 ( id, first_name, last_name, catch_phrase, timestamp, file_name,  file_row_number)
from 
    ( 
        select 
            $1 
            , $2
            , $3
            , $4
            , $5
            , metadata$filename 
            , metadata$file_row_number
        from 
            @week3_ext_stage
    )
     PATTERN='challenge_3/week3_.*'
    FILE_FORMAT = (FORMAT_NAME = 'week3_csv_format')
;

select * from week3_data_table_1;

list @week3_ext_stage;
show tables;
select * from week3_keyword_table_1;

list @week3_ext_stage;
set query_id = last_query_id();

with data_files as (
    select 
        "name" as filename
    from 
        table(result_scan($query_id))
)
-- select * from data_files;
, keyword as (
    select keyword from week3_keyword_table_1
)
-- select keyword from keyword;
select 
    filename 
from 
    data_files
    inner join keyword as k
        on contains(filename, k.keyword)
;





-- pattern2 use infer_schema()

create or replace file format week3_csv_format_2
  type = CSV
  parse_header = true
;

select * from table (infer_schema (
            location => '@week3_ext_stage'
            , files => 'keywords.csv'
            , file_format => 'week3_csv_format_2'
            , ignore_case => true
        ));
select array_agg({*}) from table (infer_schema (
            location => '@week3_ext_stage'
            , files => 'keywords.csv'
            , file_format => 'week3_csv_format_2'
            , ignore_case => true
        ));

create or replace table week3_keyword_table_2_2
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
            location => '@week3_ext_stage'
            , files => 'keywords.csv'
            , file_format => 'week3_csv_format_2'
            , ignore_case => true
        )
    )
);

desc table week3_keyword_table_2_2;

create or replace file format week3_csv_format_2_2
  type = CSV
  parse_header = true
  error_on_column_count_mismatch=false
;

copy into week3_keyword_table_2_2 
from 
    @week3_ext_stage
match_by_column_name = case_insensitive
files = ('keywords.csv')
file_format = (FORMAT_NAME = 'week3_csv_format_2_2')
include_metadata = (
   filename = METADATA$FILENAME
   , file_row_number = METADATA$FILE_ROW_NUMBER
   , start_scan_time = METADATA$START_SCAN_TIME
)
;

copy into week3_keyword_table_2
    FROM @week3_ext_stage
    FILES = ('keywords.csv')
    FILE_FORMAT = (FORMAT_NAME = 'week3_csv_format_2')
    MATCH_BY_COLUMN_NAME = CASE_SENSITIVE
    ;
