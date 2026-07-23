-- macros/render_combined_coding.sql
{% macro render_combined_coding(stg_alias, col1, col2, col3) %}
    (
        SELECT COALESCE(
            jsonb_agg(map.fhir_coding),
            -- Fallback empty or unknown coding array if none of the columns matched
            jsonb_build_array(jsonb_build_object(
                'system', 'http://example.org',
                'code', 'unknown',
                'display', 'No Mappings Found'
            ))
        )
        FROM {{ ref('concept_mappings') }} AS map
        WHERE map.local_code IN ({{ stg_alias }}.{{ col1 }}, {{ stg_alias }}.{{ col2 }}, {{ stg_alias }}.{{ col3 }})
    )
{% endmacro %}
