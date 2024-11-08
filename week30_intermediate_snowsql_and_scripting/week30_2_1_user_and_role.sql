use role securityadmin;
create user ff_30_security_user PASSWORD = 'abc123' DEFAULT_SECONDARY_ROLES = ( 'ALL' );
create user ff_30_dev_user PASSWORD = 'abc123' DEFAULT_SECONDARY_ROLES = ( 'ALL' );
create user ff_30_regular_user PASSWORD = 'abc123' DEFAULT_SECONDARY_ROLES = ( 'ALL' );

-- 2 additional roles called dev_role and security_role
create role ff_30_dev_role;
create role ff_30_security_role;

grant role ff_30_dev_role to user ff_30_dev_user;
grant role ff_30_security_role to user ff_30_security_user;
