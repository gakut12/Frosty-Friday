use role sysadmin;
drop database if exists ff_30_development;
drop database if exists ff_30_testing;
drop database if exists ff_30_acceptance;
drop database if exists ff_30_production;

use role securityadmin;
drop user if exists ff_30_security_user;
drop user if exists ff_30_dev_user;
drop user if exists ff_30_regular_user;

drop role if exists ff_30_dev_role;
drop role if exists ff_30_security_role;
