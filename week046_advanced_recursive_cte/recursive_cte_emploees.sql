use role sysadmin;
use warehouse gaku_wh;
use database gaku_frosty_friday_db;
use schema week46;
----- 
-- 階層データへのクエリ https://docs.snowflake.com/ja/user-guide/queries-hierarchical

CREATE OR REPLACE TABLE employees (title VARCHAR, employee_ID INTEGER, manager_ID INTEGER);
INSERT INTO employees (title, employee_ID, manager_ID) VALUES
    ('President', 1, NULL),  -- The President has no manager.
        ('Vice President Engineering', 10, 1),
            ('Programmer', 100, 10),
            ('QA Engineer', 101, 10),
        ('Vice President HR', 20, 1),
            ('Health Insurance Analyst', 200, 20);
select * from employees;

-- 自己結合
SELECT
     emps.title
     , emps.employee_ID
     , mgrs.employee_ID AS MANAGER_ID
     , mgrs.title AS "MANAGER TITLE"
FROM employees AS emps 
    LEFT OUTER JOIN employees AS mgrs
    ON emps.manager_ID = mgrs.employee_ID
ORDER BY 
    mgrs.employee_ID NULLS FIRST
    , emps.employee_ID
;

-- 再帰CTE
WITH RECURSIVE managers(indent, employee_ID, manager_ID, employee_title) AS (
    SELECT  --> 初期条件
        '' AS indent
        , employee_ID
        , manager_ID
        , title AS employee_title
    FROM employees
    WHERE title = 'President'
    UNION ALL
    SELECT --> 再帰
        indent || '--- '
        , employees.employee_ID
        , employees.manager_ID
        , employees.title
    FROM employees 
        INNER JOIN managers
        ON employees.manager_ID = managers.employee_ID
)
SELECT 
    indent || employee_title AS Title
    , employee_ID
    , manager_ID
FROM managers
;

---

CREATE OR REPLACE FUNCTION skey(ID VARCHAR)
  RETURNS VARCHAR
  AS
  $$
    SUBSTRING('0000' || ID::VARCHAR, -4) || ' '
  $$
  ;
SELECT skey(12);

WITH RECURSIVE managers (indent, employee_ID, manager_ID, employee_title, sort_key)  AS (
    -- Anchor Clause 初期
    SELECT 
        '' AS indent
        , employee_ID
        , manager_ID
        , title AS employee_title
        , skey(employee_ID)
    FROM employees
    WHERE title = 'President'

    UNION ALL
    -- Recursive Clause
    SELECT 
        indent || '--- '
        , employees.employee_ID
        , employees.manager_ID
        , employees.title
        , sort_key || skey(employees.employee_ID)
    FROM employees 
        JOIN managers 
            ON employees.manager_ID = managers.employee_ID
)
-- This is the "main select".
SELECT 
    indent || employee_title AS Title, employee_ID
    , manager_ID
    , sort_key
FROM managers
ORDER BY sort_key
;

-- connect by 
SELECT 
    employee_ID
    , manager_ID
    , title
FROM employees
START WITH title = 'President' --> 初期
CONNECT BY
    manager_ID = PRIOR employee_id
  ORDER BY employee_ID;

-- connect by ( with TREE)
SELECT 
    SYS_CONNECT_BY_PATH(title, ' -> ')
    , employee_ID
    , manager_ID
    , title
FROM employees
    START WITH title = 'President'
    CONNECT BY
        manager_ID = PRIOR employee_id
ORDER BY 
    employee_ID
;

-- connect by ( with ROOT)
SELECT 
    employee_ID
    , manager_ID
    , title
    , CONNECT_BY_ROOT title AS root_title
FROM employees
    START WITH title = 'President'
    CONNECT BY
        manager_ID = PRIOR employee_id
ORDER BY employee_ID
;


-- 循環データの場合
CREATE OR REPLACE TABLE employees2 (title VARCHAR, employee_ID INTEGER, manager_ID INTEGER);
INSERT INTO employees2 (title, employee_ID, manager_ID) VALUES
    ('President', 1, 101),  -- The President has no manager. -> has manager にしてみた（真のツリーではなく成ったので再帰はNGなはず）
        ('Vice President Engineering', 10, 1),
            ('Programmer', 100, 10),
            ('QA Engineer', 101, 10),
        ('Vice President HR', 20, 1),
            ('Health Insurance Analyst', 200, 20);
select * from employees2;


-- 自己結合-> 問題なく動いた・・・
SELECT
     emps.title
     , emps.employee_ID
     , mgrs.employee_ID AS MANAGER_ID
     , mgrs.title AS "MANAGER TITLE"
FROM employees2 AS emps 
    LEFT OUTER JOIN employees2 AS mgrs
    ON emps.manager_ID = mgrs.employee_ID
ORDER BY 
    mgrs.employee_ID NULLS FIRST
    , emps.employee_ID
;

-- 再帰CTE 問題なく動いた・・・・
WITH RECURSIVE managers(indent, employee_ID, manager_ID, employee_title) AS (
    SELECT  --> 初期条件
        '' AS indent
        , employee_ID
        , manager_ID
        , title AS employee_title
    FROM employees2
    WHERE title = 'President'
    UNION ALL
    SELECT --> 再帰
        indent || '--- '
        , employees.employee_ID
        , employees.manager_ID
        , employees.title
    FROM employees 
        INNER JOIN managers
        ON employees.manager_ID = managers.employee_ID
)
SELECT 
    indent || employee_title AS Title
    , employee_ID
    , manager_ID
FROM managers
;

-- タイムアウトするNGなSQL( connect by)
SELECT 
    employee_ID
    , manager_ID
    , title
FROM employees2
START WITH title = 'President' --> 初期
CONNECT BY
    manager_ID = PRIOR employee_id
  ORDER BY employee_ID
;
