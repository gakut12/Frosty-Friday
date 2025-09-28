-- utils.sql(jinja) 
-- これは、Snowsightでは動かないので注意
-- 結果的に、PARSE_JSONは不要だった・・・・
SELECT
  value::NUMBER AS original_number,
  original_number * original_number AS squared
FROM
  TABLE(FLATTEN(INPUT => PARSE_JSON('{{number_of_array}}')))
;