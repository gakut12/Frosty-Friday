/**
今週は空間関数の問題です。
フロスティロビングでは、次期英国総選挙で一部の候補者を支援しようとしている。
その際に、候補者の地域ごとでの支持の広がりを理解することが必要です。

あなたの仕事は、国/地域と議会の議席の両方をポリゴンに構築し、ウェストミンスターの議席の数が地域のポリゴンと 交差する数を計算することです。

いくつかの議席は2つの異なる地域に属していたり、どの地域にも属していなかったり（北アイルランドは提供されたデータに含まれていない）、単に厄介なだけの場合もあるので注意が必要だ。

例えば、マル島はスコットランドの「パート34」であり、アーガイル・アンド・ビュート選挙区の「パート12」である
国の地域データはhttps://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_6/nations_and_regions.csv
ウェストミンスター選挙区のデータは　https://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_6/westminster_constituency_points.csv

出典: ONS、オープン ジオグラフィー ポータル

最終結果：

NATION_OR_REGION	INTERSECTING_CONSTITUENCIES
South East	116
North West	95
London	91
East of England	82
West Midlands	80
East Midlands	78
Yorkshire and The Humber	76
South West	70
Scotland	63
Wales	52
North East	33
**/

use role sysadmin;
use warehouse compute_wh;
use database FROSTY_FRIDAY;

create schema FF_WEEK6;
use schema FF_WEEK6;

create or replace stage week6_ext_stage
  URL='s3://frostyfridaychallenges/challenge_6/';

list @week6_ext_stage;

select
    $1
    , $2
    , $3
    , $4
    , $5
    , $6
    , $7
from
    @week6_ext_stage/nations_and_regions.csv;

create or replace file format ff_week6_format
    type = csv
    PARSE_HEADER = true
    field_optionally_enclosed_by = '"'
;

select *
    from table (
        infer_schema (
            location=>'@week6_ext_stage/nations_and_regions.csv'
            , file_format=>'ff_week6_format'
        )
    );

create or replace table nations_and_regions
    using template (
        select 
            array_append(
            array_append(
                array_agg(object_construct(*)),
                {
                    'COLUMN_NAME': 'FILENAME',
                    'NULLABLE': true,
                    'TYPE': 'TEXT'
                }::VARIANT
                )
                , {
                    'COLUMN_NAME': 'FILE_RAW_NUMBER',
                    'NULLABLE': true,
                    'TYPE': 'NUMBER'
                }::VARIANT
            )
            from table (
                infer_schema (
                    location=>'@week6_ext_stage/nations_and_regions.csv'
                    , file_format=>'ff_week6_format'
                )
            )
    );
    --  ↑諦めた

create or replace table nations_and_regions
    using template (
        select 
            array_agg(object_construct(*))
            from table (
                infer_schema (
                    location=>'@week6_ext_stage/nations_and_regions.csv'
                    , file_format=>'ff_week6_format'
                    , IGNORE_CASE => TRUE
                )
            )
    );    

desc table nations_and_regions;

copy into nations_and_regions from @week6_ext_stage/nations_and_regions.csv
match_by_column_name = case_Insensitive
include_metadata = (
    file_raw_number = METADATA$file_raw_number, filename = METADATA$FILENAME);
-- https://docs.snowflake.com/en/release-notes/2024/8_17#new-copy-option-include-metadata
-- だめだった

COPY into nations_and_regions from @week6_ext_stage/nations_and_regions.csv FILE_FORMAT = (FORMAT_NAME= 'ff_week6_format') MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;

select * from nations_and_regions;

--- https://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_6/westminster_constituency_points.csv
---

create or replace table westminster_constituency_points
    using template (
        select 
            array_agg(object_construct(*))
            from table (
                infer_schema (
                    location=>'@week6_ext_stage/westminster_constituency_points.csv'
                    , file_format=>'ff_week6_format'
                    , IGNORE_CASE => TRUE
                )
            )
    );

desc table westminster_constituency_points;

select *
    from table (
        infer_schema (
            location=>'@week6_ext_stage/westminster_constituency_points.csv'
            , file_format=>'ff_week6_format'
            , MAX_RECORDS_PER_FILE => 5000 -- これがないと　Error with CSV header: header defined (5) columns while data contains more columns
            , IGNORE_CASE => TRUE
        )
    );
create or replace table westminster_constituency_points
    using template (
        select 
            array_agg(object_construct(*))
            from table (
                infer_schema (
                    location=>'@week6_ext_stage/westminster_constituency_points.csv'
                    , file_format=>'ff_week6_format'
                    , MAX_RECORDS_PER_FILE => 5000 -- これがないと　Error with CSV header: header defined (5) columns while data contains more columns
                    , IGNORE_CASE => TRUE
                )
            )
    );
COPY into westminster_constituency_points from @week6_ext_stage/westminster_constituency_points.csv FILE_FORMAT = (FORMAT_NAME= 'ff_week6_format') MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE
ON_ERROR = CONTINUE
;
/**
file	status	rows_parsed	rows_loaded	error_limit	errors_seen	first_error	first_error_line	first_error_character	first_error_column_name
s3://frostyfridaychallenges/challenge_6/westminster_constituency_points.csv	PARTIALLY_LOADED	4096	4096	4096	2	Error with CSV header: header defined (5) columns while data contains more columns
  ファイル「challenge_6/westminster_constituency_points.csv」、行 5064、文字 50
  行 5063、列 "WESTMINSTER_CONSTITUENCY_POINTS"["part":5]			
**/

select $1, $2, $3, $4, $5, $6, $7, metadata$file_row_number from @week6_ext_stage/westminster_constituency_points.csv
where metadata$file_row_number > 5000;
/**
Aylesbury	166	-0.673495	51.768465	1			5063
"Ayr	 Carrick and Cumnock"	0	-5.106532	55.251906	1		5064
**/

create or replace file format ff_week6_format
    type = csv
    parse_header = true
    field_optionally_enclosed_by = '"' -- 追加
;


truncate westminster_constituency_points;

COPY into westminster_constituency_points 
from 
    @week6_ext_stage/westminster_constituency_points.csv 
    FILE_FORMAT = (FORMAT_NAME= 'ff_week6_format') 
    MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE
;


table westminster_constituency_points;

-----------------------------------------
select 
    nation_or_region_name
    , part
    , 'POLYGON(('|| listagg(longitude || ' ' || latitude, ',') within group (order by sequence_num) ||'))' as polygon
from 
    nations_and_regions
group by 
    nation_or_region_name
    , part
;

----------------------------------------
select constituency
, part
, 'POLYGON(('|| listagg(longitude || ' ' || latitude, ',') within group (order by sequence_num) ||'))' as polygon
from 
    westminster_constituency_points
group by 
    constituency
    , part;

-------

select 
    nation_or_region_name
    , part
    , to_geography('POLYGON(('|| listagg(longitude || ' ' || latitude, ',') within group (order by sequence_num) ||'))') as polygon
from 
    nations_and_regions
group by 
    nation_or_region_name
    , part
;

select 
    constituency
    , part
    , to_geography('POLYGON(('||listagg(longitude || ' ' || latitude, ',') within group (order by sequence_num)  ||'))') as polygon
from 
    westminster_constituency_points
group by 
    constituency
    , part;

-------------------------------------------------------
with 
nations_and_regions_parts as(
    select 
        nation_or_region_name
        , type
        , part
        , to_geography('POLYGON(('||listagg(longitude || ' ' || latitude, ',') within group (order by sequence_num)||'))') as polygon
    from 
        nations_and_regions
    group by 
        nation_or_region_name
        , type
        , part
    )
, westminster_constituency_points_parts as (
    select 
        constituency
        , part
        , to_geography('POLYGON(('|| listagg(longitude || ' ' || latitude, ',') within group (order by sequence_num)||'))') as polygon
    from 
        westminster_constituency_points
    group by 
        constituency
        , part
    )
, nations_and_regions as (
    select 
        nation_or_region_name
        , st_collect(nrp.polygon) as polygon
    from 
        nations_and_regions_parts nrp
    group by 
        nation_or_region_name
)
, westminster_constituency_points as (
    select 
        constituency
        , st_collect(wcpp.polygon) as polygon
    from 
        westminster_constituency_points_parts wcpp
    group by 
        constituency
)
, intersections as (
    select 
        nr.nation_or_region_name
        , st_intersects(nr.polygon, wcp.polygon) intersects
     from 
        nations_and_regions nr
        , westminster_constituency_points wcp
), final as (
    select 
        i.nation_or_region_name as nation_or_region
        , count(*) as intersecting_constituencies
    from
        intersections i
    where  
        i.intersects = true
    group by 
        i.nation_or_region_name
)
select * from final
;
