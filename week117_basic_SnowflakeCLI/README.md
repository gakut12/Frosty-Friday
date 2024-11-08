# Week117 Basic Snowflake CLI

お題：https://frostyfriday.org/blog/2024/11/01/week-117-basic/　

1. http://s3//frostyfridaychallenges/challenge_117/frosty_nb.ipynb（http://s3//frostyfridaychallenges/challenge_117/frosty_nb.ipynb の実体）　をダウンロード
2. Snowflake CLI をインストールします (まだインストールしていない場合)
   1. Macの場合
      1. pip install snowflake-cli
3. ファイル経由で接続を作成しますconfig.toml（まだ作成していない場合）
   1. snow connection add
      1. →　　/Users/<user_name>/Library/Application Support/snowflake/config.toml に記載される
   2. 認証について
      1.--authenticator externalbrowser はうまく動かない（Errorになる、ブラウザ起動されない）
         1. snow connection test --connection "chura" --authenticator externalbrowser
      1. Key−Pairかid/passwordを使う必要ある
4. ノートブックのステージを作成する
5. ファイルをステージにアップロードする
6. ステージ内のファイルからノートブックを作成する
7. CLIからノートブックを開く
8. ノートブックを実行する

