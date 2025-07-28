# 作業ログ

``` sh
cd $(FROSTY_FRIDAY_GIT_REPOSITORY_HOME)/week062_intermediate_native_apps/
snow init --template app_basic week062
snow init --help
```

init のテンプレートは
https://github.com/snowflakedb/snowflake-cli-templates
にある。

``` sh
snow app run -c chura2_connection
snow sql -q "call hello_snowflake_app.core.hello()" -c chura2_connection
```

mkdir streamlit
snow app run -c chura2_connection

## アプリにバージョンを追加する

snow app version create v1_0 -c chura2_connection
snow app version list -c chura2_connection
snow app run --version V1_0 -c chura2_connection
