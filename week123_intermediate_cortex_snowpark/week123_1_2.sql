select * from WEEK123_SCRAPE_FROM_INDIANCULTURE;

-- https://docs.snowflake.com/en/sql-reference/functions/translate-snowflake-cortex

SELECT TAG, CONTENT, SNOWFLAKE.CORTEX.TRANSLATE(content, 'hi', 'en') as TRASLATE FROM WEEK123_SCRAPE_FROM_INDIANCULTURE;



