use role sysadmin;
use warehouse gaku_wh;

use database frosty_friday;
create or replace schema week123;

show tables;

create or replace table WEEK123_SCRAPE_FROM_INDIANCULTURE (
    TAG text
    , CONTENT text
);
