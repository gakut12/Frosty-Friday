/**
Week9 Intermediate : Tags, Masking Policies

■ストーリー
秘密を守る必要があるのは悪者だけではありません。
スーパーヒーローは悪者に対する防衛線なので、スーパーヒーローの情報は保護する必要があります。
しかし、スーパーヒーロー組織の運営は規模が大きく、システムにアクセスできる人が大勢います。

ヒーローの正体が決して明かされないようにしなくてはいけません。

より基本的なレベルでつながるために、一部のスタッフがスーパーヒーローのファーストネームを見れるようにしたいという要望が出ています。
上層部は、すべての情報を見ることができる必要があります。
組織内の役割は常に変化するため、まだ作成されていない役職に対しても、フレキシブルに対応、情報保護処理ができるようにしなくてはいけません。

■課題
タグとマスキングを使用して、data_to_be_masked テーブルから first_name 列と last_name 列をマスクします。
マスキングの挙動としては、次のようになります。

- アクセス権を持つデフォルトのユーザーは、マスクされていないhero_nameデータのみを見ることができます。
- ロールfoo1はhero_nameとfirst_nameのみを見ることができます
- ロールfoo2はテーブル全体の内容を見ることができる
- 使用されるマスキング ポリシーでは、ロール チェック機能を使用しないでください。(current_role = … など)

**/

use role sysadmin;
use warehouse compute_wh;
create database ff_week_9;

--CREATE DATA
CREATE OR REPLACE TABLE data_to_be_masked(first_name varchar, last_name varchar,hero_name varchar);
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Eveleen', 'Danzelman','The Quiet Antman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Harlie', 'Filipowicz','The Yellow Vulture');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Mozes', 'McWhin','The Broken Shaman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Horatio', 'Hamshere','The Quiet Charmer');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Julianna', 'Pellington','Professor Ancient Spectacle');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Grenville', 'Southouse','Fire Wonder');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Analise', 'Beards','Purple Fighter');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Darnell', 'Bims','Mister Majestic Mothman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Micky', 'Shillan','Switcher');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Ware', 'Ledstone','Optimo');

select * from data_to_be_masked;
--CREATE ROLE
use role securityadmin;
create role foo1;
create role foo2;

show users;

GRANT ROLE foo1 TO USER gtashiro;
GRANT ROLE foo2 TO USER gtashiro;

USE ROLE ACCOUNTADMIN;
SELECT * FROM data_to_be_masked;

create or replace tag tag_security_level allowed_values 'low_level', 'high_level';

-- hero_name は、みんな見れる
-- foo1は、hero_name, first_nameが見れる           → first_name -> low_level
-- foo2は、hero_name, first_name, last_nameがみれる　→ last_name -> high_level

alter tag tag_security_level unset masking policy hero_info_mask;
 
create or replace masking policy hero_info_mask as (val string) returns string ->
  case
    when (is_role_in_session('FOO1') or is_role_in_session('FOO2')) and system$get_tag_on_current_column('tag_security_level') = 'low_level' then val 
    when is_role_in_session('FOO2') and system$get_tag_on_current_column('tag_security_level') = 'high_level' then val 
    else '***MASKED***'
  end;



alter tag tag_security_level set masking policy hero_info_mask;

alter table data_to_be_masked alter column 
   first_name set tag tag_security_level = 'low_level'
 , last_name  set tag tag_security_level = 'high_level';

use role foo1;
select * from data_to_be_masked;


-- 
use role securityadmin;
grant usage on database ff_week_9 to role foo1;
grant usage on schema ff_week_9.public to role foo1;
grant usage on warehouse compute_wh to role foo1;
grant select on ff_week_9.public.data_to_be_masked to role foo1;

grant usage on database ff_week_9 to role foo2;
grant usage on schema ff_week_9.public to role foo2;
grant usage on warehouse compute_wh to role foo2;
grant select on ff_week_9.public.data_to_be_masked to role foo2;

use role foo1;
select * from data_to_be_masked;

use role foo2;
select * from data_to_be_masked;

use role sysadmin;
select * from data_to_be_masked;

use role accountadmin;
--
create or replace masking policy hero_info_mask2 as (val string) returns string ->
  case
    when CURRENT_ROLE() in ('FOO1','FOO2') and system$get_tag_on_current_column('tag_security_level') = 'low_level' then val 
    when CURRENT_ROLE() in ('FOO2') and system$get_tag_on_current_column('tag_security_level') = 'high_level' then val 
    else '***MASKED***'
  end;  

create or replace tag tag_security_level2 allowed_values 'low_level', 'high_level';

alter tag tag_security_level2 set masking policy hero_info_mask2;

alter table data_to_be_masked alter column 
   first_name set tag tag_security_level2 = 'low_level'
 , last_name  set tag tag_security_level2 = 'high_level';

 select * from data_to_be_masked;
 -- SQL実行エラー：列 FF_WEEK_9.PUBLIC.DATA_TO_BE_MASKED.FIRST_NAME はタグによって複数のマスキングポリシーにマップされています。問題を修正するには、ローカル管理者に連絡してください。

alter table data_to_be_masked alter column first_name unset tag tag_security_level2;
alter table data_to_be_masked alter column last_name  unset tag tag_security_level2;

select * from data_to_be_masked;

alter table data_to_be_masked alter column first_name unset tag tag_security_level;
alter table data_to_be_masked alter column last_name  unset tag tag_security_level;

select * from data_to_be_masked;

alter table data_to_be_masked alter column first_name set tag tag_security_level2 = 'low_level';
alter table data_to_be_masked alter column last_name  set tag tag_security_level2 = 'high_level';
select * from data_to_be_masked;

use role foo1;
select * from data_to_be_masked;

use role foo2;
select * from data_to_be_masked;

use role sysadmin;
select * from data_to_be_masked;

use role accountadmin;
alter tag tag_security_level2 unset masking policy hero_info_mask2;

create or replace masking policy hero_info_mask2 as (val string) returns string ->
  case
    when CURRENT_ROLE() in ('FOO1','FOO2') and system$get_tag_on_current_column('tag_security_level2') = 'low_level' then val 
    when CURRENT_ROLE() in ('FOO2') and system$get_tag_on_current_column('tag_security_level2') = 'high_level' then val 
    else '***MASKED***'
  end; 

alter tag tag_security_level2 set masking policy hero_info_mask2;

use role foo1;
select * from data_to_be_masked;

use role foo2;
select * from data_to_be_masked;

use role sysadmin;
select * from data_to_be_masked;

