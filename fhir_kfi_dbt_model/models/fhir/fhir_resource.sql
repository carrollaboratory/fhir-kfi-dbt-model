{{ config(materialized='table') }} -- Or 'incremental' if your data volume is large

SELECT
    id,
    resource_type,
    access_policy_id,
    resource FROM {{ ref('fhir_consent') }}
