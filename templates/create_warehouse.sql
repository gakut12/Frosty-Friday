use role sysadmin;
create or replace warehouse gaku_dbt_xs_wh
with
    warehouse_type = standard
    warehouse_size = 'XSMALL'
    -- resource_constraint
    -- max_cluster_count = 1
    -- min_cluster_count = 1
    -- scaling_policy = standard
    auto_suspend = 30 -- default 600
    auto_resume = true
    initially_suspended = true
    -- resource_montitor = '' TODO リソースモニターを作る
    comment = 'dbt接続用（開発）田代個人'
;
