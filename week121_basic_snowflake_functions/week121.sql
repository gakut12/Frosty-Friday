use role sysadmin;
use warehouse gaku_wh;
use database frosty_friday;
create or replace schema week121;

CREATE OR REPLACE TABLE DucksAndGeese (
id INT PRIMARY KEY,
column1 VARCHAR(10),
column2 VARCHAR(10),
column3 VARCHAR(10),
column4 VARCHAR(10),
column5 VARCHAR(10),
column6 VARCHAR(10),
column7 VARCHAR(10),
column8 VARCHAR(10),
column9 VARCHAR(10),
column10 VARCHAR(10),
column11 VARCHAR(10),
column12 VARCHAR(10),
column13 VARCHAR(10),
column14 VARCHAR(10),
column15 VARCHAR(10),
column16 VARCHAR(10),
column17 VARCHAR(10),
column18 VARCHAR(10),
column19 VARCHAR(10),
column20 VARCHAR(10),
column21 VARCHAR(10),
column22 VARCHAR(10),
column23 VARCHAR(10),
column24 VARCHAR(10),
column25 VARCHAR(10),
column26 VARCHAR(10),
column27 VARCHAR(10),
column28 VARCHAR(10),
column29 VARCHAR(10),
column30 VARCHAR(10),
column31 VARCHAR(10),
column32 VARCHAR(10),
column33 VARCHAR(10),
column34 VARCHAR(10),
column35 VARCHAR(10),
column36 VARCHAR(10),
column37 VARCHAR(10),
column38 VARCHAR(10),
column39 VARCHAR(10),
column40 VARCHAR(10),
column41 VARCHAR(10),
column42 VARCHAR(10),
column43 VARCHAR(10),
column44 VARCHAR(10),
column45 VARCHAR(10),
column46 VARCHAR(10),
column47 VARCHAR(10),
column48 VARCHAR(10),
column49 VARCHAR(10),
column50 VARCHAR(10),
column51 VARCHAR(10),
column52 VARCHAR(10),
column53 VARCHAR(10),
column54 VARCHAR(10),
column55 VARCHAR(10),
column56 VARCHAR(10),
column57 VARCHAR(10),
column58 VARCHAR(10),
column59 VARCHAR(10),
column60 VARCHAR(10),
column61 VARCHAR(10),
column62 VARCHAR(10),
column63 VARCHAR(10),
column64 VARCHAR(10),
column65 VARCHAR(10),
column66 VARCHAR(10),
column67 VARCHAR(10),
column68 VARCHAR(10),
column69 VARCHAR(10),
column70 VARCHAR(10),
column71 VARCHAR(10),
column72 VARCHAR(10),
column73 VARCHAR(10),
column74 VARCHAR(10),
column75 VARCHAR(10),
column76 VARCHAR(10),
column77 VARCHAR(10),
column78 VARCHAR(10),
column79 VARCHAR(10),
column80 VARCHAR(10),
column81 VARCHAR(10),
column82 VARCHAR(10),
column83 VARCHAR(10),
column84 VARCHAR(10),
column85 VARCHAR(10),
column86 VARCHAR(10),
column87 VARCHAR(10),
column88 VARCHAR(10),
column89 VARCHAR(10),
column90 VARCHAR(10),
column91 VARCHAR(10),
column92 VARCHAR(10),
column93 VARCHAR(10),
column94 VARCHAR(10),
column95 VARCHAR(10),
column96 VARCHAR(10),
column97 VARCHAR(10),
column98 VARCHAR(10),
column99 VARCHAR(10),
column100 VARCHAR(10)
);

INSERT INTO DucksAndGeese VALUES
(1, 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck','Duck','Duck','Duck', 'Duck'),
(2, 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck','Duck','Duck','Duck', 'Duck'),
(3, 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck','Duck','Duck','Duck', 'Duck'),
(4, 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck','Duck','Duck','Duck', 'Duck'),
(5, 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck','Duck','Duck','Duck', 'Duck'),
(6, 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck','Duck','Duck','Duck', 'Duck'),
(7, 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck','Duck','Duck','Duck', 'Duck'),
(8, 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Goose', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck','Duck','Duck','Duck', 'Duck'),
(9, 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck','Duck','Duck','Duck', 'Duck'),
(10, 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck', 'Duck','Duck','Duck','Duck', 'Duck');


select * from DucksAndGeese;

-- hashにidが含まれる
select id , hash(*) as hashed from DucksAndGeese;

-- hashは、column_* のみを使いたい
select id , hash(* exclude id) as hashed from DucksAndGeese;

with hashed as (
    select 
        id
        , hash(* exclude id) as hashed
    from DucksAndGeese
)
select hashed, array_agg(id) as ids from hashed group by hashed
;


select id , hash(* ilike 'column%') as hashed from DucksAndGeese;

-- id=8 include Goose
select * from DucksAndGeese where id = 8;

-- Dynamic Unpivot 
with hoge as (
    select * from DucksAndGeese where id = 8
)
,geho as (
    select {* exclude id} as line from hoge
)
, unpivoted as (
select 
    f.key
    , f.value 
from 
    geho q
    , lateral flatten(q.line) f
)
select * from unpivoted
where value != 'Duck'
;
