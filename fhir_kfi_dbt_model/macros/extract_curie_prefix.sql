{% macro extract_curie_prefix(column_name) %}
    case
        -- Ensure the string is populated and actually contains a colon separator
        when {{ column_name }} is not null and {{ column_name }} like '%:%'
        then trim(lower(split_part({{ column_name }}, ':', 1)))
        else null
    end
{% endmacro %}
