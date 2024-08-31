use role sysadmin;
use warehouse gaku_wh;
use database frosty_friday;
create or replace schema week108;

-- start up sql
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

-- https://docs.snowflake.com/en/sql-reference/functions/to_query
set table_name = 'week_108';

-- pattern1 most simple to_query() 
select 
    * 
from 
    table(
        to_query('select * from identifier($table_name)')
    )
;

-- pattern2 using an argument to a SQL statement
select 
    * 
from table(
    to_query(
        sql => 'select * from identifier(:table_name)',
        table_name => 'week_108'
        )
);

-- pattern3 using an argument to a SQL statement & using session variables
select 
    * 
from table(
    to_query(
        sql => 'select * from identifier(:table_name)', -- an argument to a SQL statement
        table_name => $table_name -- session variables
        )
);
