use role sysadmin;
use warehouse gaku_wh;
use database gaku_frosty_friday_db;

create or replace schema week52;

create or replace procedure CHECK_AND_GENERATE_DATA(tableName STRING)
returns string
language javascript
execute as caller
as
$$
  try {
    var tableName = TABLENAME;
    
    var command1 = `SELECT count(*) as count FROM information_schema.tables WHERE table_schema = CURRENT_SCHEMA() AND table_name = '${tableName.toUpperCase()}'`;
    var statement1 = snowflake.createStatement({sqlText: command1});
    var result_set1 = statement1.execute();
    
    result_set1.next();
    var count = result_set1.getColumnValue('COUNT');
    
    if (count == 0) {
      var command2 = `CREATE TABLE ${tableName} (payload VARIANT, ingested_at TIMESTAMP_NTZ default CURRENT_TIMESTAMP())`;
      var statement2 = snowflake.createStatement({sqlText: command2});
      statement2.execute();
    
      return `Table ${tableName} has been created.`;
    } else {
      for(var i=0; i<40; i++) {
        var jsonObject = {
          "id": i,
          "name": "Name_" + i,
          "address": "Address_" + i,
          "email": "email_" + i + "@example.com",
          "transactionValue": Math.floor(Math.random() * 10000) + 1
        };
        var jsonString = JSON.stringify(jsonObject);

        var command3 = `INSERT INTO ${tableName} (payload) SELECT PARSE_JSON(column1) FROM VALUES ('${jsonString}')`;
        var statement3 = snowflake.createStatement({sqlText: command3});
        statement3.execute();
      }
  
      return `40 records have been inserted into the ${tableName} table.`;
  }
  
  } catch (err) {
    return "Failed: " + err;
  }
$$;

-- Execute startup function
-- Run this twice to generate data

-- create table
call CHECK_AND_GENERATE_DATA('RAW_DATA');

select count(*) from RAW_DATA; -- 0

-- generate data on table
call CHECK_AND_GENERATE_DATA('RAW_DATA');

-- Sample initial data
select * from RAW_DATA;
select count(*) from RAW_DATA; -- 40

call CHECK_AND_GENERATE_DATA('RAW_DATA');
select count(*) from RAW_DATA; -- 80

select * from RAW_DATA;

select 
    PAYLOAD:"address"::string as ADDRESS
    , PAYLOAD:"email"::string as EMAIL
    , PAYLOAD:"id"::string as ID
    , PAYLOAD:"name"::string as TRANSACTION_VALUE
    , PAYLOAD:"transactionValue"::string as NAME
    , INGESTED_AT
from RAW_DATA
;

CREATE OR REPLACE DYNAMIC TABLE DYNAMIC_TBL
LAG = '1 minute'
WAREHOUSE = gaku_wh
AS
select 
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS index
    , PAYLOAD:"address"::string as ADDRESS
    , PAYLOAD:"email"::string as EMAIL
    , PAYLOAD:"id"::string as ID
    , PAYLOAD:"name"::string as TRANSACTION_VALUE
    , PAYLOAD:"transactionValue"::string as NAME
    , INGESTED_AT
from RAW_DATA
;


select * from DYNAMIC_TBL;
select count(*) from DYNAMIC_TBL;

call CHECK_AND_GENERATE_DATA('RAW_DATA');

select count(*) from DYNAMIC_TBL;
select count(*) from RAW_DATA; 


-- LAGを5分へ変更
ALTER DYNAMIC TABLE DYNAMIC_TBL SET TARGET_LAG = '5minutes';

select count(*) from RAW_DATA;

call CHECK_AND_GENERATE_DATA('RAW_DATA');

select count(*) from RAW_DATA; 
select count(*) from DYNAMIC_TBL; 

ALTER DYNAMIC TABLE DYNAMIC_TBL REFRESH;
select count(*) from DYNAMIC_TBL; 

ALTER DYNAMIC TABLE DYNAMIC_TBL SUSPEND;

call CHECK_AND_GENERATE_DATA('RAW_DATA');
select count(*) from DYNAMIC_TBL; 
select count(*) from RAW_DATA;

select * from DYNAMIC_TBL limit 10;
