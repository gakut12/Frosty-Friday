use role sysadmin;
use database gaku_frosty_friday_db;
create or replace schema week93;
use warehouse gaku_wh;

CREATE OR REPLACE NETWORK RULE ff_93_treasury_nr
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('api.fiscaldata.treasury.gov');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION treasury_eai
  ALLOWED_NETWORK_RULES = (ff_93_treasury_nr)
  ENABLED = true;

GRANT USAGE ON INTEGRATION treasury_eai TO ROLE sysadmin;

CREATE OR REPLACE TABLE WEEK_93 (
  AVG_INTEREST_RATE_AMT FLOAT,
  RECORD_DATE DATE,
  SECURITY_DESC STRING,
  SECURITY_TYPE_DESC STRING,
  SRC_LINE_NBR STRING,
  API_CALL_START_DATE DATE,
  API_CALL_END_DATE DATE
);

CREATE OR REPLACE FUNCTION get_treasury_data(start_date DATE, end_date DATE)
  RETURNS VARIANT
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.11'
  HANDLER = 'get_data'
  EXTERNAL_ACCESS_INTEGRATIONS = (treasury_eai)
  PACKAGES = ('snowflake-snowpark-python', 'requests')
AS
$$
def get_data(start_date, end_date):
    import requests
    url = f"https://api.fiscaldata.treasury.gov/services/api/fiscal_service/v2/accounting/od/avg_interest_rates?filter=record_date:gte:{start_date},record_date:lte:{end_date}"
    response = requests.get(url)
    return response.json()
$$;

SELECT get_treasury_data('2020-01-01'::DATE, '2024-04-30'::DATE);

create table get_treasury_data_20200101_20240430 as SELECT get_treasury_data('2020-01-01'::DATE, '2024-04-30'::DATE) as v;

select * from get_treasury_data_20200101_20240430;

SELECT
  d.value:avg_interest_rate_amt::FLOAT AS avg_interest_rate_amt,
  d.value:record_date::STRING AS record_calendar_day,
  d.value:security_desc::STRING AS security_desc,
  d.value:security_type_desc::STRING AS security_type_desc,
  d.value:src_line_nbr::STRING AS src_line_nbr
FROM
  get_treasury_data_20200101_20240430,
  LATERAL FLATTEN(input => v:data) d;

  
select count(*) from get_treasury_data_20200101_20240430;

-- これだと最大100件
--トータルでは880件、9ページ

-- なので、これをおこなうPythonUDFを作ることにします

  CREATE OR REPLACE FUNCTION get_treasury_data_all(start_date DATE, end_date DATE)
    RETURNS VARIANT
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    HANDLER = 'get_data'
    EXTERNAL_ACCESS_INTEGRATIONS = (treasury_eai)
    PACKAGES = ('snowflake-snowpark-python', 'requests')
  AS
$$
def get_data(start_date, end_date):
    import requests
    import time

    base_url = "https://api.fiscaldata.treasury.gov/services/api/fiscal_service/v2/accounting/od/avg_interest_rates"
    params = {
        "fields": "record_date,security_type_desc,security_desc,avg_interest_rate_amt,src_line_nbr",
        "filter": f"record_date:gte:{start_date},record_date:lt:{end_date}",
        "page[size]": 100,
        "page[number]": 1,
    }

    all_data = []

    response = requests.get(base_url, params=params)
    response.raise_for_status()
    result = response.json()

    all_data.extend(result.get("data", []))
    total_pages = result.get("meta", {}).get("total-pages", 1)

    for page in range(2, total_pages + 1):
        time.sleep(1)  # 1秒待機
        params["page[number]"] = page
        response = requests.get(base_url, params=params)
        response.raise_for_status()
        result = response.json()
        all_data.extend(result.get("data", []))

    return {"data": all_data, "total_count": len(all_data)}
$$;
 
SELECT get_treasury_data_all('2020-01-01'::DATE, '2024-04-30'::DATE) AS result;

  WITH raw AS (
      SELECT get_treasury_data_all('2020-01-01'::DATE, '2024-04-30'::DATE) AS result
  )
  SELECT
      value:avg_interest_rate_amt::FLOAT AS avg_interest_rate_amt,
      value:record_date::DATE           AS record_date,
      value:security_type_desc::STRING  AS security_type_desc,
      value:security_desc::STRING       AS security_desc,
      value:src_line_nbr::INT           AS src_line_nbr
  FROM raw,
  LATERAL FLATTEN(INPUT => result:data)
  ORDER BY record_date DESC;

  -- 863件、2024年4月30日が入っていない

    CREATE OR REPLACE FUNCTION get_treasury_data_all(start_date DATE, end_date DATE)
    RETURNS VARIANT
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    HANDLER = 'get_data'
    EXTERNAL_ACCESS_INTEGRATIONS = (treasury_eai)
    PACKAGES = ('snowflake-snowpark-python', 'requests')
  AS
$$
def get_data(start_date, end_date):
    import requests
    import time

    base_url = "https://api.fiscaldata.treasury.gov/services/api/fiscal_service/v2/accounting/od/avg_interest_rates"
    params = {
        "fields": "record_date,security_type_desc,security_desc,avg_interest_rate_amt,src_line_nbr",
        "filter": f"record_date:gte:{start_date},record_date:lte:{end_date}",
        "page[size]": 100,
        "page[number]": 1,
    }

    all_data = []

    response = requests.get(base_url, params=params)
    response.raise_for_status()
    result = response.json()

    all_data.extend(result.get("data", []))
    total_pages = result.get("meta", {}).get("total-pages", 1)

    for page in range(2, total_pages + 1):
        time.sleep(1.0)  # 1.0秒待機
        params["page[number]"] = page
        response = requests.get(base_url, params=params)
        response.raise_for_status()
        result = response.json()
        all_data.extend(result.get("data", []))

    return {"data": all_data, "total_count": len(all_data)}
$$;

SELECT get_treasury_data_all('2020-01-01'::DATE, '2024-04-30'::DATE) AS result;

  WITH raw AS (
      SELECT get_treasury_data_all('2020-01-01'::DATE, '2024-04-30'::DATE) AS result
  )
  SELECT
      value:avg_interest_rate_amt::FLOAT AS avg_interest_rate_amt,
      value:record_date::DATE           AS record_date,
      value:security_type_desc::STRING  AS security_type_desc,
      value:security_desc::STRING       AS security_desc,
      value:src_line_nbr::INT           AS src_line_nbr
  FROM raw,
  LATERAL FLATTEN(INPUT => result:data)
  ORDER BY record_date DESC;
