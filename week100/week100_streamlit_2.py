# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session
# Snowsight（Streamlit in Snowflake）から package に opencv-python-headless を入れる
import cv2 
import numpy as np

# こちらの解法は、pandas.dataframeの関数で操作を行う
# あまりPythonicな書き方ではないかもしれない。キャッシュの利用もしていない

# Write directly to the app
# アプリのタイトルを入れる
st.title("Frosty Friday Week100 App :balloon:")

# Get the current credentials
# セッションの取得
session = get_active_session()

df_table = session.table("week100_tbl").to_pandas()
st.dataframe(df_table, use_container_width=True)

# チェックボックスで、どのファイルの画像を出力するかを選択する
file_name = st.radio("file_name",df_table.loc[:, 'FILE_NAME'])

# テーブルから該当のFILENAMEの画像情報を取得する
target_df = df_table.query("FILE_NAME==@file_name",engine="python")
image_bytes = bytes.fromhex(str(target_df['IMAGE_BYTES'].iloc[0]))

# バイト列から画像をデコードする
img = cv2.imdecode(np.frombuffer(image_bytes, np.uint8), cv2.IMREAD_COLOR)

# 画像を表示する
# BGR チャンネルで表示（一般的な画像フォーマットはRGBであるため）
st.image(img, channels="BGR") 
