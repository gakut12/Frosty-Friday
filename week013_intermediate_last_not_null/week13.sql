/**
Week13 - Basic Snowflake / Intermediate Non-Snowflake : Last not null

今週は、理解するのは非常に簡単ですが、SQL で実行するのは難しい、少し紛らわしい問題を取り上げます。

**/

use role sysadmin;
use warehouse gaku_wh;
create or replace database frosty_friday;
create or replace schema week13;

create or replace table testing_data(id int autoincrement start 1 increment 1, product string, stock_amount int,date_of_check date);
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero capes',1,'2022-01-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero capes',2,'2022-01-02');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero capes',NULL,'2022-02-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero capes',NULL,'2022-03-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',5,'2022-01-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',NULL,'2022-02-13');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',6,'2022-01-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',NULL,'2022-01-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',3,'2022-04-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',2,'2022-07-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',NULL,'2022-01-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',3,'2022-05-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',NULL,'2022-10-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',10,'2022-11-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',NULL,'2022-02-14');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',NULL,'2022-02-15');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',NULL,'2022-02-13');

-- データの確認
select * from testing_data order by product, date_of_check
-------------------------------------------------------------------------------
-- for Snowflake の解法その1（Window関数 last_value利用）
-------------------------------------------------------------------------------
-- まずは、last_valueのみ
select
    id
    , product
    , stock_amount
    , date_of_check
    , last_value(stock_amount) over (partition by product order by date_of_check)
from 
    testing_data
order by product, date_of_check
;
-- null を無視しよう
select
    id
    , product
    , stock_amount
    , date_of_check
    , last_value(stock_amount ignore nulls) over (partition by product order by date_of_check)
from 
    testing_data
order by product, date_of_check
;

-- 自分より前のデータで・・・・を追加 rows between unbounded proceding and current row
-- 前：proceding
select
    product
    , stock_amount
    , last_value(stock_amount ignore nulls) over (partition by product order by date_of_check rows between unbounded preceding and current row) as stock_amount_filled_out
    , date_of_check
from 
    testing_data
order by product, date_of_check
;

-------------------------------------------------------------------------------
-- for Snowflake の解法その2（ASOF JOIN使用）
-------------------------------------------------------------------------------

with asofjoin as( 
select 
    t1.id as t1_id
    , t1.product as t1_product
    , t1.stock_amount as t1_stock_amount
    , t1.date_of_check as t1_date_of_check
    , t2.id as t2_id
    , t2.product as t2_product
    , t2.stock_amount as t2_stock_amount
    , t2.date_of_check as t2_date_of_check
from testing_data t1
asof join (select * from testing_data where stock_amount is not null) t2
match_condition (t1.date_of_check >= t2.date_of_check)
on t1.product = t2.product
) 
select 
    t1_product
    , t1_stock_amount
    , t2_stock_amount
    , t1_date_of_check
from 
    asofjoin
order by t1_product, t1_date_of_check
;

-------------------------------------------------------------------------------
-- 解法3 for not snowflake , 自己結合を利用
-------------------------------------------------------------------------------
with testing_data_1 as (
    select 
        id
        , product
        , stock_amount
        , date_of_check 
    from 
        testing_data
)
, testing_data_2 as (
    select 
        id
        , product
        , stock_amount
        , date_of_check 
    from 
        testing_data
    where
        stock_amount is not null
)
, joined as (
    select 
        testing_data_1.id as id
        , testing_data_1.product as product
        , testing_data_1.stock_amount as stock_amount
        , testing_data_1.date_of_check as date_of_check
        , testing_data_2.stock_amount as stock_amount_2
    from 
        testing_data_1 
        left outer join testing_data_2 
        on testing_data_1.product = testing_data_2.product
           and testing_data_1.date_of_check > testing_data_2.date_of_check
)
, grouped as (
select 
    id
    , product
    , stock_amount
    , date_of_check
    , max(stock_amount_2) as stock_amount_2_max
from
    joined
group by all
) 

select 
    product
    , stock_amount
    , coalesce(stock_amount, stock_amount_2_max) as stock_amount_field_out
    , date_of_check
from
    grouped
order by
    product, date_of_check
;
