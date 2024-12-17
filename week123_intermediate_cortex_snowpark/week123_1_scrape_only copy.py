import requests
from bs4 import BeautifulSoup
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
import sys


def scrape_text_from_url(url):
    print("scrape_test_from_url")
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0 Safari/537.36'
        }
        response = requests.get(url, headers=headers)
        response.raise_for_status()

        soup = BeautifulSoup(response.text, 'html.parser')
        title_tag = soup.title.get_text().strip().upper() if soup.title else ""

        main_content = soup.find('body')
        if not main_content:
            print("Main content not found.")
            return None

        elements = main_content.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p'])

        start_collecting = False
        filtered_elements = []

        for element in elements:
            if element.name == 'h1' and element.get_text(strip=True).upper() == 'प्राचीन भारत में किलों का इतिहास':
                start_collecting = True
            if start_collecting:
                filtered_elements.append(element)

        rows = []

        if title_tag:
            rows.append(["TITLE", title_tag])

        for element in filtered_elements:
            tag_name = element.name.upper()
            text_content = element.get_text().strip()
            rows.append([tag_name, text_content])

        df = pd.DataFrame(rows, columns=["TAG", "CONTENT"])

        return df
    except requests.exceptions.RequestException as e:
        print(f"Error fetching the URL: {e}")
        return None


if __name__ == "__main__":
    args = sys.argv
    print("0 : " + args[0])
    print("1 : " + args[1])
    print("2 : " +  args[2])

    url = 'https://indianculture.gov.in/hi/node/2730054'
    print(url)
    result_df = scrape_text_from_url(url)
    print(result_df)

    print('Snowflakeへの接続')
    # Snowflakeへの接続
    conn = snowflake.connector.connect(
        user=args[1],
        account=args[2],
        database='frosty_friday',
        schema='week123',
        authenticator='externalbrowser'
    )

    print('TABLEへの書き込み')
    # TABLEへのDataFrameの書き込み
    success, nchunks, nrows, output = write_pandas(
        conn=conn,
        df=result_df,
        table_name='WEEK123_SCRAPE_FROM_INDIANCULTURE'
    )

