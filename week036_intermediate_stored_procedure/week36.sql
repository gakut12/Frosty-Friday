use role sysadmin;
use warehouse gaku_wh;

use database frosty_friday;
create or replace schema week36;

CREATE OR REPLACE TABLE table_1 (id INT);
CREATE OR REPLACE VIEW view_1 AS (SELECT * FROM table_1);
CREATE OR REPLACE TABLE table_2 (id INT);
CREATE OR REPLACE VIEW view_2 AS (SELECT * FROM table_2);
CREATE OR REPLACE TABLE table_6 (id INT);
CREATE OR REPLACE VIEW view_6 AS (SELECT * FROM table_6);
CREATE OR REPLACE TABLE table_5 (id INT);
CREATE OR REPLACE VIEW view_5 AS (SELECT * FROM table_5);
CREATE OR REPLACE TABLE table_4 (id INT);
CREATE OR REPLACE VIEW view_4 AS (SELECT * FROM table_4);
CREATE OR REPLACE TABLE table_3 (id INT);
CREATE OR REPLACE VIEW view_3 AS (SELECT * FROM table_3);
CREATE OR REPLACE VIEW my_union_view AS
SELECT * FROM table_1
UNION ALL
SELECT * FROM table_2
UNION ALL
SELECT * FROM table_3
UNION ALL
SELECT * FROM table_4
UNION ALL
SELECT * FROM table_5
UNION ALL
SELECT * FROM table_6;

CREATE OR REPLACE TABLE table_10 (id INT);

-- 
select * from my_union_view;

select 
    *
from table(GET_OBJECT_REFERENCES(
      database_name => 'FROSTY_FRIDAY'
    , schema_name => 'WEEK36'
    , object_name => 'MY_UNION_VIEW' 
  ))
where 
    REFERENCED_OBJECT_TYPE = 'TABLE'
    and REFERENCED_DATABASE_NAME = 'FROSTY_FRIDAY'
    and REFERENCED_SCHEMA_NAME = 'WEEK36'
;

select 
    *
from 
    SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
where 
    REFERENCED_OBJECT_DOMAIN = 'TABLE'
    and REFERENCED_DATABASE = 'FROSTY_FRIDAY'
    and REFERENCED_SCHEMA = 'WEEK36'
;

-- このビューの待機時間は最大3時間です。
-- 見れるようになるまで、最大3時間かかるかも


select distinct concat(
    '"'
  , REFERENCING_DATABASE
  , '"."'
  , REFERENCING_SCHEMA
  , '"."'
  , REFERENCING_OBJECT_NAME
  , '"'
) as OBJECT_FQN
from SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
where REFERENCED_OBJECT_DOMAIN = 'TABLE'
  and REFERENCED_DATABASE = 'FROSTY_FRIDAY'
  and REFERENCED_SCHEMA = 'WEEK36'
  and REFERENCED_OBJECT_NAME = 'TABLE_1'
;

    select 
        listagg(
            concat_ws(
                '.'
                , referencing_database
                , referencing_schema
                , referencing_object_name)
                , ', '
            ) 
    from 
        SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
    where 
        REFERENCED_DATABASE = upper('FROSTY_FRIDAY')
        and REFERENCED_SCHEMA = upper('WEEK36')
        and REFERENCED_OBJECT_NAME = upper('TABLE_1')
    ;

create or replace procedure check_dependency(
	database_name string, 
    schema_name string, 
    object_name string
)
returns string
language sql
execute as owner
as
$$
DECLARE
    dependencies string;
BEGIN
    select 
        listagg(
            concat_ws(
                '.'
                , referencing_database
                , referencing_schema
                , referencing_object_name)
                , ', '
            ) into :dependencies
    from 
        SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES
    where 
        REFERENCED_DATABASE = upper(:database_name)
        and REFERENCED_SCHEMA = upper(:schema_name)
        and REFERENCED_OBJECT_NAME = upper(:object_name)
    ;
    
    if (nullif(:dependencies,'') is not null) then
    	return 'Object cannot be dropped because it is referenced by: ' || :dependencies ;
    else
    	return 'Object can be dropped';
    end if;
END;
$$;

call check_dependency('FROSTY_FRIDAY','WEEK36','TABLE_1');
call check_dependency('FROSTY_FRIDAY','WEEK36','TABLE_10');
