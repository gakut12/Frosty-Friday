-- 環境設定
use role sysadmin;
use warehouse gaku_wh;
use database gaku_frosty_friday_db;
create or replace schema week76;


-- スタートアップスクリプト
CREATE OR REPLACE TABLE task_table (stamp time, message varchar);


use role sysadmin;
CREATE OR REPLACE TASK main_task 
  SCHEDULE = '1 minute'
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
AS
SELECT CASE
    WHEN RANDOM() <0 THEN 1/0
    ELSE 1
END;
-- 動かしたらエラーに
-- WAREHOUSE not specified and missing serverless task privilege to create task MAIN_TASK. To create it as a user-managed task, specify a WAREHOUSE. To create it as a serverless task, execute the CREATE TASK command with a role that has been granted the EXECUTE MANAGED TASK account-level privilege.
use role accountadmin;
GRANT EXECUTE MANAGED TASK ON ACCOUNT TO ROLE SYSADMIN;
-- REVOKE EXECUTE MANAGED TASK ON ACCOUNT FROM ROLE SYSADMIN;


CREATE OR REPLACE TASK main_task 
  SCHEDULE = '1 minute'
  warehouse = 'gaku_wh'
AS
SELECT CASE
    WHEN RANDOM() <0 THEN 1/0
    ELSE 1
END;


CREATE OR REPLACE TASK child_task
warehouse = 'gaku_wh'
AFTER main_task
AS
INSERT INTO task_table (stamp,message) VALUES(CURRENT_TIMESTAMP,'child_task succes!');


--- Challange
/**
エンジニアとして私たちが目指すものの一つは、障害が発生しても動作し続ける堅牢なシステムです。
今週は、タスクにおけるこの機能を拡張していきます。タスクが失敗しても、連鎖タスクは継続しなければなりません。

→ Finalyzer Task を使う必要あり
https://docs.snowflake.com/ja/user-guide/tasks-graphs
**/

-- Create the task
create or replace task child_finalizer_task
  warehouse = 'gaku_wh' -- Modified to a user managed task to match privileges I have on the account
  finalize = main_task
as
  insert into task_table (stamp, message) values (current_timestamp, 'MAIN_TASK ran!')
;

---　タスクの起動
-- Activate the tasks
alter task child_finalizer_task resume;
alter task child_task resume;
alter task main_task resume;

-- Query the table
select * from task_table;

-- Deactive the tasks to clean up
alter task main_task suspend;
alter task child_task suspend;
alter task child_finalizer_task suspend;