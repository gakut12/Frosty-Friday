-- Settings Environments
use role sysadmin;
use warehouse gaku_wh;
use database gaku_frosty_friday_db;
create or replace schema week44;

-- START SCRIPT
create or replace table MOCK_DATA (
id INT,
salary INT,
teamnumber INT
);
desc table mock_data;
insert into MOCK_DATA (id, salary, teamnumber) values (1, 781767, 2);

select * from mock_data;
insert into MOCK_DATA (id, salary, teamnumber) values (2, 701047, 5);
insert into MOCK_DATA (id, salary, teamnumber) values (3, 348497, 2);
insert into MOCK_DATA (id, salary, teamnumber) values (4, 555275, 2);
insert into MOCK_DATA (id, salary, teamnumber) values (5, 144962, 3);
insert into MOCK_DATA (id, salary, teamnumber) values (6, 832979, 4);
insert into MOCK_DATA (id, salary, teamnumber) values (7, 387404, 1);
insert into MOCK_DATA (id, salary, teamnumber) values (8, 427563, 3);
insert into MOCK_DATA (id, salary, teamnumber) values (9, 788928, 3);
insert into MOCK_DATA (id, salary, teamnumber) values (10, 257613, 1);
insert into MOCK_DATA (id, salary, teamnumber) values (11, 483792, 4);
insert into MOCK_DATA (id, salary, teamnumber) values (12, 720679, 3);
insert into MOCK_DATA (id, salary, teamnumber) values (13, 452976, 4);
insert into MOCK_DATA (id, salary, teamnumber) values (14, 541193, 2);
insert into MOCK_DATA (id, salary, teamnumber) values (15, 159377, 1);
insert into MOCK_DATA (id, salary, teamnumber) values (16, 825003, 4);
insert into MOCK_DATA (id, salary, teamnumber) values (17, 362209, 3);
insert into MOCK_DATA (id, salary, teamnumber) values (18, 291622, 5);
insert into MOCK_DATA (id, salary, teamnumber) values (19, 646774, 3);
insert into MOCK_DATA (id, salary, teamnumber) values (20, 971930, 1);

select * from mock_data;

-- 行アクセスポリシーを作成
CREATE OR REPLACE ROW ACCESS POLICY demo_policy
AS (teamnumber int) RETURNS BOOLEAN ->
CURRENT_ROLE() = 'HR'
OR LEFT(CURRENT_ROLE(),13) = 'MANAGER_TEAM_' AND RIGHT(CURRENT_ROLE(),1) = RIGHT(teamnumber, 1);

-- 行アクセスポリシーを適用
alter table MOCK_DATA add row access policy demo_policy on (teamnumber);


select * from MOCK_DATA;

-- Hack
CREATE OR REPLACE PROCEDURE totally_not_a_suspicious_procedure()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS
$$
var stmt = snowflake.createStatement({
sqlText: "alter table MOCK_DATA drop row access policy demo_policy;"
});
stmt.execute();
return "Row access policy dropped successfully.";
$$;

CALL totally_not_a_suspicious_procedure();
select * from MOCK_DATA;

CREATE OR REPLACE PROCEDURE totally_not_a_suspicious_procedure2()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS
$$
var stmt = snowflake.createStatement({
sqlText: "alter table MOCK_DATA add row access policy demo_policy on (teamnumber);;"
});
stmt.execute();
return "Row access policy dropped successfully.";
$$;

CALL totally_not_a_suspicious_procedure2();

drop procedure totally_not_a_suspicious_procedure();
drop procedure totally_not_a_suspicious_procedure2();

select * from snowflake.account_usage.query_history;
select * from information_schema.QUERY_HISTORY;

-- SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORYビュー
-- ビューの遅延は最大45分
-- データは一年間保持
select 
    query_text
    ,start_time
    ,user_name 
from 
    snowflake.account_usage.query_history 
where 
    query_text ilike '%drop row access policy%'
;

-- ****_DB,INFORMATION_SCHEMA.QUERY_HISTORY()  
-- INFORMATION_SCHEMAテーブル関数
-- リアルタイムに近い
-- データ保持は7日間
-- 結果は、ユーザーに現在割り当てられているロールの権限に応じて異なります。
-- RESULT_LIMIT : デフォルト: 100 （範囲：1〜10000）

select 
    query_text
    ,start_time
    ,user_name 
from
    table(gaku_frosty_friday_db.information_schema.query_history()) 
where 
    query_text ilike '%drop row access policy%';

select 
    query_text
    ,start_time
    ,user_name 
from
    table(gaku_frosty_friday_db.information_schema.query_history(result_limit => 5)) 
where 
    query_text ilike '%drop row access policy%';


select 
    query_text
    ,start_time
    ,user_name 
from
    table(gaku_frosty_friday_db.information_schema.query_history(result_limit => 10)) 
where 
   query_text ilike '%drop row access policy%'
order by 
    start_time desc
;


select 
    query_text
    ,start_time
    ,user_name 
from
    table(gaku_frosty_friday_db.information_schema.query_history(result_limit => 40)) 
where 
   query_text ilike 'call%'
order by 
    start_time desc
;

select 
    query_text
    ,start_time
    ,user_name 
from
    table(gaku_frosty_friday_db.information_schema.query_history(result_limit => 100)) 
where 
   query_text ilike 'call%'
order by 
    start_time desc
limit 40
;
