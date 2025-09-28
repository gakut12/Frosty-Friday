-- utils.sql(jinja) 
-- これは、Snowsightでは動かないので注意

SELECT
  value::NUMBER AS original_number,
  original_number * original_number AS squared
FROM
  TABLE(FLATTEN(INPUT => {{number_of_array}}))
;
