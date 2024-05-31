/**
Week10-hard : Stored Procedure

Frosty Consultingでは、ステージからデータを手動かつ動的にロードできるようにしたいという依頼を受けました。
具体的には、次のことが実現できるようにしたいと考えています。

- 単一のコマンド（ストアドプロシージャ）を実行する
- 手動で行うと、スケジュールされず、Snowpipesも使用できなくなります。
- ウェアハウスのサイズを動的に変えて実行、ファイルが 10 KB を超える場合はサイズSmallのウェアハウスを使用し、その10 KB未満のファイルは xsmall ウェアハウスで処理する。

**/

use role sysadmin;
create database ff_week_10;
use database ff_week_10;

create or replace procedure stored_procedure_template(var1 string)
    returns array
    language sql
    execute as caller
as
    $$
        declare
            log_array array default ARRAY_CONSTRUCT();
        begin
            log_array := array_append(:log_array, :var1);
            return log_array;
            -- return var1
        end;
    $$
;
call stored_procedure_template('testtesttest');

-------------------

use role sysadmin;
-- Create the warehouses
create warehouse if not exists my_xsmall_wh 
    with warehouse_size = XSMALL
    auto_suspend = 120;
    
create warehouse if not exists my_small_wh 
    with warehouse_size = SMALL
    auto_suspend = 120;

-- Create the table
create or replace table week10_tbl
(
    date_time datetime,
    trans_amount double
);
-- TODO infer_schemaで、Metadataもいれる形で実装する。csvも対応済み

-- create file format
create or replace file format week10_csv_format
  type = CSV
  skip_header = 1
  null_if = ('NULL')
  empty_field_as_null = true
  field_optionally_enclosed_by = '"'
;

-- Create the stage
create or replace stage week_10_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_10/'
    file_format = week10_csv_format;

list @week_10_frosty_stage;
select
    "name"
    , "size"
from 
    table(result_scan(last_query_id()));

create or replace procedure dynamic_warehouse_data_load(stage_name string, table_name string)
    returns array
    language sql
    execute as caller
as
    $$
        declare
            log_array array default ARRAY_CONSTRUCT();
        begin
            log_array := array_append(:log_array, 'stage_name :' || :stage_name);
            log_array := array_append(:log_array, 'table_name :' || :table_name);
            return log_array;
            -- return var1
        end;
    $$
;
call dynamic_warehouse_data_load('public', 'hoge');

create or replace procedure dynamic_warehouse_data_load(stage_name string, table_name string)
    returns array
    language sql
    execute as caller
as
    $$
        declare
            log_array array default ARRAY_CONSTRUCT();
        begin
            
--            log_array := array_append(:log_array, 'stage_name :' || :stage_name);
--            log_array := array_append(:log_array, 'table_name :' || :table_name);
                
            -- stage上のファイルの情報を取得
            list @week_10_frosty_stage;
            let result_set_ls resultset := (select "name" as name , "size" as size from table(result_scan(last_query_id())));
            let cur cursor for result_set_ls;
            for t in cur do
                let name string := t.name;
                let size number := t.size;
                if (size < 10240 ) then
                    use warehouse my_xsmall_wh;
                else
                    use warehouse my_small_wh;
                end if;
                let sql string := 'copy into week10_tbl from @week_10_frosty_stage files = (''' || replace(:name, 's3://frostyfridaychallenges/challenge_10/') || ''' )';
--                log_array := array_append(:log_array, 'sql :' || :sql );
                execute immediate :sql;
            end for;

            let loaded_total number;
            select count(*) into :loaded_total from week10_tbl;
            log_array := array_append(:log_array, 'loaded_total :' || :loaded_total );
            
            return log_array;
        end;
    $$
;
call dynamic_warehouse_data_load('public', 'week10_tbl');

list @week_10_frosty_stage;
select $1 as name , $2 as size from table(result_scan(last_query_id()));

select split_part('s3://frostyfridaychallenges/challenge_10/2022-07-01.csv', '/', -1) as hoge;

show stages like 'week_10_frosty_stage';


create or replace procedure dynamic_warehouse_data_load(stage_name string, table_name string)
    returns array
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
                    use warehouse my_xsmall_wh;
                else
                    use warehouse my_small_wh;
                end if;
                let sql string := 'copy into ' || :table_name || ' from @' || :stage_name || ' files = (''' || split_part(:name, '/', -1) || ''' )';
                -- TODO infer_schema、include_metadata を使う形で作り直す
--                log_array := array_append(:log_array, 'sql :' || :sql );
                execute immediate :sql;
            end for;

            let loaded_total number;
            select count(*) into :loaded_total from week10_tbl;
            log_array := array_append(:log_array, 'loaded_total :' || :loaded_total );

            return log_array;
        end;
    $$
;
-- Create the table
truncate table week10_tbl;

-- Create the stage
-- 一度取り込んでるので、STAGEを作り直し
create or replace stage week_10_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_10/'
    file_format = week10_csv_format
;

call dynamic_warehouse_data_load('week_10_frosty_stage', 'week10_tbl');

-- 
select query_id, query_text, warehouse_name from table(information_schema.query_history_by_session()) where contains(query_text, 'copy into week10_tbl from') order by start_time desc limit 100;

--- python版
-- https://github.com/darylkit/Frosty_Friday/blob/main/Week%2010%20-%20Stored%20Procedures/stored_procedures.sql
