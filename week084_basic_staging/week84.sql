-- 環境設定
use role sysadmin;
use database gaku_frosty_friday_db;
create or replace schema week84;
use warehouse gaku_wh;

/**
https://frostyfriday.org/blog/2024/03/08/week-84-basic/

CREATE STAGE frosty_aws_stage
  URL = 's3://frostyfridaychallenges/';

LIST @FROSTY_AWS_STAGE/challenge_84/;
は、Access Deniedエラーになります。

そのため、AWS S3を外部ステージに接続するためのストレージインテグレーションを作成します。
**/

-- AWS S3を外部ステージに接続するためのストレージインテグレーションを作成
CREATE OR REPLACE STORAGE INTEGRATION gakufrostyfriday_storage_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::**************:role/gakufrostyfriday_snowflake_access_role'
  STORAGE_ALLOWED_LOCATIONS = ('*')
;

/**
s3 : 中国以外のパブリックAWSリージョンのS3ストレージ
s3china : 中国の
s3gov : 政府リージョン用
**/

-- Stageの作成
CREATE OR REPLACE STAGE gakufrostyfriday_stage
  STORAGE_INTEGRATION = gakufrostyfriday_storage_integration
  URL = 's3://gakufrostyfriday/'
;

list @gakufrostyfriday_stage/week84;

create or replace stage week84;
list @week84;

-- 解法 COPY FILESコマンドを使用してファイルをコピーする
COPY FILES
  INTO @week84
  FROM @gakufrostyfriday_stage;

list @week84;

create or replace stage week84_1;
-- 1. ファイル名を指定してコピーする

COPY FILES
  INTO @week84_1
  FROM @gakufrostyfriday_stage
  FILES = ('week84/_copy_these_very_specific.txt', 'week84/_files_of_ours.txt');

list @week84_1;

  -- 2. 特定のディレクトリをコピーする
  create or replace stage week84_1;

COPY FILES
  INTO @week84_1/weelk84_1_1/
  FROM @gakufrostyfriday_stage/weelk84_1/;

list @week84_1;

-- 3. パターンの一致を使用してファイルをコピーする
list @week84;

COPY FILES
  INTO @week84_1/weelk84_parquet/
  FROM @gakufrostyfriday_stage/
  PATTERN='.*[.]parquet'
;

list @week84_1/weelk84_parquet/;
