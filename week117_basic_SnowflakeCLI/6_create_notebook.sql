CREATE NOTEBOOK FROSTY_NOTEBOOK_FROM_FILE
 FROM '@frosty_friday.public.notebook_stage'
 MAIN_FILE = 'frosty_nb.ipynb'
 QUERY_WAREHOUSE = GAKU_WH;
