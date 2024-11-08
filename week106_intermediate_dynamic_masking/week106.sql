use role sysadmin;
use warehouse gaku_wh;

use database frosty_friday;
create or replace schema week106;

-- startup code
CREATE TABLE customer_data (
    customer_id INTEGER,
    name STRING,
    email STRING,
    phone STRING,
    address STRING,
    credit_card_number STRING,
    account_balance FLOAT
);

INSERT INTO customer_data (customer_id, name, email, phone, address, credit_card_number, account_balance) VALUES
(1, 'John Doe', 'john.doe@example.com', '123-456-7890', '123 Main St', '4111111111111111', 15000.00),
(2, 'Jane Smith', 'jane.smith@example.com', '234-567-8901', '456 Elm St', '4222222222222222', 8500.00),
(3, 'Alice Johnson', 'alice.johnson@example.com', '345-678-9012', '789 Oak St', '4333333333333333', 3000.00),
(4, 'Bob Brown', 'bob.brown@example.com', '456-789-0123', '101 Pine St', '4444444444444444', 500.00),
(5, 'Charlie Davis', 'charlie.davis@example.com', '567-890-1234', '202 Maple St', '4555555555555555', 12000.00),
(6, 'Diana Evans', 'diana.evans@example.com', '678-901-2345', '303 Cedar St', '4666666666666666', 2000.00),
(7, 'Frank Green', 'frank.green@example.com', '789-012-3456', '404 Birch St', '4777777777777777', 30000.00),
(8, 'Hannah White', 'hannah.white@example.com', '890-123-4567', '505 Willow St', '4888888888888888', 4500.00),
(9, 'Ian Black', 'ian.black@example.com', '901-234-5678', '606 Aspen St', '4999999999999999', 7500.00),
(10, 'Jill Blue', 'jill.blue@example.com', '012-345-6789', '707 Cherry St', '4000000000000000', 500.00);

select * from customer_data;

-- create 3 roles
use role securityadmin;
create role ff_week106_admin;
create role ff_week106_manager;
create role ff_week106_manager;


grant role ff_week106_admin to user "g.tashiro@churadata.okinawa";
grant role ff_week106_manager to user "g.tashiro@churadata.okinawa";
grant role ff_week106_analyst to user "g.tashiro@churadata.okinawa";

use role sysadmin;
use database frosty_friday;
grant usage on database frosty_friday to role ff_week106_admin;
grant usage on database frosty_friday to role ff_week106_manager;
grant usage on database frosty_friday to role ff_week106_analyst;

grant usage on schema frosty_friday.week106 to role ff_week106_admin;
grant usage on schema frosty_friday.week106 to role ff_week106_manager;
grant usage on schema frosty_friday.week106 to role ff_week106_analyst;

grant select on all tables in schema week106 to role ff_week106_admin;
grant select on all tables in schema week106 to role ff_week106_manager;
grant select on all tables in schema week106 to role ff_week106_analyst;

grant usage on warehouse gaku_wh to role ff_week106_admin;
grant usage on warehouse gaku_wh to role ff_week106_manager;
grant usage on warehouse gaku_wh to role ff_week106_analyst;

use role ff_week106_admin;
select * from week106.customer_data;

/**
For analyst role: Fully mask the credit card number, mask the domain part of the email, and mask the account balance.
For manager role: Partially mask the credit card number (showing only the last 4 digits), mask the domain part of the email, and partially mask the account balance by rounding it.
For admin role: No masking is applied; the admin should see the full data.
**/

use role sysadmin;
use schema frosty_friday.week106;
desc table customer_data;
/**
name	type	kind	null?	default	primary key	unique key	check	expression	comment	policy name	privacy domain
CUSTOMER_ID	        NUMBER(38,0)	COLUMN	Y		N	N					
NAME	            VARCHAR(16777216)	COLUMN	Y		N	N					
EMAIL	            VARCHAR(16777216)	COLUMN	Y		N	N					
PHONE	            VARCHAR(16777216)	COLUMN	Y		N	N					
ADDRESS	            VARCHAR(16777216)	COLUMN	Y		N	N					
CREDIT_CARD_NUMBER	VARCHAR(16777216)	COLUMN	Y		N	N					
ACCOUNT_BALANCE	    FLOAT	COLUMN	Y		N	N					
**/

use role sysadmin;
-- email
select email from customer_data;
-- mask the domain part of the email
select regexp_replace(email,'(.*)@(.*)', '\\1@********') from customer_data;

-- credit_card_number
select credit_card_number from customer_data;

-- Partially mask the credit card number (showing only the last 4 digits)
select regexp_replace(credit_card_number,'^(.*)([0-9][0-9][0-9][0-9])$','************\\2') from customer_data;
-- credit card number full masking
select regexp_replace(credit_card_number,'[0-9]','*') from customer_data;

-- account balance
-- partial mask
select (floor(account_balance/2000))*2000 as account_balance from customer_data order by 1;
-- full mask
select null as account_balance from customer_data;

-- ff_week106_admin;
-- ff_week106_manager;
-- ff_week106_analyst;

CREATE OR REPLACE MASKING POLICY mask_credit_card_number
AS (val string) RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() in ('FF_WEEK106_ANALYST') THEN regexp_replace(val,'[0-9]','*')
    WHEN CURRENT_ROLE() in ('FF_WEEK106_MANAGER') THEN regexp_replace(val,'^(.*)([0-9][0-9][0-9][0-9])$','************\\2')
    ELSE val
  END;

CREATE OR REPLACE MASKING POLICY mask_email
AS (val string) RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() in ('FF_WEEK106_ANALYST','FF_WEEK106_MANAGER') THEN regexp_replace(val,'(.*)@(.*)', '\\1@********')
    ELSE val
  END;

CREATE OR REPLACE MASKING POLICY mask_account_balance
AS (val float) RETURNS float ->
  CASE
    WHEN CURRENT_ROLE() in ('FF_WEEK106_ANALYST') THEN null
    WHEN CURRENT_ROLE() in ('FF_WEEK106_MANAGER') THEN floor(val/2000)*2000
    ELSE val
  END;

-- unset (masking policyを修正する時は必要)
-- if masking policy change, require "alter table unset"
alter table customer_data modify 
    column email unset masking policy 
    , column CREDIT_CARD_NUMBER unset masking policy 
    , column ACCOUNT_BALANCE unset masking policy 
;

-- set masking policy 
alter table customer_data modify 
    column email set masking policy mask_email
    , column CREDIT_CARD_NUMBER set masking policy mask_credit_card_number
    , column ACCOUNT_BALANCE set masking policy mask_account_balance
;


select * from customer_data;

use role ff_week106_analyst;
select * from customer_data;

use role ff_week106_manager;
select * from customer_data;

use role ff_week106_admin;
select * from customer_data;
