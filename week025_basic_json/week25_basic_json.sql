use database FROSTY_FRIDAY;
use role SYSADMIN;
use warehouse GAKU_WH;
create or replace schema week25;

-- https://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_25/ber_7d_oct_clim.json
-- stageを作ります。Challangeでは↑のURL形式でしたが、S3形式だと下記になります
create or replace stage week25_stage
  URL='s3://frostyfridaychallenges/challenge_25/';

-- 提供ファイルの確認
list @week25_stage;
/**
name	size	md5	last_modified
s3://frostyfridaychallenges/challenge_25/ber_7d_oct_clim.json	110924	c6050fec5b28e2c47a50b596452e9ff7	Tue, 29 Nov 2022 14:26:51 GMT
**/

-- JSONのFile Formatを作成。STRIP_OUTER_ARRAYは今回のデータでは不要だが、あっても問題はないので入れている
create or replace file format week25_json_file_format
    type = JSON
    STRIP_OUTER_ARRAY = TRUE -- JSON パーサーに、外側の括弧（つまり [ ]）を削除するように指示するブール値。
;

-- JSONフォーマットで読み込み
select 
    $1::variant as v
from @week25_stage/ber_7d_oct_clim.json
(file_format => 'week25_json_file_format')
;

-- デフォルト（＝CSV）で読み込むと・・・
select $1, $2 from @week25_stage/ber_7d_oct_clim.json;


---------------------------------------------------------------
-- 解法① Pattern.1
---------------------------------------------------------------
-- JSONファイルを取り込むテーブルの作成（メタデータ付き）
create or replace table week25_raw (
    v variant
    , file_name string
    , file_row_number number
);

copy into week25_raw 
from (
    select
        $1::variant as v
        , metadata$filename as file_name
        , metadata$file_row_number as file_row_number
    from
        @week25_stage/ber_7d_oct_clim.json
        (file_format => 'week25_json_file_format')
)
;

select * from week25_raw;

with sources as (
select 
        sources.value::variant as sources
    from 
        week25_raw
        , LATERAL FLATTEN(v:"sources") as sources
)
select 
    sources
    , sources:distance::number as distance
    , sources:dwd_station_id::string as dwd_station_id
    , sources:first_record::string as first_record
    , sources:height::number as height
    , sources:id::string as id
    , sources:last_record::datetime as last_record
    , sources:lat::float as lat
    , sources:lon::float as lon
    , sources:observation_type::string as observation_type
    , sources:station_name::string as station_name
    , sources:wmo_station_id::string as wmo_station_id
from 
    sources
;

with weathers as (
    select 
        weathers.value::variant as weathers
    from 
        week25_raw
        , LATERAL FLATTEN(v:"weather") as weathers
)
-- select * from weathers;
select 
    weathers
    , weathers:cloud_cover::number as cloud_cover
    , weathers:condition::string as condition
    , weathers:dew_point::string as dew_point
    , weathers:fallback_source_ids::variant as fallback_source_ids
    , weathers:icon::string as icon
    , weathers:precipitation::float as precipitation
    , weathers:pressure_msl::float as pressure_msl
    , weathers:relative_humidity::float as relative_humidity
    , weathers:source_id::string as source_id
    , weathers:sunshine::number as sunshine
    , weathers:temperature::number as temperature
    , weathers:timestamp::timestamp_tz as timestamp
    , weathers:visibility::number as visibility
    , weathers:wind_direction::number as wind_direction
    , weathers:wind_gust_direction::number as wind_gust_direction
    , weathers:wind_gust_speed::float as wind_gust_speed
    , weathers:wind_speed::float as wind_speed
from 
    weathers;

-- テーブル化
create or replace table weather_parsed as 
with weathers as (
    select 
        weathers.value::variant as weathers
    from 
        week25_raw
        , LATERAL FLATTEN(v:"weather") as weathers
)
select 
    weathers
    , weathers:cloud_cover::number as cloud_cover
    , weathers:condition::string as condition
    , weathers:dew_point::string as dew_point
    , weathers:fallback_source_ids::variant as fallback_source_ids
    , weathers:icon::string as icon
    , weathers:precipitation::float as precipitation
    , weathers:pressure_msl::float as pressure_msl
    , weathers:relative_humidity::float as relative_humidity
    , weathers:source_id::string as source_id
    , weathers:sunshine::number as sunshine
    , weathers:temperature::float as temperature
    , weathers:timestamp::timestamp_tz as timestamp
    , weathers:visibility::number as visibility
    , weathers:wind_direction::number as wind_direction
    , weathers:wind_gust_direction::number as wind_gust_direction
    , weathers:wind_gust_speed::float as wind_gust_speed
    , weathers:wind_speed::float as wind_speed
from 
    weathers
;

select * from weather_parsed;

-- Step3 create agg table
create or replace table weather_agg as
select 
    timestamp::date as date 
    , array_agg(distinct icon) within group (order by icon asc) as icon_array -- https://docs.snowflake.com/ja/sql-reference/functions/array_agg
    , avg(temperature) as avg_temperature
    , sum(precipitation) as total_precipitation
    , avg(wind_speed) as avg_wind
    , avg(relative_humidity) as avg_humidity
from 
    weather_parsed
group by date
order by date desc
;

select * from weather_agg;

---------------------------------------------------------------
-- 解法② Pattern.2 Using INFER_SCHEMA
---------------------------------------------------------------
SELECT *
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@week25_stage/ber_7d_oct_clim.json'
      , FILE_FORMAT=>'week25_json_file_format'
      )
    );
create or replace table week25_raw_2
  using template (
    select array_agg(object_construct(*))
      from table(
        infer_schema(
          LOCATION=>'@week25_stage/ber_7d_oct_clim.json',
          FILE_FORMAT=>'week25_json_file_format'
        )
      ));
desc table week25_raw_2;

-- selectのなかに各文字列を生成
with source as (
SELECT expression
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@week25_stage/ber_7d_oct_clim.json'
      , FILE_FORMAT=>'week25_json_file_format'
      )
    )
)
select listagg(expression, ',') from source;

copy into week25_raw_2 from (
select
    $1:sources::ARRAY,$1:weather::ARRAY -- <- select listagg(expression, ',') from source;の結果を貼り付け
from @week25_stage/ber_7d_oct_clim.json
(file_format => week25_json_file_format) t)
on_error = 'Continue' ;

select * from week25_raw_2;

-- もしすでにこのファイルを作っていたら
-- remove @~/week25.json;
copy into @~/week25.json from (select "weather" from week25_raw_2) single = true FILE_FORMAT = (FORMAT_NAME = week25_json_file_format);

list @~;

select $1::variant from @~/week25.json (file_format => 'week25_json_file_format');

SELECT *
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@~/week25.json'
      , FILE_FORMAT=>'week25_json_file_format'
      )
    );

CREATE or replace TABLE weather_parsed_2
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@~/week25.json',
          FILE_FORMAT=>'week25_json_file_format',
          IGNORE_CASE => TRUE
        )
      ));
select * from weather_parsed_2;
desc table weather_parsed_2;

with source as (
SELECT expression
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@~/week25.json'
      , FILE_FORMAT=>'week25_json_file_format'
      )
    )
)
select listagg(expression, ',') from source;

copy into weather_parsed_2 from (
select
    $1:cloud_cover::NUMBER(3, 0),$1:condition::TEXT,$1:dew_point::NUMBER(3, 1),$1:fallback_source_ids::OBJECT,$1:icon::TEXT,$1:precipitation::NUMBER(2, 1),$1:pressure_msl::NUMBER(6, 2),$1:relative_humidity::NUMBER(3, 0),$1:source_id::NUMBER(5, 0),$1:sunshine::NUMBER(2, 0),$1:temperature::NUMBER(3, 1),$1:timestamp::TIMESTAMP_NTZ,$1:visibility::NUMBER(5, 0),$1:wind_direction::NUMBER(3, 0),$1:wind_gust_direction::NUMBER(3, 0),$1:wind_gust_speed::NUMBER(3, 1),$1:wind_speed::NUMBER(3, 1)
from @~/week25.json
(file_format => week25_json_file_format) t)
on_error = 'Continue' ;

select * from weather_parsed_2;

-- Step3 create agg table
create or replace table weather_agg_2 as
select 
    timestamp::date as date 
    , array_agg(distinct icon) within group (order by icon asc) as icon_array -- https://docs.snowflake.com/ja/sql-reference/functions/array_agg
    , avg(temperature) as avg_temperature
    , sum(precipitation) as total_precipitation
    , avg(wind_speed) as avg_wind
    , avg(relative_humidity) as avg_humidity
from 
    weather_parsed_2
group by date
order by date desc
;

select * from weather_agg_2;

----------------------------------------------------------------------
-- 解法②' Pattern.2' Using INFER_SCHEMA and match_by_column_name
-- よりきれいに完結に記載する
------------------------------------------------------------------------ 

CREATE TABLE week25_raw_3
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@week25_stage/ber_7d_oct_clim.json'
          , FILE_FORMAT=>'week25_json_file_format'
          , IGNORE_CASE => TRUE
        )
      ));

desc table week25_raw_3;

copy into week25_raw_3 from @week25_stage/ber_7d_oct_clim.json
file_format = week25_json_file_format
match_by_column_name = case_insensitive; 

select * from week25_raw_3;

-- もしすでにこのファイルを作っていたら
remove @~/week25.json;
copy into @~/week25.json from (select "weather" from week25_raw_2) single = true FILE_FORMAT = (FORMAT_NAME = week25_json_file_format);

list @~;

select $1::variant from @~/week25.json (file_format => 'week25_json_file_format');

CREATE or replace TABLE weather_parsed_3
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@~/week25.json'
          , FILE_FORMAT=>'week25_json_file_format'
          , IGNORE_CASE => TRUE
        )
      ));
select * from weather_parsed_3;

copy into weather_parsed_3 from @~/week25.json
file_format = week25_json_file_format
match_by_column_name = case_insensitive;

select * from weather_parsed_3;

create or replace table weather_agg3 as 
select 
    timestamp::date as date 
    , array_agg(distinct icon) within group (order by icon asc) as icon_array -- https://docs.snowflake.com/ja/sql-reference/functions/array_agg
    , avg(temperature) as avg_temperature
    , sum(precipitation) as total_precipitation
    , avg(wind_speed) as avg_wind
    , avg(relative_humidity) as avg_humidity
from 
    weather_parsed_3
group by date
order by date desc
;

select * from weather_agg3;
