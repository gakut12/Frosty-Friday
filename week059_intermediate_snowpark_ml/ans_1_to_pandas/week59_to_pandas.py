from snowflake.snowpark import Session
import pandas as pd
from sklearn.tree import DecisionTreeClassifier

# セッションの作成
session = Session.builder.config("connection_name", "myconnection").create()

# CSVの読み込み（ローカル）
csv_path = '../age_and_income.csv'
df = pd.read_csv(csv_path)

# テーブルとして登録
session.write_pandas(df, "WEEK59", auto_create_table=True, overwrite=True)

# Load table
week59 = session.table('WEEK59').to_pandas()

# 特徴量とターゲットに分割
X = week59[['age']]
y = week59['monthly_income']

# Initialize the DecisionTreeClassifier with column names
model = DecisionTreeClassifier(random_state=42)

# Fit the model to the data
model.fit(X, y)

# Make predictions
week59['predited_purchase'] = model.predict(X)

# Display the predictions
print(week59)
