-- week39: https://frostyfriday.org/blog/2023/03/24/week-39-basic/

-- 環境準備(DB・スキーマ・テーブル準備)
use role accountadmin;

show users;
SELECT "name", "default_secondary_roles"
FROM TABLE(result_scan(last_query_id()));

CREATE OR REPLACE PROCEDURE update_default_secondary_roles_for_all()
RETURNS VARIANT NOT NULL
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
let updated_users = [];
let users = snowflake.execute({sqlText: "SHOW USERS"});
while (users.next()) {
    let username = users.getColumnValue("name");
    let dsr = users.getColumnValue("default_secondary_roles");

    // SNOWFLAKEユーザーの場合はスキップ
    if (username === 'SNOWFLAKE') {
        continue;
    }

    // default_secondary_rolesが["ALL"]の場合のみ処理を実行
    if (dsr === '["ALL"]') {
        snowflake.execute({
            sqlText: "alter user identifier(?) set default_secondary_roles=()",
            binds: ["\"" + username + "\""],
        });
        updated_users.push(username);
    }
}
return updated_users;
$$;

USE ROLE ACCOUNTADMIN; 
CALL update_default_secondary_roles_for_all();



use role accountadmin;
create or replace database ff39_db;
create or replace schema general_schema;
use schema ff39_db.general_schema;

create or replace table customer_deets (
    id int,
    name string,
    email string
);

insert into customer_deets values
    (1, 'Jeff Jeffy', 'jeff.jeffy121@gmail.com'),
    (2, 'Kyle Knight', 'kyleisdabest@hotmail.com'),
    (3, 'Spring Hall', 'hall.yay@gmail.com'),
    (4, 'Dr Holly Ray', 'drdr@yahoo.com');

select * from customer_deets;

-- 解答
-- 機能ロールの作成
-- drop role devops_func_role;
-- drop role devops_admin_func_role;
create or replace role devops_func_role;
create or replace role devops_admin_func_role;

create or replace role use_compute_wh_access_role;
grant usage on warehouse compute_wh to role use_compute_wh_access_role;
grant role use_compute_wh_access_role to role devops_func_role;
grant role use_compute_wh_access_role to role devops_admin_func_role;

-- 機能ロールは全てsysadminに継承
grant role devops_func_role to role sysadmin;
grant role devops_admin_func_role to role sysadmin;

use role devops_func_role;
select is_database_role_in_session('readonly_including_pii_access_role');
select is_database_role_in_session('readonly_access_role');
select is_database_role_in_session('pii_access_role');
use role devops_admin_func_role;
select is_database_role_in_session('readonly_including_pii_access_role');
select is_database_role_in_session('readonly_access_role');
select is_database_role_in_session('pii_access_role');

-- アクセスロールの作成
use role accountadmin;
-- drop database role readonly_access_role;
-- drop database role readonly_including_pii_access_role;
create or replace database role ff39_db.readonly_access_role;
create or replace database role ff39_db.readonly_including_pii_access_role;

grant usage on database ff39_db to database role ff39_db.readonly_access_role;
grant usage on schema ff39_db.general_schema to database role ff39_db.readonly_access_role;
grant select on all tables in schema ff39_db.general_schema to database role ff39_db.readonly_access_role;
grant select on future tables in schema ff39_db.general_schema to database role ff39_db.readonly_access_role;

grant database role ff39_db.readonly_access_role to role devops_func_role;

grant usage on database ff39_db to database role ff39_db.readonly_including_pii_access_role;
grant usage on schema ff39_db.general_schema to database role ff39_db.readonly_including_pii_access_role;
grant select on all tables in schema ff39_db.general_schema to database role ff39_db.readonly_including_pii_access_role;
grant select on future tables in schema ff39_db.general_schema to database role ff39_db.readonly_including_pii_access_role;

grant database role ff39_db.readonly_including_pii_access_role to role devops_admin_func_role;

show users;
USE SECONDARY ROLES NONE;

use role devops_func_role;
select is_database_role_in_session('readonly_including_pii_access_role');
select is_database_role_in_session('readonly_access_role');
select is_database_role_in_session('pii_access_role');
use role devops_admin_func_role;
select is_database_role_in_session('readonly_including_pii_access_role');
select is_database_role_in_session('readonly_access_role');
select is_database_role_in_session('pii_access_role');

-- マスキングアクセスロールの作成
use role accountadmin;
-- drop database role pii_access_role;
create or replace database role pii_access_role;

grant database role pii_access_role to database role readonly_including_pii_access_role;
-- revoke database role pii_access_role from database role readonly_including_pii_access_role;

use role devops_func_role;
select is_database_role_in_session('readonly_including_pii_access_role');
select is_database_role_in_session('readonly_access_role');
select is_database_role_in_session('pii_access_role');

use role devops_admin_func_role;
select is_database_role_in_session('readonly_including_pii_access_role');
select is_database_role_in_session('readonly_access_role');
select is_database_role_in_session('pii_access_role');

-- マスキング処理の作成
use role accountadmin;
create or replace function email_masking_function(email varchar)
RETURNS VARCHAR
AS $$
    CONCAT('*****', '@', SPLIT_PART(email, '@', 2))
$$;

-- 動作確認
select email_masking_function(email) from customer_deets;

-- マスキングポリシーの作成
create or replace masking policy email_masking_policy AS (email varchar) returns varchar ->
    CASE
        when is_database_role_in_session('pii_access_role') then email
        else ff39_db.general_schema.email_masking_function(email)
    end
;

-- マスキングポリシーのアタッチ
ALTER TABLE ff39_db.general_schema.customer_deets MODIFY COLUMN email SET MASKING POLICY email_masking_policy;
-- ALTER TABLE ff39_db.general_schema.customer_deets MODIFY COLUMN email UNSET MASKING POLICY;

-- 動作確認
-- 1. 個人情報閲覧不可のロールでSELECTした場合、メールアドレスがマスクされる
use role devops_func_role;
use warehouse compute_wh;
select * from ff39_db.general_schema.customer_deets;

select is_database_role_in_session('pii_access_role');

-- 2. 個人情報閲覧可のロールでSELECTした場合、メールアドレスがマスクされない
use role devops_admin_func_role;
use warehouse compute_wh;
select * from ff39_db.general_schema.customer_deets;

select is_database_role_in_session('pii_access_role');
