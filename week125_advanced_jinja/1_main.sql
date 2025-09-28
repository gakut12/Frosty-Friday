EXECUTE IMMEDIATE FROM @week125_stage/1_utils.sql
    USING (number_of_array=>'[1,2,3,4]');