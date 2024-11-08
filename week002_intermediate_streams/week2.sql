/**
Week2 Intermediate（中級） Streams https://docs.snowflake.com/ja/user-guide/streams-intro

人事部の担当者は、変更管理をしていきたいと考えています。
しかし、作成したSTREAMが、関係ないものも拾ってしまっていると考えていました。

Parquet形式のデータをロードし、テーブルに変換します。
DEPTとJOB_TITLEのカラムへの変更のみを表示するSTREAMを作成してください

Parquetのデータは、
https://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_2/employees.parquet
にあります。

データの取り込みが済んだら、次のコマンドを実行します

UPDATE <table_name> SET COUNTRY = 'Japan' WHERE EMPLOYEE_ID = 8;
UPDATE <table_name> SET LAST_NAME = 'Forester' WHERE EMPLOYEE_ID = 22;
UPDATE <table_name> SET DEPT = 'Marketing' WHERE EMPLOYEE_ID = 25;
UPDATE <table_name> SET TITLE = 'Ms' WHERE EMPLOYEE_ID = 32;
UPDATE <table_name> SET JOB_TITLE = 'Senior Financial Analyst' WHERE EMPLOYEE_ID = 68;

結果は次のようになります

https://frostyfriday.org/wp-content/uploads/2022/07/End-Product-2048x349.png

DEPTとJOB_TITLEが変更されたUPDATEのみSTREAMに記録されています。
こちらを実現してみましょう！


**/

-----------------------------------------------------------------------------
-- 解法① INFER_SCHEMA を使う方法 
-----------------------------------------------------------------------------

-- parquet形式を読み込むFILE　　FORMATの作成
 create or replace file format week2_parquet type = 'parquet';

 -- STAGEの作成（↑で作成したFILE　　FORMATを使って）
 -- https://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_2/employees.parquet
 create or replace stage week2_ext_stage 
  url = 's3://frostyfridaychallenges/challenge_2/employees.parquet'
  file_format = (FORMAT_NAME = 'week2_parquet')
;

-- STAGE内を確認
list @week2_ext_stage;

select 
    $1
    , $2
    , $3
    , metadata$filename 
    , metadata$file_row_number
from 
    @week2_ext_stage
;
-- コンパイルエラー
-- $2, $3を設定したら「PARQUET ファイル形式は、型バリアント、オブジェクトまたは配列の列を1つだけ生成できます。the MATCH_BY_COLUMN_NAME copy option or  コピーと変換を使用して、データを個別の列にロードします。」

select 
    $1
    , metadata$filename 
    , metadata$file_row_number
from 
    @week2_ext_stage
;

-- parquetファイルからカラム構成を抽出してやる⇨INFER_SCHAMA
-- https://docs.snowflake.com/ja/sql-reference/functions/infer_schema?utm_source=snowscope&utm_medium=serp&utm_term=INFER_SCHEMA

SELECT *
FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@week2_ext_stage'
      , FILE_FORMAT=>'week2_parquet'    
    )
);

/**
COLUMN_NAME TYPE NULLABLE EXPRESSION FILENAMES ORDER_ID
employee_id	NUMBER(38, 0)	TRUE	$1:employee_id::NUMBER(38, 0)	challenge_2/employees.parquet	0
first_name	TEXT	TRUE	$1:first_name::TEXT	challenge_2/employees.parquet	1
last_name	TEXT	TRUE	$1:last_name::TEXT	challenge_2/employees.parquet	2
email	TEXT	TRUE	$1:email::TEXT	challenge_2/employees.parquet	3
**/

-- https://docs.snowflake.com/ja/sql-reference/sql/create-table?utm_source=snowscope&utm_medium=serp&utm_term=USING+TEMPLATE

-- INFER_SCHEMAを使って、CSVからカラム推定を行って、テーブルを作成
CREATE OR REPLACE TABLE week2_table
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    WITHIN GROUP (ORDER BY order_id)
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@week2_ext_stage',
          FILE_FORMAT=>'week2_parquet'
        )
      ));

desc table week2_table;

select * from week2_table;

-- ファイルの中身を投入
copy into week2_table from @week2_ext_stage ;
-- PARQUET ファイル形式は、型バリアント、オブジェクトまたは配列の列を1つだけ生成できます。the MATCH_BY_COLUMN_NAME copy option or  コピーと変換を使用して、データを個別の列にロードします。

copy into week2_table from @week2_ext_stage MATCH_BY_COLUMN_NAME = 'CASE_INSENSITIVE';
      
/**
file	status	rows_parsed	rows_loaded	error_limit	errors_seen	first_error	first_error_line	first_error_character	first_error_column_name
s3://frostyfridaychallenges/challenge_2/employees.parquet	LOADED	100	100	1	0				
**/

-- ロードされたテーブルを確認
select * from week2_table;
select
    "employee_id"
    , "dept"
    , "job_title"
from
    week2_table;

-- 変更管理で見たいのは、deptとjob_titleなのでそこだけを見るためのVIEWを作成
create view week2_view as
select
    "employee_id"
    , "dept"
    , "job_title"
from
    week2_table;

select * from week2_view;

-- streamを作る
CREATE OR REPLACE STREAM week2_stream
    ON VIEW week2_view
    ;

-- streamの中身を確認（この時点では空）
select * from week2_stream;

-- データの変更を行う（問題に記載のあったUPDATE文を発行）
UPDATE week2_table SET "country" = 'Japan' WHERE "employee_id" = 8;
select * from week2_stream; -- streamにはいらない

UPDATE week2_table SET "last_name" = 'Forester' WHERE "employee_id" = 22;
select * from week2_stream; -- streamにはいらない

UPDATE week2_table SET "dept" = 'Marketing' WHERE "employee_id" = 25;
select * from week2_stream; -- streamにはいる
/**
employee_id	dept	job_title	METADATA$ROW_ID	METADATA$ACTION	METADATA$ISUPDATE
25	Marketing	Assistant Professor	04041e6bda647a5bbb25983e3e99bb6aa399cd58	INSERT	TRUE
25	Accounting	Assistant Professor	04041e6bda647a5bbb25983e3e99bb6aa399cd58	DELETE	TRUE
**/

UPDATE week2_table SET "title" = 'Ms' WHERE "employee_id" = 32;
select * from week2_stream; -- streamにはいらない

UPDATE week2_table SET "job_title" = 'Senior Financial Analyst' WHERE "employee_id" = 68;
select * from week2_stream;
/**
employee_id	dept	job_title	METADATA$ROW_ID	METADATA$ACTION	METADATA$ISUPDATE
25	Marketing	Assistant Professor	04041e6bda647a5bbb25983e3e99bb6aa399cd58	INSERT	TRUE
68	Product Management	Senior Financial Analyst	2b5f97e0b354b2fd390e7a3ed40923ae2f324b95	INSERT	TRUE
68	Product Management	Assistant Manager	2b5f97e0b354b2fd390e7a3ed40923ae2f324b95	DELETE	TRUE
25	Accounting	Assistant Professor	04041e6bda647a5bbb25983e3e99bb6aa399cd58	DELETE	TRUE
**/

-----------------------------------------------------------------------------
-- 解法② INFER_SCHEMAを使わない方法
-----------------------------------------------------------------------------

use role accountadmin;

-- parquet形式を読み込むFILE　　FORMATの作成
create or replace file format week2_parquet_2 type = 'parquet';

-- 解法①との違いは、URLとderectory
create or replace stage week2_ext_stage_2
  url = 's3://frostyfridaychallenges/challenge_2/'
  file_format = (FORMAT_NAME = 'week2_parquet_2')
  	directory = ( enable = true );
;

list @week2_ext_stage_2;
-- Snowsight でStageをみると　directory = ( enable = true );　の違いがよく分かります

SELECT *
FROM TABLE(
    INFER_SCHEMA(
      location =>'@week2_ext_stage_2'
      , file_format => 'week2_parquet_2'
      , files => 'employees.parquet'
      , ignore_case => true
    )
);

create or replace table week2_table_2 
(   employee_id number , 
    first_name varchar , 
    last_name varchar , 
    email varchar , 
    street_num number , 
    street_name varchar , 
    city varchar , 
    postcode varchar , 
    country varchar , 
    country_code varchar , 
    time_zone varchar , 
    payroll_iban varchar , 
    dept varchar , 
    job_title varchar , 
    education varchar , 
    title varchar , 
    suffix varchar 
);

copy into week2_table_2
from 
(   select $1:employee_id::number, 
           $1:first_name::varchar, 
           $1:last_name::varchar, 
           $1:email::varchar, 
           $1:street_num::number, 
           $1:street_name::varchar, 
           $1:city::varchar, 
           $1:postcode::varchar, 
           $1:country::varchar, 
           $1:country_code::varchar, 
           $1:time_zone::varchar, 
           $1:payroll_iban::varchar, 
           $1:dept::varchar, 
           $1:job_title::varchar, 
           $1:education::varchar, 
           $1:title::varchar, 
           $1:suffix::varchar
	from '@week2_ext_stage_2/employees.parquet') 
FILE_FORMAT = week2_parquet_2;

-- 後は一緒
-- 解法①との違いは、ignore_case => true　で、カラム名に　　”が不要に
create view week2_view_2 as
select
    employee_id
    , dept
    , job_title
from
    week2_table_2;

select * from week2_view_2;

-- streamを作る
CREATE OR REPLACE STREAM week2_stream_2
    ON VIEW week2_view_2
;
