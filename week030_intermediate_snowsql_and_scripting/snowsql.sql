-- default
!set prompt_format=[user]#[warehouse]@[database].[schema]>
-- サンプル(https://docs.snowflake.com/ja/user-guide/snowsql-use#prompt-example)
!set prompt_format=[#FF0000][user].[role].[#00FF00][database].[schema].[#0000FF][warehouse]>
-- 多すぎ、とりあえず全部乗っけた
!set prompt_format=[#0000FF]([account])([role])[#000000][user]@[#00FF00][database].[#009900][schema].[#0000FF][warehouse]>
-- Snowsightでの表示を参考に
!set prompt_format=[#0000FF]([role])[#00FFFF][warehouse][#000000]@[#00FF00][database].[#009900][schema]>


-- 変数展開をSnowSQLでやるために
!define snowshell=bash
select '&snowshell' as snowshell;
!set variable_substitution=true
select '&snowshell' as snowshell;


--　フェデレーション（SSO）認証で動かす場合は、--authenticator externalbrowser
-- 認証が始まるまで、結構時間がかかりますね・・・
-- 下記は、sqlファイルを実行する方法 
-- -f : 指定のファイルを実行する
-- -o : 設定を変更する
-- -variable HOGE=geho と変数を設定して注入する

-- まずユーザとロールを作成
snowsql --authenticator externalbrowser -f week30_2_1_user_and_role.sql
-- 変数展開をtrueにして、変数を指定し、データベースオブジェクトをつくって、権限付与する
snowsql --authenticator externalbrowser -f week30_2_2.sql -o variable_substitution=true --variable database_name=ff_30_testing --variable role_name=ff_30_dev_role
-- クリーンナップ
snowsql --authenticator externalbrowser -f week30_cleanup.sql
