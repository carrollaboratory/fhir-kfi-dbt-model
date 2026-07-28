{{ config(materialized='ephemeral') }}

SELECT
  local_code,
  -- This converts the columns directly into the FHIR coding JSON structure
  jsonb_build_object(
    'system', code_system,
    'code', code,
    'display', display
  ) AS fhir_coding
FROM {{ ref('harmony') }}
