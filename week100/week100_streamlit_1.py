# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session
import cv2
import numpy as np
import io

# こちらの解法は、sqlを記載する方法

# Write directly to the app
st.title("Frosty Friday Week100 App :balloon:")

# Get the current credentials
session = get_active_session()

sql_get_filenames = f"select file_name from public.week100_tbl";
data_filenames = session.sql(sql_get_filenames).collect()

file_name = st.radio("file_name",data_filenames)

sql = f"select file_name, image_bytes from public.week100_tbl where file_name = '{file_name}'"
df = session.sql(sql).collect()
st.dataframe(df, use_container_width=True)

hex_string = str(df[0]['IMAGE_BYTES'])
image_bytes = bytes.fromhex(hex_string)
# バイト列から画像をデコードする
img = cv2.imdecode(np.frombuffer(image_bytes, np.uint8), cv2.IMREAD_COLOR)

# 画像を表示する
# BGR チャンネルで表示（一般的な画像フォーマットはRGBであるため）
st.image(img, channels="BGR") 
