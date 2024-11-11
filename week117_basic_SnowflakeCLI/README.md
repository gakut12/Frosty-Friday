# Week117 Basic Snowflake CLI

https://frostyfriday.org/blog/2024/11/01/week-117-basic/　

1. Download the following notebook from S3
   1. url : https://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_117/frosty_nb.ipynb
2. Install the Snowflake CLI (if you haven’t already)
   1. if mac : pip install snowflake-cli
3. Create a connection via a config.toml file (if you haven’t already)
   1. snow connection add
      1. file output to : ~/.snowflake/config.toml ( if exists ~/.snowflake directory)
      2. or file output to : ~/Library/Application Support/snowflake/config.toml
   2. if federation SSO authenticator : --authenticator externalbrowser
   3. if key-pair authenticator : --authenticator snowflake_jwt and set private key file path
4. Create a stage for the notebook
   1. use "snow sql"
      1. snow sql --query "create stage NOTEBOOK_STAGE"
   2. use snow command
      1. snow stage create @NOTEBOOK_STAGE
5. Upload the file to the stage
   1. use snow command
      1. snow stage copy frosty_nb.ipynb @frosty_friday.public.notebook_stage
   2. use "snow sql --query"
      1. put command
6. Create a notebook from the file in the stage
   1. use command 
      1. snow notebook create -f @frosty_friday.public.notebook_stage/frosty_nb.ipynb FROSTY_NOTEBOOK
   2. use sql
      1. make sql file :
         1. 6_create_notebook.sql
         2. snow sql --filename 6_create_notebook.sql
7. Open the notebook from the CLI
   1. snow notebook open FROSTY_NOTEBOOK
8. Run the notebook
   1. open browser and click Run all
