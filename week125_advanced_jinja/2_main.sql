{% from "2_utils.sql" import power_of_two %}

{% set num_list = [1, 2, 3, 4] %}

{{ power_of_two(num_list) }}