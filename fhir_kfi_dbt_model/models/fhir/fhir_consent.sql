-- models/fhir/fhir_consent.sql
-- Stage 2: Consent staging → FHIR R4 Consent JSON
-- FHIR R4 resource type: Consent
-- Source model: stg_consent
--
-- Each row is one FHIR Consent resource representing an INCLUDE Access Policy.
-- The resource column contains the complete FHIR R4 Consent JSON as jsonb.
--
-- Note: data_use_permission / data_use_modifier are intentionally scalar
-- (0..1) fields on stg_consent, not a multivalued relationship -- see
-- stg_consent.sql. No join or aggregation needed for them here; they're
-- combined into provision.purpose via render_combined_coding() below.

{{ config(materialized='ephemeral') }}

{% set meta_extensions = model.meta.get('extensions', {}) %}
{% set description_url = meta_extensions.get('description') %}
{% set website_url = meta_extensions.get('website') %}


with staged as (

  select
    id,
    access_policy_id,
    data_use_accession,
    data_use_permission,
    data_use_modifier,
    disease_limitation,
    access_description,
    website,
    meta_last_updated
  from {{ ref('stg_consent') }}

),

-- One row per candidate extension, filtered to non-null BEFORE it's built
-- into a jsonb object -- same pattern as identifier_rows in
-- fhir_researchstudy.sql. Add a union arm here for each new extension
-- instead of nesting another CASE/|| in the built object below.
extension_rows as (

    select
        id as resource_id,
        '{{ description_url }}'::text as url,
        jsonb_build_object('valueMarkdown', access_description) as value_obj
    from staged
    where access_description is not null

    union all

    select
        id as resource_id,
        '{{ website_url }}'::text as url,
        jsonb_build_object('valueUrl', website) as value_obj
    from staged
    where website is not null

),

extensions_agg as (

    select
        resource_id,
        jsonb_agg(
            jsonb_build_object('url', url) || value_obj
            order by url
        ) as extensions
    from extension_rows
    group by resource_id

),

built as (
  select
    -- ── Search / key columns ──────────────────────────────────────────────────
    stg.id::text as id,
    'Consent'::text as resource_type,
    stg.access_policy_id::text as access_policy_id,

    -- ── FHIR resource ─────────────────────────────────────────────────────────
    jsonb_strip_nulls(
      jsonb_build_object(
        'resourceType', 'Consent',
        'id', stg.id,
        'meta', jsonb_build_object(
          'lastUpdated', to_char( stg.meta_last_updated, 'YYYY-MM-DD"T"HH24:MI:SS"Z"' ),
          'profile', jsonb_build_array( '{{ model.config.meta.profiles.consent }}' )
        ),
        'status', 'active',
        'scope', '{ "coding": [ { "system": "http://hl7.org/fhir/ValueSet/consent-scope", "code": "research", "display": "Research" } ] }'::jsonb,
        'category', '[ { "coding" : [ { "system" : "http://terminology.hl7.org/CodeSystem/consentcategorycodes", "code" : "research", "display" : "Research Information Access" } ] } ]'::jsonb,

        'provision', jsonb_build_object(
          'type', 'permit',
          'purpose', (
            {{ render_combined_coding('stg', 'data_use_permission', 'data_use_modifier', 'disease_limitation') }}
          )
        ),

        'extension', coalesce(ext.extensions, '[]'::jsonb)
      )
    ) as resource

  from staged as stg
  left join extensions_agg as ext
    on stg.id = ext.resource_id
)

select
  id,
  resource_type,
  access_policy_id,
  resource
from built
