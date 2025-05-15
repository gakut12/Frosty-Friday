create or replace file format week3_csv_format_2
  type = CSV
  parse_header = true
;

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
