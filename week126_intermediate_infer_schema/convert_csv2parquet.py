import pandas as pd

# ① CSVファイルを読み込む
df = pd.read_csv("customers_orders_ff.csv")

# ② Parquetファイルとして出力する
df.to_parquet("customers_orders_ff.parquet", index=False)

print("Parquet ファイルを出力しました！")