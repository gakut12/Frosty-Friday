/**
今週は、テーブルを JSON VARIANT オブジェクトに変換します。
普通、JSON形式のデータをテーブルに取り込むことが多いと思いますが、今回はその逆を行います

ここにはスーパーヒーローのセットに関する情報を含むテーブルがあります。
このテーブルを JSON VARIANT オブジェクトに変換することです。
例は、
https://frostyfriday.org/wp-content/uploads/2022/09/result.png
にあるので、こちらを再現してください

- country_of_residence
- superhero_name
- superpowers

※カラム名は小文字で出力
※superpower, second_superpower, third_superpowerをARRAY型へ
※superpowerがない場合は、undefined と表示

**/

use role sysadmin;
use warehouse gaku_wh;
create or replace database frosty_friday;
create or replace schema week14;

create or replace table week_14 (
    superhero_name varchar(50),
    country_of_residence varchar(50),
    notable_exploits varchar(150),
    superpower varchar(100),
    second_superpower varchar(100),
    third_superpower varchar(100)
);

INSERT INTO week_14 VALUES ('Superpig', 'Ireland', 'Saved head of Irish Farmer\'s Association from terrorist cell', 'Super-Oinks', NULL, NULL);
INSERT INTO week_14 VALUES ('Señor Mediocre', 'Mexico', 'Defeated corrupt convention of fruit lobbyists by telling anecdote that lasted 33 hours, with 16 tangents that lead to 17 resignations from the board', 'Public speaking', 'Stamp collecting', 'Laser vision');
INSERT INTO week_14 VALUES ('The CLAW', 'USA', 'Horrifically violent duel to the death with mass murdering super villain accidentally created art installation last valued at $14,450,000 by Sotheby\'s', 'Back scratching', 'Extendable arms', NULL);
INSERT INTO week_14 VALUES ('Il Segreto', 'Italy', NULL, NULL, NULL, NULL);
INSERT INTO week_14 VALUES ('Frosty Man', 'UK', 'Rescued a delegation of data engineers from a DevOps conference', 'Knows, by memory, 15 definitions of an obscure codex known as "the data mesh"', 'can copy and paste from StackOverflow with the blink of an eye', NULL);

-- 取り込まれたデータを確認しましょう。5件なのでLimit句とか付けてません
select * from week_14;

-- テーブル定義も確認。今回は、カラム名だけがわかれば十分ですが
desc table week_14;
/**
name	type	kind	null?	default	primary key	unique key	check	expression	comment	policy name	privacy domain
SUPERHERO_NAME	VARCHAR(50)	COLUMN	Y		N	N					
COUNTRY_OF_RESIDENCE	VARCHAR(50)	COLUMN	Y		N	N					
NOTABLE_EXPLOITS	VARCHAR(150)	COLUMN	Y		N	N					
SUPERPOWER	VARCHAR(100)	COLUMN	Y		N	N					
SECOND_SUPERPOWER	VARCHAR(100)	COLUMN	Y		N	N					
THIRD_SUPERPOWER	VARCHAR(100)	COLUMN	Y		N	N					
**/

select
    country_of_residence
    , superhero_name
    , superpower
    , second_superpower
    , third_superpower
from
    week_14;

-- superpowerを配列に
select 
    SUPERHERO_NAME
    , COUNTRY_OF_RESIDENCE
    , ARRAY_CONSTRUCT_COMPACT(SUPERPOWER,SECOND_SUPERPOWER,THIRD_SUPERPOWER) as superpowers
from
    week_14;

-- superpowerがない場合は、「undefined」に
select 
    SUPERHERO_NAME
    , COUNTRY_OF_RESIDENCE
    , ARRAY_CONSTRUCT_COMPACT(SUPERPOWER,SECOND_SUPERPOWER,THIRD_SUPERPOWER) as _superpowers
    , array_size(_superpowers) as superpower_size
    , case 
        when superpower_size = 0 then ARRAY_CONSTRUCT_COMPACT('undefined')
        else _superpowers
    end as superpowers
from
    week_14;

-- valiant を作る準備
select
    object_construct(*)
from
    week_14;

-- CTEで組み立て
with superhero_info_all as (
    select 
        SUPERHERO_NAME
        , COUNTRY_OF_RESIDENCE
        , ARRAY_CONSTRUCT_COMPACT(SUPERPOWER,SECOND_SUPERPOWER,THIRD_SUPERPOWER) as _superpowers
        , array_size(_superpowers) as superpower_size
        , case 
            when superpower_size = 0 then ARRAY_CONSTRUCT_COMPACT('undefined')
            else _superpowers
        end as superpowers
    from
        week_14
    )
, superhero_info as (
    select
        COUNTRY_OF_RESIDENCE as "country_of_residencd" -- 出力は小文字だったので、""で囲んで小文字固定
        , SUPERHERO_NAME as "superhero_name"
        , superpowers as "superpowers"
    from 
        superhero_info_all
)
select object_construct(*) as superhero_json from superhero_info;


-- CTEで組み立て
with superhero_info_all as (
    select 
        country_of_residence 
        , superhero_name 
        , array_construct_compact(superpower,second_superpower,third_superpower) as _superpowers
        , case 
            when array_size(_superpowers) = 0 then array_construct_compact('undefined')
            else _superpowers
        end  superpowers
    from
        week_14
    )
, superhero_info as (
    select
        country_of_residence as "country_of_residencd" -- 出力は小文字だったので、""で囲んで小文字固定
        , superhero_name as "superhero_name"
        , superpowers as "superpowers"
    from 
        superhero_info_all
)
select object_construct(*) as superhero_json from superhero_info;
