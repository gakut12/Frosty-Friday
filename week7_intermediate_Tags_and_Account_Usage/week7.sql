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

use role accountadmin;

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
/**
, ng_use_filter as (
    select
        query_id
        , base_objects_accessed
        , filter(base_objects_accessed, a -> a:objectId in (select distinct object_id from object_ids)) as objectId_1
    from 
        snowflake.account_usage.access_history 
    where
        array_size(objectId_1) > 0
    order by
        query_start_time desc
    limit 100
    -- エラー 300010のため、処理は中止されました：1094633624。インシデント 7573493。 
    -- 残念ながらFILTERには、サブクエリはまだ使えなさそう
)
**/
, accessed_tables as (
	select 
        s.*
        , l.value
	from
        snowflake.account_usage.access_history as s
		, lateral flatten(base_objects_accessed) as l
	WHERE
        exists (
            select 1 from object_ids 
            where 
                l.value['objectId']::number = object_ids.object_id)
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
