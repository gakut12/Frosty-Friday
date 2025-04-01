use role sysadmin;
use warehouse gaku_wh;

use database gaku_frosty_friday_db;
create or replace schema week46;


-- create part 1 table 
create or replace table original_shopping_cart (
    cart_number number
    , contents array
);

insert into original_shopping_cart ( cart_number, contents)
    select
        1 as cart_number
        , array_construct(5,10,15,20) as contentes
    union all
    select
        2 as cart_number
        , array_construct(8, 9, 10, 11, 12, 13, 14) as contente
;

select * from original_shopping_cart;


-- create part2 table removed
create or replace table order_to_unpack (
    cart_number number
    , remove_contents number
    , remove_order number
);

insert into order_to_unpack (cart_number, remove_contents, remove_order) 
values
    (1, 10, 1),
    (1, 15, 2),
    (1, 5, 3),
    (1, 20, 4),
    (2, 8, 1),
    (2, 14, 2),
    (2, 11, 3),
    (2, 12, 4),
    (2, 9, 5),
    (2, 10, 6),
    (2, 13, 7)
;

select * from order_to_unpack;

-- 解法① 再帰CTEを使った解法

-- とりあえず、2つのテーブルをJOINしてみる
-- その前に、joinが1:nかどうかを確認

select
    cart_number
    , count(*) as count
from 
    order_to_unpack
group by 1 order by 2;

-- JOINしてみる
select 
    *
from
    original_shopping_cart
    left outer join order_to_unpack
    on original_shopping_cart.cart_number = order_to_unpack.cart_number    
;

-- カートの中身を突合するものを消してみる
select 
    *
    , array_remove(original_shopping_cart.contents,order_to_unpack.remove_contents) as current_contents_of_cart
from
    original_shopping_cart
    left outer join order_to_unpack
    on original_shopping_cart.cart_number = order_to_unpack.cart_number
;

-- カート[1,2]から最初に消す中身を消してみる
select 
    order_to_unpack.remove_order as removal_iteration
    , original_shopping_cart.cart_number as cart_number
    , array_remove(original_shopping_cart.contents,order_to_unpack.remove_contents) as current_contents_of_cart
    , order_to_unpack.remove_contents as content_last_removed
    , original_shopping_cart.contents as contents_before_removed
from
    original_shopping_cart
    left outer join order_to_unpack
    on original_shopping_cart.cart_number = order_to_unpack.cart_number
where
    order_to_unpack.remove_order = 1
;

-- ↑これが初期条件となる


with recursive recurtive_cte_shopping_cart_unpacking as (
    select 
        order_to_unpack.remove_order as removal_iteration
        , original_shopping_cart.cart_number as cart_number
        , array_remove(original_shopping_cart.contents,order_to_unpack.remove_contents) as current_contents_of_cart
        , order_to_unpack.remove_contents as content_last_removed
        , original_shopping_cart.contents as contents_before_removed
    from
        original_shopping_cart
        left outer join order_to_unpack
        on original_shopping_cart.cart_number = order_to_unpack.cart_number
    where
        order_to_unpack.remove_order = 1
    union all
    select 
        order_to_unpack.remove_order as removal_iteration
        , recurtive_cte_shopping_cart_unpacking.cart_number as cart_number
        , array_remove(recurtive_cte_shopping_cart_unpacking.current_contents_of_cart,order_to_unpack.remove_contents) as current_contents_of_cart
        , order_to_unpack.remove_contents as content_last_removed
        , recurtive_cte_shopping_cart_unpacking.current_contents_of_cart as contents_before_removed
    from
        recurtive_cte_shopping_cart_unpacking
        left outer join order_to_unpack
        on recurtive_cte_shopping_cart_unpacking.cart_number = order_to_unpack.cart_number
            and recurtive_cte_shopping_cart_unpacking.removal_iteration + 1 = order_to_unpack.remove_order
    where
        array_size ( recurtive_cte_shopping_cart_unpacking.current_contents_of_cart ) > 0 -- > 終了条件
)
-- select * from recurtive_cte_shopping_cart_unpacking;

select
    cart_number
    , current_contents_of_cart
    , content_last_removed
    , removal_iteration
from 
    recurtive_cte_shopping_cart_unpacking
order by cart_number, removal_iteration
;


-- 解法② ウィンドウ関数を使った解法

select 
    order_to_unpack.remove_order as removal_iteration
    , original_shopping_cart.cart_number as cart_number
    , order_to_unpack.remove_contents as content_last_removed
    , original_shopping_cart.contents as contents_before_removed
    , array_agg(order_to_unpack.remove_contents) over (partition by original_shopping_cart.cart_number order by order_to_unpack.remove_order)  as removed_contents_array
from
    original_shopping_cart
    left outer join order_to_unpack
    on original_shopping_cart.cart_number = order_to_unpack.cart_number
;

select 
    order_to_unpack.remove_order as removal_iteration
    , original_shopping_cart.cart_number as cart_number
    , order_to_unpack.remove_contents as content_last_removed
    , original_shopping_cart.contents as contents_before_removed
    , array_agg(order_to_unpack.remove_contents) over (partition by original_shopping_cart.cart_number order by order_to_unpack.remove_order)  as removed_contents_array
    , array_except(contents_before_removed, removed_contents_array) as current_contents_of_cart
from
    original_shopping_cart
    left outer join order_to_unpack
    on original_shopping_cart.cart_number = order_to_unpack.cart_number
;

with with_removed_contents as (
    select 
        order_to_unpack.remove_order as removal_iteration
        , original_shopping_cart.cart_number as cart_number
        , order_to_unpack.remove_contents as content_last_removed
        , original_shopping_cart.contents as contents_before_removed
        , array_agg(order_to_unpack.remove_contents) over (partition by original_shopping_cart.cart_number order by order_to_unpack.remove_order) as removed_contents_array
        , array_except(contents_before_removed, removed_contents_array) as current_contents_of_cart
    from
        original_shopping_cart
        left outer join order_to_unpack
        on original_shopping_cart.cart_number = order_to_unpack.cart_number
)
select 
    cart_number
    , current_contents_of_cart
    , content_last_removed
    , removal_iteration
from with_removed_contents
;
