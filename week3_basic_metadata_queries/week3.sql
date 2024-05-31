/**
Week3 - Basic Metadata Queries

Week1では、S3に配置したデータの取り込みについて説明しましたが、ここWeek3では更に一歩進んだチャレンジです。

基本的に驚くことはありませが、作り始めると頭を悩ませるかもしれません

世界でも有数のホワイト企業であるFrosty Friday 株式会社　には、csvデータが多数配備されているS3バケットがあります。
これらのデータはそれほど複雑なデータではなく、すべて同じカラム構成のデータです。
これらのファイルをすべて一つのテーブルに取り込む必要があります。

ただし、重要なデータもアップロードされる場合があります。
この重要なファイルには通常とは異なる命名法則があり、その場合には特別な処理をしなくてはいけません。
参照用にメタデータを別途テーブルに保持する必要があります。
S3内には、keyword.csv というファイルで、この中には重要なファイルを示すキーワードが登録されています。

課題：
ステージ内の keyword.csvに登録されているキーワードのいずれかを含むファイルをリストアップするテーブルを作成してください。
S3bakettono URIは、s3://frostyfridaychallenges/challenge_3/ になります。

結果：
結果は次のようになります
https://frostyfriday.org/wp-content/uploads/2022/07/result-2048x218.png


**/

use database frosty_friday;
use schema public;

create or replace stage week3_ext_stage
  URL='s3://frostyfridaychallenges/challenge_3/';

list @week3_ext_stage;
/**
s3://frostyfridaychallenges/challenge_3/keywords.csv
s3://frostyfridaychallenges/challenge_3/week3_data1.csv
s3://frostyfridaychallenges/challenge_3/week3_data2.csv
s3://frostyfridaychallenges/challenge_3/week3_data2_stacy_forgot_to_upload.csv
s3://frostyfridaychallenges/challenge_3/week3_data3.csv
s3://frostyfridaychallenges/challenge_3/week3_data4.csv
s3://frostyfridaychallenges/challenge_3/week3_data4_extra.csv
s3://frostyfridaychallenges/challenge_3/week3_data5.csv
s3://frostyfridaychallenges/challenge_3/week3_data5_added.csv
**/
select $1, $2, $3, $4 from @week3_ext_stage/keywords.csv;

select 
    $1
    , $2
    , $3
    , metadata$filename 
    , metadata$file_row_number
from 
    @week3_ext_stage/keywords.csv
;

create or replace table week3_keyword_table (
    keyword text
    , added_by text
    , nonsense number
    , file_name text
    , file_row_number number
)
;


create or replace file format week3_csv_format
  type = CSV
  parse_header = true
;

copy into week3_keyword_table ( keyword, added_by, nonsense, file_name,  file_row_number)
from 
    ( 
        select 
            $1 
            , $2
            , $3
            , metadata$filename 
            , metadata$file_row_number
        from 
            @week3_ext_stage/keywords.csv
    )
FILE_FORMAT = (FORMAT_NAME = 'week3_csv_format');


select 
    $1
    , $2
    , $3
    , metadata$filename 
    , metadata$file_row_number
from 
    @week3_ext_stage/week3_data1.csv
;
select 
    $1
    , $2
    , $3
    , metadata$filename 
    , metadata$file_row_number
from 
    @week3_ext_stage/week3_data2.csv
;
