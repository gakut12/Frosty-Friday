use role sysadmin;

-- を指定
-- &database_name
-- &role_name

create database &database_name;
create schema &database_name.security;

use role securityadmin;
-- dev_role should be able to create and query all (future) tables, views, and schemas in every database, except for changing anything in the security schemas.
grant usage, create schema on database &database_name to role &role_name;
grant usage, create table, create view on schema &database_name.public to role &role_name;
grant select on future tables in schema &database_name.public to role &role_name;
grant select on all tables in schema &database_name.public to role &role_name;
grant select on future views in schema &database_name.public to role &role_name;
grant select on all views in schema &database_name.public to role &role_name;
