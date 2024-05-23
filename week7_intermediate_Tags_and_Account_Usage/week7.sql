/**
Week7 - 中級 - Tags, Account_Usage

悪役になるのはそれだけで十分難しいことです。しかしデータの問題は善人だけの問題ではありません。
悪役は多くの俯瞰的な情報を持っている。EVIL INC.はSnowflakeの使用を開始した。

開発している、超兵器（スーパーウェポン）の最も重要な部分、キャッチフレーズの情報が漏洩していることが発覚しました。
幸いなことに、誰がどの情報にアクセスしたかが追跡できるようにタグを設定していました。

今回の課題は、「Level Super Secret A+++++++」とタグ付けされたデータに誰がアクセスしたかを突き止めることです。
データにアクセスするユーザーを作るのはちょっと難しすぎるかもしれないので、ユーザーの代わりにロールを使っています。

以下は、チャレンジの前に実行していただきたい予備コードです。account_usageの更新には2時間かかるので、以下のコードを実行し、少なくとも数時間後にチャレンジに戻ってくることをお勧めする。

1) データベースを新規に作っていい場合のSQLはこちら
2）データベースを新規に作りたくない場合のSQLはこちら

求める結果はこちら
TAG_NAME, TAG_VALUE, MIN(QUERY_ID), TABLE_NAME, ROLE_NAME
SECURITY_CLASS, Level Super Secret A++++++, 0125ded8-0000-223e-0000-914900053246,  FROSTY_FRYDAY.CHALLENGES.WEEK7_VILLAN_INFORMATION, USER1
SECURITY_CLASS, Level Super Secret A++++++, 0125ded8-0000-223e-0000-914900053246,  FROSTY_FRYDAY.CHALLENGES.WEEK7_WEAPON_STORAGE_LOCATION, USER3

**/

------- 回答
use role accountadmin;
use warehouse compute_wh;
-- database, schemaは設定しなくても今回は良さそうではある
-- use database ff_week_7;
-- use schema public;

with object_ids as (
    select 
        tag_name
        , tag_value
        , object_id
    from
        snowflake.account_usage.tag_references
    where
        tag_value = 'Level Super Secret A+++++++'
)
-- select * from object_ids;
,
query_history as (
    select
        query_id
        , role_name
    from
        snowflake.account_usage.query_history
)
-- select distinct object_id from object_ids limit 10;

, accessed_tables as (
	select 
        access_history.*
        , flattened_base_objects_accessed.value
	from
        snowflake.account_usage.access_history
		, lateral flatten(base_objects_accessed) as flattened_base_objects_accessed
	WHERE
        exists (
            select 1 from object_ids 
            where 
                flattened_base_objects_accessed.value['objectId']::number = object_ids.object_id)
)
-- select * from accessed_tables;
, potential_leaks as (
    select 
        accessed_tables.* 
        , query_history.role_name
    from 
        accessed_tables
    	inner join snowflake.account_usage.query_history
    	on
    	   query_history.query_id = accessed_tables.query_id
)
, add_tag_info as (
select 
    object_ids.tag_name
    , object_ids.tag_value
    , potential_leaks.query_id
    , potential_leaks.value['objectName']::string as table_name 
    , potential_leaks.role_name
--    , potential_leaks.value['objectId']::number as object_id
--    , object_ids.* 
from 
    potential_leaks
    left outer join object_ids
        on object_id = object_ids.object_id
)
select 
    tag_name
    , tag_value
    , min(query_id)
    , table_name
    , role_name
from 
    add_tag_info
group by all
;

select 
    tag_name
    , tag_value
    , object_id
from
    snowflake.account_usage.tag_references
where
    tag_value = 'Level Super Secret A+++++++'
;
--　うまくいかなかった解法（Lambda式FILTERをつかってみた）
-- https://docs.snowflake.com/en/sql-reference/functions/filter
/**
SELECT FILTER(
  [
    {'name':'Pat', 'value': 50},
    {'name':'Terry', 'value': 75},
    {'name':'Dana', 'value': 25}
  ],
  a -> a:value >= 50) AS "Filter >= 50";
**/
select
    query_id
    , base_objects_accessed
    , flattened_base_objects_accessed.value['objectId']::string  as object_id
    , flattened_base_objects_accessed.value['objectName']::string  as object_name
from 
    snowflake.account_usage.access_history
    , lateral flatten(base_objects_accessed) as flattened_base_objects_accessed
where
    array_size(filter(base_objects_accessed, a -> a:objectId in (19483, 19487))) > 0
order by
    query_start_time desc
    limit 100
;

-- うまくいかなかった
with object_ids as (
    select 
        tag_name
        , tag_value
        , object_id
    from
        snowflake.account_usage.tag_references
    where
        tag_value = 'Level Super Secret A+++++++'
)
select
    query_id
    , base_objects_accessed
    , flattened_base_objects_accessed.value['objectId']::string  as object_id
    , flattened_base_objects_accessed.value['objectName']::string  as object_name
from 
    snowflake.account_usage.access_history
    , lateral flatten(base_objects_accessed) as flattened_base_objects_accessed
where
    array_size(filter(base_objects_accessed, a -> a:objectId in (select distinct object_id from object_ids))) > 0
order by
    query_start_time desc
    limit 100
;
-- SQL実行の内部エラー
-- エラー 300010のため、処理は中止されました：1094633624。インシデント 7573493。 
-- 残念ながらFILTERには、サブクエリはまだ使えなさそう。

