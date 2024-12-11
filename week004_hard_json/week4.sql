/**
Frosty Friday 社のコンサルタントは、Frost大学の歴史学部の分析の仕事を受注しました。
分析のために、データウェアハウスに　歴史上の君主　のデータを投入し分析に使いたいと考えています。
今回の課題は、https://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_4/Spanish_Monarchs.json
にあるJSONファイルをデータウェアハウスに取り込み、下記の画像のようにテーブルを解析してください

https://frostyfriday.org/wp-content/uploads/2022/07/Screenshot-2022-07-14-at-20.08.12.png

※上記の画像が読めない場合は、クリックして大きな画像を閲覧してください。

- ニックネームと配偶者
- 誕生順のID
- ファイル内に出現する順序で Inter-House ID
- 最後は26行になるはず

■ヒント
- 途中で列を失わないように
- JSONを変換するときには利用可能なすべての出力とそのパラメータを必ず調査してください
**/

use role sysadmin;
use warehouse gaku_wh;
use database frosty_friday;
create or replace schema week4;

create or replace stage week4_ext_stage
  URL='s3://frostyfridaychallenges/challenge_4/';

ls @week4_ext_stage;


create or replace file format week4_json_file_format
    type = JSON
    STRIP_OUTER_ARRAY = TRUE -- JSON パーサーに、外側の括弧（つまり [ ]）を削除するように指示するブール値。
;

select 
    $1::variant as v
from @week4_ext_stage/Spanish_Monarchs.json
(file_format => 'week4_json_file_format')
;

create or replace file format week4_json_file_format_non_strip
    type = JSON
--    STRIP_OUTER_ARRAY = TRUE -- JSON パーサーに、外側の括弧（つまり [ ]）を削除するように指示するブール値。
;

select 
    $1::variant as v
from @week4_ext_stage/Spanish_Monarchs.json
(file_format => 'week4_json_file_format_non_strip')
;

create or replace table week4_raw (
    v variant
    , file_name string
    , file_row_number number
);

copy into week4_raw 
from (
    select
        $1::variant as v
        , metadata$filename as file_name
        , metadata$file_row_number as file_row_number
    from
        @week4_ext_stage/Spanish_Monarchs.json
        (file_format => 'week4_json_file_format')
)
;

select v from week4_raw;

select 
    value
from 
    week4_raw
    , LATERAL FLATTEN(v:"Houses") as h
;

select 
    h.value as h_value
    , m.value as m_value
from 
    week4_raw
    , LATERAL FLATTEN(v:"Houses") as h
    , LATERAL FLATTEN(h.value:"Monarchs") as m
;

create or replace view spanish_monarches_view
as
select
    ROW_NUMBER() OVER (ORDER BY m.value:"Birth"::date) as ID
    , m.index + 1 as INTER_HOUSE_ID
    , v:"Era"::string as ERA
    , h.value:"House"::string as HOUSE
    , m.value:"Name"::string as NAME
    , m.value:"Nickname"[0]::string as NICKNAME_1
    , m.value:"Nickname"[1]::string as NICKNAME_2
    , m.value:"Nickname"[3]::string as NICKNAME_3
    , m.value:"Birth"::date as BIRTH
    , m.value:"Place of Birth"::string as PLACE_OF_BIRTH
    , m.value:"Start of Reign"::date as START_OF_REIGN
    , m.value:"Consort\\/Queen Consort"[0]::string as CONSORT_OR_QUEEN_CONSORT_1
    , m.value:"Consort\\/Queen Consort"[1]::string  as CONSORT_OR_QUEEN_CONSORT_2
    , m.value:"Consort\\/Queen Consort"[2]::string  as CONSORT_OR_QUEEN_CONSORT_3
    , m.value:"End of Reign"::date as END_OF_REIGN
    , m.value:"Duration"::string as DURATION
    , m.value:"Death"::date as DEATH
    , m.value:"Age at Time of Death"::string as AGE_AT_TIME_OF_DEATH_YEARS
    , m.value:"Place of Death"::string as PLACE_OF_DEATH
    , m.value:"Burial Place"::string as BURIAL_PLACE
from 
    week4_raw
    , LATERAL FLATTEN(v:"Houses") as h
    , LATERAL FLATTEN(h.value:"Monarchs") as m
;

select * from spanish_monarches_view;
