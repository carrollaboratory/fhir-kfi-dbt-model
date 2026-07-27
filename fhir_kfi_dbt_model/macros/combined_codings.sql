-- macros/render_combined_coding.sql
{% macro render_combined_coding(stg_alias, col1, col2, col3) %}
(
  SELECT COALESCE(
    (SELECT jsonb_agg(fhir_coding) FROM {{ ref('concept_mappings') }} WHERE local_code = {{ stg_alias }}.{{ col1 }}),
    jsonb_build_array()
  ) ||
  COALESCE(
    (SELECT jsonb_agg(fhir_coding) FROM {{ ref('concept_mappings') }} WHERE local_code = {{ stg_alias }}.{{ col2 }}),
    jsonb_build_array()
  ) ||
  COALESCE(
    (SELECT jsonb_agg(fhir_coding) FROM {{ ref('concept_mappings') }} WHERE local_code = {{ stg_alias }}.{{ col3 }}),
    jsonb_build_array()
  )
)
{% endmacro %}
