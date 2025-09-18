use database frosty_friday_db;
use schema week001;

-- parse_header が有効なFile Format
create or replace file format week1_csv_format_2
  type = CSV
  parse_header = true
  null_if = ('NULL', 'null')
  empty_field_as_null = true
  error_on_column_count_mismatch=false
;

list @week001_stage;
select * from table (infer_schema (
            location => '@week001_stage'
--            , files => ('1.csv','2.csv','3.csv')
            , file_format => 'week1_csv_format_2'
            , ignore_case => true
        ));


create or replace table week1_table_2
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
            location => '@week001_stage'
            , file_format => 'week3_csv_format_2'
            , ignore_case => true
        )
    )
);

desc table week1_table_2;

-- create or replace file format week1_csv_format_2_2
--   type = CSV
--   parse_header = true
--   null_if = ('NULL', 'null')
--   empty_field_as_null = true
--   error_on_column_count_mismatch=false
-- ;

copy into week1_table_2 
from 
    @week001_stage
match_by_column_name = case_insensitive
files = ('1.csv','2.csv','3.csv')
file_format = (FORMAT_NAME = 'week1_csv_format_2')
include_metadata = (
   filename = METADATA$FILENAME
   , file_row_number = METADATA$FILE_ROW_NUMBER
   , start_scan_time = METADATA$START_SCAN_TIME
)
;
        
select * from week1_table_2;

with source as (
    select 
        result
        , filename
        , file_row_number
    from 
        week1_table_2
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