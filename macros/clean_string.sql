{% macro clean_string(column_name) %}
    {#-
        Standardizes a string column:
        - Trims whitespace
        - Converts to lowercase
        - Replaces multiple spaces with single space

        Usage: {{ clean_string('customer_city') }}
    -#}
    lower(trim(regexp_replace({{ column_name }}, '\s+', ' ')))
{%- endmacro %}
