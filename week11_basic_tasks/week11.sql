/**
今週、FrostyFarms は一連の連鎖タスク (正確には2つ) を作成しようとしています。農場には牛乳を生産する牛がたくさんいて、そこから牛乳の一部が脱脂乳に加工されます。
牛乳の脂肪分率によってデータの表示方法を変えてデータを編集したいと考えています。

脱脂乳は遠心分離機で脂肪を減らすプロセスを経るため、全乳の列にはそのプロセスに関連する列は必要ありませんが、脱脂乳の列には必要です。

牛乳の脂肪率に応じて、データの異なる行に対して異なるアクションを実行する親タスクと子タスクを作成します。

最初のクエリを実行すると、3%のデータは次のようになります。

3%以外の行は次のようになります

2番目のクエリでは次のような結果が返されるはずです。
**/

-- Set the database and schema
use database frosty_friday_week11;
use schema week11;

-- Create the stage that points at the data.
create stage week_11_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_11/'
    file_format = <insert_csv_file_format;

-- Create the table as a CTAS statement.
create or replace table frosty_friday.challenges.week11 as
select m.$1 as milking_datetime,
        m.$2 as cow_number,
        m.$3 as fat_percentage,
        m.$4 as farm_code,
        m.$5 as centrifuge_start_time,
        m.$6 as centrifuge_end_time,
        m.$7 as centrifuge_kwph,
        m.$8 as centrifuge_electricity_used,
        m.$9 as centrifuge_processing_time,
        m.$10 as task_used
from @week_11_frosty_stage (file_format => '<insert_csv_file_format>', pattern => '.*milk_data.*[.]csv') m;


-- TASK 1: Remove all the centrifuge dates and centrifuge kwph and replace them with NULLs WHERE fat = 3. 
-- Add note to task_used.
create or replace task whole_milk_updates
    schedule = '1400 minutes'
as
    <insert_sql_here>


-- TASK 2: Calculate centrifuge processing time (difference between start and end time) WHERE fat != 3. 
-- Add note to task_used.
create or replace task skim_milk_updates
    after frosty_friday.challenges.whole_milk_updates
as
    <insert_sql_here>


-- Manually execute the task.
execute task whole_milk_updates;

-- Check that the data looks as it should.
select * from week11;

-- Check that the numbers are correct.
select task_used, count(*) as row_count from week11 group by task_used;
