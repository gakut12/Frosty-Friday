from snowflake.snowpark import Session
from snowflake.snowpark.functions import col
from snowflake.ml.modeling.tree import DecisionTreeRegressor
from snowflake.ml.modeling.pipeline import Pipeline

# セッションの作成
session = Session.builder.config("connection_name", "myconnection").create()

week59_df = session.table("WEEK59").select(
    col('"age"').alias('AGE'),
    col('"monthly_income"').alias('MONTHLY_INCOME')
)

X = ["AGE"]
y   = "MONTHLY_INCOME"

pipeline = Pipeline(steps=[
    (
        "dtr",
        DecisionTreeRegressor(
            input_cols   = X,
            label_cols   = [y],
            output_cols  = ["PREDICTED_INCOME"]
        )
    ),
])

pipeline.fit(week59_df)
pipeline.predict(week59_df).show()
