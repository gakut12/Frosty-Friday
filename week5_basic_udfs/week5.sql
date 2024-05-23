/**
今週のチャレンジでは、この問題を執筆した時点（※2022年7月）でかなり注目されている機能である　SnowflakeでのPython　を使用します。

最初に、数値型のカラムを一つ持つ非常にシンプルなテーブルを作ります。
レコード数や中の数値は自由に決めてください。

その後、数値を3倍にする　非常に基本的な関数から始めます。

この課題は、「難しいPython関数を構築する」ことではなく、「SnowflakeでのUDF（ユーザ定義関数）を構築して使用する」ことを目的とします。

単純なSELECT文でコードをテストできます。

SELECT timesthree(start_int) FROM FF_week_5;

**/

use role sysadmin;
use warehouse compute_wh;
use database frosty_friday;
use schema public;

create or replace table ff_week_5 (start_int number);
insert into ff_week_5 (start_int)
select UNIFORM(0,1000, random()) as start_int
from table(GENERATOR(ROWCOUNT => 100));

--
select * from ff_week_5 order by start_int;

-- Pythonで関数を作成
create or replace function timesthree(i int)
returns int
language python
runtime_version = '3.8'
handler = 'timesthree_py'
as
$$
def timesthree_py(i):
  return i*3
$$
;

SELECT start_int, timesthree(start_int) as start_int_x3 FROM FF_week_5 order by start_int;

-- SQLで関数を作成
create or replace function timesthree_by_sql(i int)
returns int
language sql
as
$$
i*3
$$
;

SELECT start_int, timesthree_by_sql(start_int) as start_int_x3 FROM FF_week_5 order by start_int;
