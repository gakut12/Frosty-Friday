use role sysadmin;
-- 4 databases, named: Development, Testing, Acceptance, and Production
create database ff_30_development;
create database ff_30_testing;
create database ff_30_acceptance;
create database ff_30_production;

-- 1 additional schema in every database (besides Public) called security
create schema ff_30_development.security;
create schema ff_30_testing.security;
create schema ff_30_acceptance.security;
create schema ff_30_production.security;

-- 1 additional schema in Development called ‘dev_user’
create schema ff_30_development."dev_user";

-- 3 users: security_user, dev_user, regular_user
-- password = abc123
-- secondary roles should be enabled
use role securityadmin;
create user ff_30_security_user PASSWORD = 'abc123' DEFAULT_SECONDARY_ROLES = ( 'ALL' );
create user ff_30_dev_user PASSWORD = 'abc123' DEFAULT_SECONDARY_ROLES = ( 'ALL' );
create user ff_30_regular_user PASSWORD = 'abc123' DEFAULT_SECONDARY_ROLES = ( 'ALL' );

-- 2 additional roles called dev_role and security_role
create role ff_30_dev_role;
create role ff_30_security_role;

-- dev_role should be able to create and query all (future) tables, views, and schemas in every database, except for changing anything in the security schemas.
grant usage, create schema on database ff_30_development to role ff_30_dev_role;
grant usage, create schema on database ff_30_testing to role ff_30_dev_role;
grant usage, create schema on database ff_30_acceptance to role ff_30_dev_role;
grant usage, create schema on database ff_30_production to role ff_30_dev_role;
grant usage, create table, create view on schema ff_30_development.public to role ff_30_dev_role;
grant usage, create table, create view on schema ff_30_testing.public to role ff_30_dev_role;
grant usage, create table, create view on schema ff_30_acceptance.public to role ff_30_dev_role;
grant usage, create table, create view on schema ff_30_production.public to role ff_30_dev_role;
grant usage, create table, create view on schema ff_30_production.public to role ff_30_dev_role;
grant select on future tables in schema ff_30_development.public to role ff_30_dev_role;
grant select on future tables in schema ff_30_testing.public to role ff_30_dev_role;
grant select on future tables in schema ff_30_acceptance.public to role ff_30_dev_role;
grant select on future tables in schema ff_30_production.public to role ff_30_dev_role;
grant select on all tables in schema ff_30_development.public to role ff_30_dev_role;
grant select on all tables in schema ff_30_testing.public to role ff_30_dev_role;
grant select on all tables in schema ff_30_acceptance.public to role ff_30_dev_role;
grant select on all tables in schema ff_30_production.public to role ff_30_dev_role;
grant select on future views in schema ff_30_development.public to role ff_30_dev_role;
grant select on future views in schema ff_30_testing.public to role ff_30_dev_role;
grant select on future views in schema ff_30_acceptance.public to role ff_30_dev_role;
grant select on future views in schema ff_30_production.public to role ff_30_dev_role;
grant select on all views in schema ff_30_development.public to role ff_30_dev_role;
grant select on all views in schema ff_30_testing.public to role ff_30_dev_role;
grant select on all views in schema ff_30_acceptance.public to role ff_30_dev_role;
grant select on all views in schema ff_30_production.public to role ff_30_dev_role;

-- grant usage on database ff_30_development to role ff_30_dev_role;
grant usage, create table, create view on schema ff_30_development."dev_user" to role ff_30_dev_role;
grant select on future tables in schema ff_30_development."dev_user" to role ff_30_dev_role;
grant select on all tables in schema ff_30_development."dev_user" to role ff_30_dev_role;
grant select on future views in schema ff_30_development."dev_user" to role ff_30_dev_role;
grant select on all views in schema ff_30_development."dev_user" to role ff_30_dev_role;

-- security_role should be able to create and query all (future) tables, views, and schemas in every database.
grant usage on database ff_30_development to role ff_30_security_role;
grant usage on database ff_30_testing to role ff_30_security_role;
grant usage on database ff_30_acceptance to role ff_30_security_role;
grant usage on database ff_30_production to role ff_30_security_role;
grant usage, create table, create view on schema ff_30_development.security to role ff_30_security_role;
grant usage, create table, create view on schema ff_30_testing.security to role ff_30_security_role;
grant usage, create table, create view on schema ff_30_acceptance.security to role ff_30_security_role;
grant usage, create table, create view on schema ff_30_production.security to role ff_30_security_role;
grant select on future tables in schema ff_30_development.security to role ff_30_security_role;
grant select on future tables in schema ff_30_testing.security to role ff_30_security_role;
grant select on future tables in schema ff_30_acceptance.security to role ff_30_security_role;
grant select on future tables in schema ff_30_production.security to role ff_30_security_role;
grant select on all tables in schema ff_30_development.security to role ff_30_security_role;
grant select on all tables in schema ff_30_testing.security to role ff_30_security_role;
grant select on all tables in schema ff_30_acceptance.security to role ff_30_security_role;
grant select on all tables in schema ff_30_production.security to role ff_30_security_role;
grant select on future views in schema ff_30_development.security to role ff_30_security_role;
grant select on future views in schema ff_30_testing.security to role ff_30_security_role;
grant select on future views in schema ff_30_acceptance.security to role ff_30_security_role;
grant select on future views in schema ff_30_production.security to role ff_30_security_role;
grant select on all views in schema ff_30_development.security to role ff_30_security_role;
grant select on all views in schema ff_30_testing.security to role ff_30_security_role;
grant select on all views in schema ff_30_acceptance.security to role ff_30_security_role;
grant select on all views in schema ff_30_production.security to role ff_30_security_role;


-- dev_user should have the dev_role , security_user should have the security_role
grant role ff_30_dev_role to user ff_30_dev_user;
grant role ff_30_security_role to user ff_30_security_user;

-- the role public is only allowed to query Production.Public
grant usage on database ff_30_production to role public;
grant usage on schema ff_30_production.public to role public;
grant select on future tables in schema ff_30_production.public to role public;
grant select on future views in schema ff_30_production.public to role public;
grant select on all tables in schema ff_30_production.public to role public;
grant select on all views in schema ff_30_production.public to role public;

-- 1 SMALL warehouse called default_wh
use role sysadmin;
create or replace warehouse ff_30_default_wh
with
  WAREHOUSE_SIZE = SMALL
  INITIALLY_SUSPENDED = TRUE
;

-- Execute the secondary script
use role sysadmin;
use database ff_30_development;
use schema "FF_30_DEVELOPMENT"."PUBLIC";
!source week30_secondary.sql


