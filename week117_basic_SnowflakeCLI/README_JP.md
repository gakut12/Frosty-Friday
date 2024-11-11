# Week117 Basic Snowflake CLI

お題：https://frostyfriday.org/blog/2024/11/01/week-117-basic/　

1. https://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_117/frosty_nb.ipynb　をダウンロード
2. Snowflake CLI をインストールします (まだインストールしていない場合)
   1. Macの場合
      1. pip install snowflake-cli
3. ファイル経由で接続を作成しますconfig.toml（まだ作成していない場合）
   1. snow connection add
      1. ~/Library/Application Support/snowflake/config.toml
      2. ~/.snowflake というディレクトリがあれば、このディレクトリに作成される（ ~/.snowflake/config.toml ）
   2. 認証について
      1. --authenticator externalbrowser
         1. snow connection test --connection "chura" --authenticator externalbrowser
      2. ID/Password認証
      3. KeyPair認証
         1. private key fileを記載する
         2. authenticator で、SNOWFLAKE_JWT を設定する
4. ノートブックのステージを作成する
   1. snow sql --query "create stage NOTEBOOK_STAGE"
   2. or
   3. snow stage create @NOTEBOOK_STAGE
5. ファイルをステージにアップロードする
   1. snow stage copy frosty_nb.ipynb @frosty_friday.public.notebook_stage
   2. or
   3. put コマンドを使う
6. ステージ内のファイルからノートブックを作成する
   1. snow notebook create -f @frosty_friday.public.notebook_stage/frosty_nb.ipynb FROSTY_NOTEBOOK
   2. or
   3. make 6_create_notebook.sql and snow sql --filename 6_create_notebook.sql
7. CLIからノートブックを開く
   1. snow notebook open FROSTY_NOTEBOOK
8. ノートブックを実行する
    1. ブラウザが開くので、そこで Run allを実行
