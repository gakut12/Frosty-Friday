use role sysadmin;
use warehouse GAKU_WH;

use database gaku_frosty_friday_db;
create or replace schema week067;

create or replace table us_patents as (
SELECT patent_index.patent_id
    , invention_title
    , patent_type
    , application_date 
    , document_publication_date
FROM cybersyn_us_patent_grants.cybersyn.uspto_contributor_index AS contributor_index
INNER JOIN
    cybersyn_us_patent_grants.cybersyn.uspto_patent_contributor_relationships AS relationships
    ON contributor_index.contributor_id = relationships.contributor_id
INNER JOIN
    cybersyn_us_patent_grants.cybersyn.uspto_patent_index AS patent_index
    ON relationships.patent_id = patent_index.patent_id
WHERE contributor_index.contributor_name ILIKE 'NVIDIA CORPORATION'
    AND relationships.contribution_type = 'Assignee - United States Company Or Corporation'
);

select * from us_patents limit 10;
select patent_type, count(*) from us_patents group by all;
/**
PATENT_TYPE	COUNT(*)
Design	12
Utility	6450
Reissue	6
**/

-- 解法①　udf , langurage : sql
create or replace function ff_week_67_udf (patent_type string, application_date date, document_publication_date date)
returns variant
language sql
as
$$
    TO_VARIANT(
        OBJECT_CONSTRUCT(
            'patent_type', patent_type
            , 'days_difference'
            , datediff(day,application_date,document_publication_date )
            , 'inside_of_projection'
            , case 
                 when (patent_type = 'Reissue' and datediff(day, application_date, document_publication_date ) <= 365 )  then 'true'
                 when (patent_type = 'Design' and datediff(day, application_date, document_publication_date ) <= 365 * 2)  then 'true'
                 else 'false'
              end
        )
    )
$$
;

select ff_week_67_udf('Reissue',to_date('2025-04-01'), to_date('2025-04-11')); -- true
select ff_week_67_udf('Reissue',to_date('2025-04-01'), to_date('2026-04-11')); -- false
select ff_week_67_udf('Design',to_date('2025-04-01'), to_date('2025-04-11')); -- true
select ff_week_67_udf('Design',to_date('2025-04-01'), to_date('2026-04-11')); -- true
select ff_week_67_udf('Design',to_date('2025-04-01'), to_date('2027-04-11')); -- false

select patent_type, ff_week_67_udf(patent_type, application_date, document_publication_date) from us_patents;

select patent_type, ff_week_67_udf(patent_type, application_date, document_publication_date) from us_patents where patent_type = 'Reissue'; -- 365日以内はTrue
select patent_type, ff_week_67_udf(patent_type, application_date, document_publication_date) from us_patents where patent_type = 'Design'; -- 365*2=730日以内はTrue
select patent_type, ff_week_67_udf(patent_type, application_date, document_publication_date) from us_patents where patent_type = 'Utility';　-- 全部False

create or replace function ff_week_67_udf (patent_type string, application_date date, document_publication_date date)
returns variant
language sql
as
$$
    TO_VARIANT(
        OBJECT_CONSTRUCT(
            'days_difference'
            , datediff(day,application_date,document_publication_date )
            , 'inside_of_projection'
            , case 
                 when (patent_type = 'Reissue' and datediff(day, application_date, document_publication_date ) <= 365 )  then 'true'
                 when (patent_type = 'Design' and datediff(day, application_date, document_publication_date ) <= 365 * 2)  then 'true'
                 else 'false'
              end
        )
    )
$$
;

select *, ff_week_67_udf(patent_type, application_date, document_publication_date) as object_as_output, object_as_output['inside_of_projection']::string as inside_of_projection  from us_patents;


-- 解法② udfにsnowflake scriptingを使ってみる
-- https://docs.snowflake.com/en/release-notes/2025/9_23
-- https://docs.snowflake.com/en/developer-guide/udf/sql/udf-sql-procedural-functions

create or replace function ff_week_67_udf_2_snowflake_scripting (patent_type string, application_date date, document_publication_date date)
returns boolean
language sql
as
$$
    declare
        inside_of_projection boolean default false;
    begin
        inside_of_projection := datediff(day, application_date, document_publication_date ) <= 365;
        return inside_of_projection;
    end;
$$
;

select 'Reissue' as patent_type, to_date('2025-04-01') as application_date, to_date('2025-04-11') as document_publication_date,  ff_week_67_udf_2_snowflake_scripting(patent_type,application_date, document_publication_date) as inside_of_projection;
select 'Reissue' as patent_type, to_date('2025-04-01') as application_date, to_date('2026-04-11') as document_publication_date,  ff_week_67_udf_2_snowflake_scripting(patent_type,application_date, document_publication_date) as inside_of_projection;

create or replace function ff_week_67_udf_2_snowflake_scripting (patent_type string, application_date date, document_publication_date date)
returns boolean
language sql
as
$$
    declare
        inside_of_projection boolean default false;
        term_of_patent_type number default 0;
    begin
        if (patent_type = 'Reissue') then term_of_patent_type := 365;
        elseif (patent_type = 'Design') then term_of_patent_type := 365 * 2;
        else term_of_patent_type := null;
        end if;
        inside_of_projection := datediff(day, application_date, document_publication_date ) <= term_of_patent_type;
        return inside_of_projection;
    end;
$$
;

select 'Reissue' as patent_type, to_date('2025-04-01') as application_date, to_date('2025-04-11') as document_publication_date,  ff_week_67_udf_2_snowflake_scripting(patent_type,application_date, document_publication_date) as inside_of_projection;
select 'Reissue' as patent_type, to_date('2025-04-01') as application_date, to_date('2026-04-11') as document_publication_date,  ff_week_67_udf_2_snowflake_scripting(patent_type,application_date, document_publication_date) as inside_of_projection;
select 'Design' as patent_type, to_date('2025-04-01') as application_date, to_date('2025-04-11') as document_publication_date,  ff_week_67_udf_2_snowflake_scripting(patent_type,application_date, document_publication_date) as inside_of_projection;
select 'Design' as patent_type, to_date('2025-04-01') as application_date, to_date('2026-04-11') as document_publication_date,  ff_week_67_udf_2_snowflake_scripting(patent_type,application_date, document_publication_date) as inside_of_projection;
select 'Design' as patent_type, to_date('2025-04-01') as application_date, to_date('2027-04-11') as document_publication_date,  ff_week_67_udf_2_snowflake_scripting(patent_type,application_date, document_publication_date) as inside_of_projection;

create or replace function ff_week_67_udf_2_snowflake_scripting (patent_type string, application_date date, document_publication_date date)
returns varchar
language sql
as
$$
    declare
        inside_of_projection boolean default false;
        term_of_patent_type number default 0;
    begin
        if (patent_type = 'Reissue') then term_of_patent_type := 365;
        elseif (patent_type = 'Design') then term_of_patent_type := 365 * 2;
        else term_of_patent_type := -1;
        end if;
        inside_of_projection := datediff(day, application_date, document_publication_date ) <= term_of_patent_type;
        return TO_VARCHAR(
                OBJECT_CONSTRUCT(
                    'days_difference'
                    , datediff(day,application_date,document_publication_date )
                    , 'inside_of_projection'
                    , inside_of_projection
                )
            );
    end;
$$
;

select 'Design' as patent_type, to_date('2025-04-01') as application_date, to_date('2027-04-11') as document_publication_date,  ff_week_67_udf_2_snowflake_scripting(patent_type,application_date, document_publication_date) as inside_of_projection;

select *, ff_week_67_udf_2_snowflake_scripting(patent_type, application_date, document_publication_date) as object_as_output, PARSE_JSON(object_as_output)['inside_of_projection']::string as inside_of_projection from us_patents; 


select *, ff_week_67_udf_2_snowflake_scripting(patent_type, application_date, document_publication_date) as object_as_output, PARSE_JSON(object_as_output)['inside_of_projection']::string as inside_of_projection from us_patents where patent_type = 'Reissue';
select *, ff_week_67_udf_2_snowflake_scripting(patent_type, application_date, document_publication_date) as object_as_output, PARSE_JSON(object_as_output)['inside_of_projection']::string as inside_of_projection from us_patents where patent_type = 'Design';
select *, ff_week_67_udf_2_snowflake_scripting(patent_type, application_date, document_publication_date) as object_as_output, PARSE_JSON(object_as_output)['inside_of_projection']::string as inside_of_projection from us_patents where patent_type = 'Utility';