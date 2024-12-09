-- set environment 実行環境設定


use role sysadmin;
use warehouse gaku_wh;

use database frosty_friday;
create or replace schema week120;

-- startup script

CREATE OR REPLACE VIEW WEB_SALES as (
    SELECT * from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.WEB_SALES
    LIMIT 5000
);
CREATE OR REPLACE VIEW WEB_RETURNS as (
    SELECT * from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.WEB_RETURNS
    LIMIT 5000
);
CREATE OR REPLACE VIEW WEB_SITE as (
    SELECT * from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.WEB_SITE
    LIMIT 5000
);
CREATE OR REPLACE VIEW WEB_PAGE as (
    SELECT * from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.WEB_PAGE
    LIMIT 5000
);
CREATE OR REPLACE VIEW WEB_ITEM as (
    SELECT * from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.ITEM
    LIMIT 5000
);

-- join key from challange sql
-- ws_web_page_sk : wr_web_page_sk
-- ws_item_sk     : wr_item_sk
-- ws_web_page_sk ; wp_web_page_sk
-- ws_web_site_sk : web_site_sk
-- ws_item_sk     : i_item_sk

CALL SNOWFLAKE.DATA_PRIVACY.GENERATE_SYNTHETIC_DATA({
    'datasets':[
        {
          'input_table': 'frosty_friday.week120.WEB_SALES',
          'output_table': 'frosty_friday.week120.WEB_SALES_SYNTHETIC',
          'columns': {'ws_web_page_sk': {'join_key': True}, 'ws_item_sk': {'join_key': True}, 'ws_web_site_sk': {'join_key': True}}
        }
        , {
          'input_table': 'frosty_friday.week120.WEB_RETURNS',
          'output_table': 'frosty_friday.week120.WEB_RETURNS_SYNTHETIC',
          'columns': {'wr_web_page_sk': {'join_key': True}, 'wr_item_sk': {'join_key': True}}
        }
        , {
          'input_table': 'frosty_friday.week120.WEB_SITE',
          'output_table': 'frosty_friday.week120.WEB_SITE_SYNTHETIC',
          'columns': {'web_site_id': {'join_key': False}, 'web_name': {'join_key': False}, 'web_site_sk': {'join_key': True}}
        }
        , {
          'input_table': 'frosty_friday.week120.WEB_PAGE',
          'output_table': 'frosty_friday.week120.WEB_PAGE_SYNTHETIC',
          'columns': {'wp_web_page_sk': {'join_key': True}}
        }
        , {
          'input_table': 'frosty_friday.week120.WEB_ITEM',
          'output_table': 'frosty_friday.week120.WEB_ITEM_SYNTHETIC',
          'columns': {'i_item_id': {'join_key': False}, 'i_item_sk': {'join_key': True}}
        }
      ]
      , 'privacy_filter': false
      , 'replace_output_tables':True
  });

  -- SYNTHENIC DATA joined
select 
    ws.*,
    wr.*,
    wp.*,
    wsi.*,
    wi.*
from WEB_SALES_SYNTHETIC ws
left join WEB_RETURNS_SYNTHETIC wr
    on ws.ws_web_page_sk = wr.wr_web_page_sk
    and ws.ws_item_sk = wr.wr_item_sk
left join WEB_PAGE_SYNTHETIC wp
    on ws.ws_web_page_sk = wp.wp_web_page_sk
left join WEB_SITE_SYNTHETIC wsi
    on ws.ws_web_site_sk = wsi.web_site_sk
left join WEB_ITEM_SYNTHETIC wi
    on ws.ws_item_sk = wi.i_item_sk;

-- WEB_RETURNS_SYNTHETICも突合0件 
-- -> そもそもOriginal（WEB_RETURNS）でも突合なし
-- WEB_ITEM_SYNTHETICのも突合0件
-- -> Originalでは突合は少ないがある

-- 元データ
  select 
    ws.*,
    wr.*,
    wp.*,
    wsi.*,
    wi.*
from WEB_SALES ws
left join WEB_RETURNS wr
    on ws.ws_web_page_sk = wr.wr_web_page_sk
    and ws.ws_item_sk = wr.wr_item_sk
left join WEB_PAGE wp
    on ws.ws_web_page_sk = wp.wp_web_page_sk
left join WEB_SITE wsi
    on ws.ws_web_site_sk = wsi.web_site_sk
left join WEB_ITEM wi
    on ws.ws_item_sk = wi.i_item_sk;

