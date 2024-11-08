/**
今日は金曜日です。JSON 解析の腕を磨くには最高の日です!

最終結果

以下を実行した場合、最終的に次のような結果になります。

select *
from (
    <your query goes here>
) sub
where word like 'l%';

正しい場合、（「where word like 'l%'」フィルターなし）

count(word) は 32,295 行を取得します。
count(distinct word) で 3,000 行が取得されます
データソース:

https://www.ef.co.uk/english-resources/english-vocabulary/top-3000-words/
https://dictionaryapi.dev/
ボーナスポイント

幸運にも次のいずれかの地域にいる場合は、バリアント パスを使用してテーブルに検索最適化を適用してみてください。
**/

use role sysadmin;
use warehouse gaku_wh;

create or replace schema week16;
use schema week16;

create or replace file format json_ff
    type = json
    strip_outer_array = TRUE;
    
create or replace stage week_16_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_16/'
    file_format = json_ff;

create or replace table week16 as
select t.$1:word::text word, t.$1:url::text url, t.$1:definition::variant definition  
from @week_16_frosty_stage (file_format => 'json_ff', pattern=>'.*week16.*') t;

---
select * from week16 where word like 'l%';


select 
    word
    , url
    , d.value
from 
    week16
    , lateral flatten(definition) as d
where word like 'l%';
;

select 
    word
    , url
--    , d.value as definition_value
    , meanings.value as meanings_value
    , meanings.value:partOfSpeech as partOfSpeech
    , meanings.value:synonyms as general_synonyms
from 
    week16
    , lateral flatten(definition) as d
    , lateral flatten(d.value:"meanings") as meanings
where word like 'l%';
;


select 
    word
    , url
--    , d.value as definition_value
--    , meanings.value as meanings_value
    , meanings.value:partOfSpeech::string as partOfSpeech
    , meanings.value:synonyms::string as general_synonyms
    , meanings.value:antonyms::string as general_antonyms
--    , definitions.value as definitions_value
    , definitions.value:definition::string as difinition
    , definitions.value:example::string as exanple_if_applicable
    , definitions.value:synonyms::string as difinitional_synonyms
    , definitions.value:antonyms::string as difinitional_antonyms
from 
    week16
    , lateral flatten(definition) as d
    , lateral flatten(d.value:"meanings") as meanings
    , lateral flatten(meanings.value:"definitions") as definitions
where word like 'l%';
;
