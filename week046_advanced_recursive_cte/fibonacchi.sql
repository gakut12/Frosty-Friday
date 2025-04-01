use role sysadmin;
use warehouse gaku_wh;
use database gaku_frosty_friday_db;
use schema week46;

WITH RECURSIVE fibonacci(n, a, b) AS (
  SELECT 1, 0, 1  -- (項数, 前の値, 現在の値)
  UNION ALL
  SELECT n + 1, b, a + b
  FROM fibonacci
  WHERE n < 20
)
SELECT n, a AS fibonacci_number
FROM fibonacci;

--> 502ms
show parameters like 'STATEMENT_TIMEOUT_IN_SECONDS';
-- 172800s 
alter session set STATEMENT_TIMEOUT_IN_SECONDS = 30;

show parameters like 'STATEMENT_TIMEOUT_IN_SECONDS';
-- 30s

WITH RECURSIVE fibonacci(n, a, b) AS (
  SELECT 1, 0, 1  -- (項数, 前の値, 現在の値)
  UNION ALL
  SELECT n + 1, b, a + b
  FROM fibonacci
--   WHERE n < 20 <-- 無限ループ
)
SELECT n, a AS fibonacci_number
FROM fibonacci;

--> 表現可能な範囲外の数値：型 FIXED[SB16](38,0){not null}、値 127127879743834334146972278486287885163

with recursive tow_plus(n, a) AS (
    select 1, 0  -- (項数, 現在の値)
    union all
    select 
        n + 1
        , a + 2 
      from 
        tow_plus
    where n < 20
)
select n, a AS tow_plus from tow_plus;

-- 無限ループさせちゃいます
alter session set STATEMENT_TIMEOUT_IN_SECONDS = 30;
with recursive tow_plus(n, a) AS (
    select 1, 0  -- (項数, 現在の値)
    union all
    select 
        n + 1
        , a + 2 
      from 
        tow_plus
--    where n < 20
)
select n, a AS tow_plus from tow_plus;
