/**
Week101_Easy_Insert_multi_table

やあ、仲間！Pirate SQL チャレンジへようこそ！

あなたの使命は、悪名高い海賊とその財宝のデータを管理することです。src海賊とその略奪品の詳細を含むソース テーブルとt1、t2特定の条件に基づいてデータを挿入する 2 つの宛先テーブルの 3 つのテーブルを操作します。

- 戦利品の量（BOOTY_AMOUNT)が 700 ユニット以上の海賊をt1のみを挿入する
- ランクが「First Mate (一等航海士)」の海賊をt2のみ挿入する
- 戦利品（BOOTY_AMMOUNT）が 100 未満の海賊は、両方のテーブルに挿入する
-- 他のすべての海賊はt2のみ に挿入する
以下の手順に従ってテーブルを作成し、条件に従ってデータを挿入します。
この課題を解決するには、Snowflake で使用できる INSERT (マルチテーブル) の種類を確認してください。

https://docs.snowflake.com/ja/sql-reference/sql/insert-multi-table

SQL の危険な海域を航行し、真の海賊船長としての勇気を証明する際に、
風が背中を押してくれますように! チャレンジのテーマを提案してくれた同志の Niccolò のように!

※回答例が画像がありますが、あくまでも回答「例」であって、回答ではなさそうです
**/

use role sysadmin;
use warehouse gaku_wh;
use database frosty_friday;
create or replace schema week101;

-- Creating the destination tables t1 and t2
CREATE OR REPLACE TABLE t1 (
    pirate_name STRING,
    booty_amount NUMBER,
    rank STRING,
    ship_name STRING
);

CREATE OR REPLACE TABLE t2 (
    pirate_name STRING,
    booty_amount NUMBER,
    rank STRING,
    ship_name STRING
);

-- Creating the source table src with pirate-themed data
CREATE OR REPLACE TABLE src (
    pirate_name STRING,
    booty_amount NUMBER,
    rank STRING,
    ship_name STRING
);

-- Inserting data into the src table
INSERT INTO src (pirate_name, booty_amount, rank, ship_name) VALUES
    ('Blackbeard', 500, 'Captain', 'Queen Anne\'s Revenge')
    ('Anne Bonny', 300, 'First Mate', 'Revenge'),
    ('Calico Jack', 200, 'Captain', 'Ranger'),
    ('Henry Morgan', 1000, 'Admiral', 'Oxford'),
    ('Bartholomew Roberts', 400, 'Captain', 'Royal Fortune'),
    ('Mary Read', 150, 'Quartermaster', 'Ranger'),
    ('Stede Bonnet', 50, 'Captain', 'Revenge'),
    ('Charles Vane', 250, 'Captain', 'Lark'),
    ('Jack Sparrow', 800, 'Captain', 'Black Pearl'),
    ('William Kidd', 600, 'Captain', 'Adventure Galley')
    ;

/**
'
- Pirates with booty amounts greater than 700 units should be inserted into t1 only.
- Pirates with the rank “First Mate” should be inserted into t2 only.
- Pirates with less than 100 units of booty should be inserted into both tables.
- All other pirates should be inserted into t2 only.
**/

-- https://docs.snowflake.com/en/sql-reference/sql/insert-multi-table

-- ここから実装
CREATE OR REPLACE TABLE t1 (
    pirate_name STRING,
    booty_amount NUMBER,
    rank STRING,
    ship_name STRING
);

CREATE OR REPLACE TABLE t2 (
    pirate_name STRING,
    booty_amount NUMBER,
    rank STRING,
    ship_name STRING
);

select * from src;
-- 条件1 booty_amount が 700以上
select * from src where booty_amount >= 700;

-- 条件2 RANKが、First Mate
select * from src where RANK = 'First Mate';
/**
PIRATE_NAME	BOOTY_AMOUNT	RANK	SHIP_NAME
Anne Bonny	300	First Mate	Revenge
**/
/**
PIRATE_NAME	BOOTY_AMOUNT	RANK	SHIP_NAME
Henry Morgan	1000	Admiral	Oxford
Jack Sparrow	800	Captain	Black Pearl
**/

-- 条件3 100ユニット以下は、t2
select * from src where booty_amount < 100;

-- INSERT（マルチテーブル）
insert first
    when booty_amount >= 700 then 
        into t1
    when RANK = 'First Mate' then
        into t2
    when booty_amount < 100 then
        into t1
        into t2
    else
        into t2
    select * from src;

-- 確認
    select * from t1;
    select * from t2;

/**
正直この機能は、使ったこともないですし、今後も使うことはないかなと思います
dbtなどでは使えないので。データパイプラインを構築するうえではなかなか使わないかなと思いました
**/
