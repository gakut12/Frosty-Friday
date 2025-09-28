-- 引数が数値のリスト、その数値の2乗を返す
{%- macro power_of_two(num_list) -%}
  {%- for num in num_list -%}
    {{ 'select ' + num|string + ' as original_number, ' + (num*num)|string + ' as squared ' }}
    {% if not loop.last %}
      {{ ' union all ' }}
    {%- endif -%}    
  {% endfor %}
{%- endmacro -%}