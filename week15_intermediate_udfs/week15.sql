/**
今週は、特定のスライディング ビンに従って分類する必要がある住宅販売に関する小規模なデータセットを扱っています。ただし、ビンのサイズと数はすぐに変わる可能性があるという問題があります。

課題は、次のことを実行する単一の名前を持つ関数を作成することです。

不均一なビンサイズを処理できる
最初のパラメータは、ビンを通知する列である必要があります（この例では、[価格]に従って分類します）
2 番目のパラメータでは、ビンの範囲を指定する必要があります (これらは不均等なビンであることに注意してください。ビン 1 は 1 ～ 400、ビン 2 は 401 ～ 708、ビン 3 は 709 ～ 3000 になります)。指定方法は自由です。下限、上限、両方、各ビン内のカウントなどを指定できます。
SQLを使用する場合、最低でも2〜6個のビンを処理できる必要がありますが、他の言語を使用する場合は、任意の数のビンを処理できるほど柔軟であることがわかります。
クエリは次のようになります。

SELECT sale_date,
       price,
       your_function(price,<bin_ranges>) AS BUCKET_SET1,
       your_function(price,<bin_ranges>) AS BUCKET_SET2,
       your_function(price,<bin_ranges>) AS BUCKET_SET3,
FROM home_sales
次に、テスト目的で次のビン/バケット範囲を渡す必要があります。

BUCKET_SET_1 :
1: 0 – 1
2: 2 – 310,000
3: 310001 – 400000
4: 400001 – 500000

BUCKET_SET_2 :
1: 0 – 210000
2: 210001 – 350000

BUCKET_SET_3 :
1: 0 – 250000
2: 250001 – 290001
3: 290002 – 320000
4: 320001 – 360000
5: 360001 – 410000
6: 410001 – 470001

**/
use role sysadmin;
use warehouse gaku_wh;
create or replace schema week15;

create table home_sales (
sale_date date,
price number(11, 2)
);

insert into home_sales (sale_date, price) values
('2013-08-01'::date, 290000.00),
('2014-02-01'::date, 320000.00),
('2015-04-01'::date, 399999.99),
('2016-04-01'::date, 400000.00),
('2017-04-01'::date, 470000.00),
('2018-04-01'::date, 510000.00);

-- テーブルの確認
select * from home_sales;

select
    index + 1 as bin_no
    , value
from 
    table(flatten([1, 310000, 400000, 500000]))
where
    1 = 1
    and 310000 <= value
;

select
    index+1
    , value
from 
    table(flatten([1, 310000, 400000, 500000]))
where 320000.00 > value
;

create or replace function udf_bin (price number(11, 2), buckets array)
returns number as 
$$
    select 
        min(f.index) + 1
    from 
        table(flatten(buckets)) f
    where 
        price <= f.value
$$;
select 
    sale_date
    , price
    , udf_bin(price, [1, 310000, 400000, 500000]) as bucket_set_1
    , udf_bin(price, [210000, 350000]) as bucket_set_2
    , udf_bin(price, [250000, 290001, 320000, 360000, 410000, 410001]) as bucket_set_3
from home_sales
order by sale_date
;
-- binの範囲が、こえちゃうとnullになってしまっている

-- binの最大範囲より大きいときは、最後にする　→ nullの場合、array(buckets)のサイズを代入する
create or replace function udf_bin (price number(11, 2), buckets array)
returns number as 
$$
    select 
        coalesce(min(f.index) + 1, array_size(buckets))
    from 
        table(flatten(buckets)) f
    where 
        price <= f.value
$$;

select 
    sale_date
    , price
    , udf_bin(price, [1, 310000, 400000, 500000]) as bucket_set_1
    , udf_bin(price, [210000, 350000]) as bucket_set_2
    , udf_bin(price, [250000, 290001, 320000, 360000, 410000, 410001]) as bucket_set_3
from home_sales
order by sale_date
;

-- bucket_set_1 : 1, 310000, 400000, 500000
-- bucket_set_2 : 210000, 350000
-- bucket_set_3 : 250000, 290001, 320000, 360000, 410000, 410001
