use role sysadmin;
use warehouse gaku_wh;
use database GAKU_FROSTY_FRIDAY_DB;
create or replace schema week108;


CREATE TABLE week_108 AS
SELECT * FROM VALUES
    (1, 'Alice', 'Laptop', 1, 1200.50),
    (2, 'Bob', 'Smartphone', 2, 800.00),
    (3, 'Charlie', 'Tablet', 1, 300.00),
    (4, 'David', 'Smartwatch', 3, 150.00),
    (5, 'Eva', 'Headphones', 2, 100.00),
    (6, 'Frank', 'Laptop', 1, 1300.00),
    (7, 'Grace', 'Smartphone', 1, 900.00),
    (8, 'Hank', 'Tablet', 4, 320.00),
    (9, 'Ivy', 'Smartwatch', 2, 180.00),
    (10, 'Jack', 'Headphones', 3, 110.00),
    (11, 'Karen', 'Laptop', 1, 1250.75),
    (12, 'Leo', 'Smartphone', 2, 850.00),
    (13, 'Mona', 'Tablet', 1, 350.00),
    (14, 'Nina', 'Smartwatch', 3, 160.00),
    (15, 'Oscar', 'Headphones', 2, 105.00),
    (16, 'Paul', 'Laptop', 1, 1350.00),
    (17, 'Quincy', 'Smartphone', 1, 950.00),
    (18, 'Rita', 'Tablet', 4, 330.00),
    (19, 'Sam', 'Smartwatch', 2, 200.00),
    (20, 'Tina', 'Headphones', 3, 115.00)
AS sales(sale_id, customer_name, product_name, quantity, sale_amount);

select * from week_108;

SET table_name = 'week_108';

SELECT * FROM TABLE(TO_QUERY('SELECT * FROM IDENTIFIER($table_name)'));

unset table_name;
SELECT * FROM TABLE(TO_QUERY('SELECT * FROM IDENTIFIER($table_name)'));

SET table_name = 'week_108';

SELECT * FROM TABLE(
  TO_QUERY(
    'SELECT * FROM IDENTIFIER($table_name)
    WHERE customer_name = :arg1', arg1 => 'Alice'
    )
  );


set table_name2 = 'week_108';
 SELECT * FROM TABLE(
  TO_QUERY(
    'SELECT * FROM IDENTIFIER(:arg1)'
    , arg1 => $table_name2
    )
  );


  -------------------- TO_QUERY ------------------
  CREATE OR REPLACE PROCEDURE get_num_results_tq(query VARCHAR)
RETURNS TABLE ()
LANGUAGE SQL
AS
$$
DECLARE
  res RESULTSET DEFAULT (SELECT COUNT(*) FROM TABLE(TO_QUERY(:query)));
BEGIN
  RETURN TABLE(res);
END;
$$
;

call get_num_results_tq('select 2');


call get_num_results_tq('select 2; CREATE TABLE hoge (id    STRING, value STRING); ');
--> エラー
/**
Uncaught exception of type 'STATEMENT_ERROR' on line 3 at position 25 : SQL compilation error: syntax error line 1 at position 10 unexpected 'CREATE'.
**/

---- Dynamic SQL : SQLの文字列を組み立てて実行する方式 --------------


CREATE OR REPLACE PROCEDURE get_num_results(query VARCHAR)
RETURNS INTEGER
LANGUAGE SQL
AS
$$
DECLARE
  row_count INTEGER DEFAULT 0;
  stmt VARCHAR DEFAULT 'SELECT COUNT(*) FROM (' || query || ')';
  res RESULTSET DEFAULT (EXECUTE IMMEDIATE :stmt);
  cur CURSOR FOR res;
BEGIN
  OPEN cur;
  FETCH cur INTO row_count;
  RETURN row_count;
END;
$$
;

call get_num_results('select 1');
call get_num_results('select 2; CREATE TABLE hoge (id    STRING, value STRING); ');

/**
Uncaught exception of type 'STATEMENT_ERROR' on line 5 at position 25 : SQL compilation error: syntax error line 1 at position 30 unexpected ';'. syntax error line 1 at position 80 unexpected ')'.

若干、エラーが違う

内部実装が違うが、SQLインジェクションは起きてしまう
**/