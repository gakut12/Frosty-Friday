use role sysadmin;
use warehouse gaku_wh;

use database FROSTY_FRIDAY;
create or replace schema week21;

-- Startup SQL
create or replace table hero_powers (
hero_name VARCHAR(50),
flight VARCHAR(50),
laser_eyes VARCHAR(50),
invisibility VARCHAR(50),
invincibility VARCHAR(50),
psychic VARCHAR(50),
magic VARCHAR(50),
super_speed VARCHAR(50),
super_strength VARCHAR(50)
);
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('The Impossible Guard', '++', '-', '-', '-', '-', '-', '-', '+');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('The Clever Daggers', '-', '+', '-', '-', '-', '-', '-', '++');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('The Quick Jackal', '+', '-', '++', '-', '-', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('The Steel Spy', '-', '++', '-', '-', '+', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Agent Thundering Sage', '++', '+', '-', '-', '-', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Mister Unarmed Genius', '-', '-', '-', '-', '-', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Doctor Galactic Spectacle', '-', '-', '-', '++', '-', '-', '-', '+');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Master Rapid Illusionist', '-', '-', '-', '-', '++', '-', '+', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Galactic Gargoyle', '+', '-', '-', '-', '-', '-', '++', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Alley Cat', '-', '++', '-', '-', '-', '-', '-', '+');


-- Week21 Basic pivoting
-- 解法① unpivot + pivot ( not dynamic pivoting)
select * from hero_powers;

-- unpivotting

select *
  from hero_powers
    unpivot (
      powers for power in (
          flight
        , laser_eyes
        , invisibility
        , invincibility
        , psychic
        , magic
        , super_speed
        , super_strength
      )
    );

with unpivotting as (
select *
  from hero_powers
    unpivot (
      power_level for power in (
          flight
        , laser_eyes
        , invisibility
        , invincibility
        , psychic
        , magic
        , super_speed
        , super_strength
      )
    )
)
, filtered as (
select
    hero_name
    , power
    , case
        when power_level = '++' then 'MAIN_POWER'
        when power_level = '+' then 'SECONDARY_POWER'
        else null
     end as categorized_power_level

from 
    unpivotting
where
    power_level != '-'
)
-- select * from filtered;

select 
    hero_name
    , "'MAIN_POWER'" as main_power
    , "'SECONDARY_POWER'" as secondary_power
from
    filtered
    pivot (
        min(power) for categorized_power_level in (
            'MAIN_POWER'
            , 'SECONDARY_POWER'
        )
    )
;

-- 解法②　動的PIVOT　https://docs.snowflake.com/en/sql-reference/constructs/pivot

with unpivotting as (
select *
  from hero_powers
    unpivot (
      power_level for power in (
          flight
        , laser_eyes
        , invisibility
        , invincibility
        , psychic
        , magic
        , super_speed
        , super_strength
      )
    )
)
, filtered as (
select
    hero_name
    , power
    , case
        when power_level = '++' then 'MAIN_POWER'
        when power_level = '+' then 'SECONDARY_POWER'
        else null
     end as categorized_power_level

from 
    unpivotting
where
    power_level != '-'
)
-- select * from filtered;
select * from filtered
    pivot ( max(power) for categorized_power_level in ( any order by categorized_power_level))
--    AS p (hero_name, main_power, secondary_power)
;

-- 解法③ unpivotを使いたくない　https://zenn.dev/indigo13love/articles/971cdb3b893590
-- 動的UNPIVOT（object_construct使っての実装）＋動的PIVOT（Snowflake提供機能）

-- 動的UNPIVOT（object_constructを利用）
select * from hero_powers;
select object_construct(*) from hero_powers;


with queries as (
 select 
        hero_name,
        object_construct(*) line
    from 
        hero_powers
)
-- select * from  queries;
, unpivoting as (
    select
        queries.hero_name
        , f.*
    from queries, lateral flatten(queries.line) f
)
-- select * from unpivoting;
, rename_colums as (
    select 
        hero_name, 
        key as power, 
        case
            when value = '++' then 'MAIN_POWER'
            when value = '+' then 'SECONDARY_POWER'
            else null
         end as categorized_power_level 
    from unpivoting
    where value != '-' and key != 'HERO_NAME'
    ) 
-- select * from rename_colums;
, pivoting as (
select * from rename_colums
    pivot ( max(power) for categorized_power_level in ( any order by categorized_power_level))
)
-- select * from pivoting;

, final as (
    select
        hero_name
        , "'MAIN_POWER'" as MAIN_POWER
        , "'SECONDARY_POWER'" as SECONDARY_POWER
    from
        pivoting
)
select * from final;

-- 解法③-1 unpivotを使いたくない　https://zenn.dev/indigo13love/articles/971cdb3b893590
-- 動的UNPIVOT（object_construct使っての実装）＋動的PIVOT（Snowflake提供機能）
-- ちょっとリファクタリング（ hero_nameの重複をへらして、SQLを更にシンプルに）

-- 動的UNPIVOT（object_constructを利用）
select * from hero_powers;
select object_construct(* exclude hero_name) from hero_powers;


with queries as (
 select 
        hero_name,
        object_construct(* exclude hero_name) line
    from 
        hero_powers
)
-- select * from  queries;
, unpivoting as (
    select
        queries.hero_name
        , f.*
    from queries, lateral flatten(queries.line) f
)
-- select * from unpivoting;
, rename_colums as (
    select 
        hero_name, 
        key as power, 
        case
            when value = '++' then 'MAIN_POWER'
            when value = '+' then 'SECONDARY_POWER'
            else null
         end as categorized_power_level 
    from 
        unpivoting
    where 
        value != '-'
    ) 
-- select * from rename_colums;
, pivoting as (
select * from rename_colums
    pivot ( max(power) for categorized_power_level in ( any order by categorized_power_level))
)
-- select * from pivoting;
, final as (
    select
        hero_name
        , "'MAIN_POWER'" as MAIN_POWER
        , "'SECONDARY_POWER'" as SECONDARY_POWER
    from
        pivoting
)
select * from final;
