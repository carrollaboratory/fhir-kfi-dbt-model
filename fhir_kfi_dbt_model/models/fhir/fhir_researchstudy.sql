-- models/fhir/fhir_researchstudy.sql
-- Stage 2: research_study staging → FHIR R4 ResearchStudy JSON
-- FHIR R4 resource type: ResearchStudy
-- Source model: stg_research_study
--
-- Each row is one FHIR ResearchStudy resource representing an INCLUDE Study.
-- The resource column contains the complete FHIR R4 ResearchStudy JSON as jsonb.


{{ config(materialized='ephemeral') }}

{% set meta_extensions = model.meta.get('extensions', {}) %}
{% set study_design_url = meta_extensions.get('study_design') %}
{% set study_associated_party_url = meta_extensions.get('study_associated_party') %}
{% set research_study_acknowledgement_url = meta_extensions.get('research_study_acknowledgement') %}


with staged as (

  select
    id,
    do_id,
    short_name,
    study_code,
    investigators,
    contacts,
    publications,
    website,
    external_ids,
    access_policy_id,
    title,
    part_of,
    citation_statement,
    description
    from {{ ref('stg_consent') }}
),


built as (
    select
        -- ── Search / key columns ──────────────────────────────────────────────────
        id::text as id,
        'ResearchStudy'::text as resource_type,
        access_policy_id::text as access_policy_id,

        -- ── FHIR resource ─────────────────────────────────────────────────────────
        jsonb_strip_nulls(
            jsonb_build_object(
                'resourceType', 'ResearchStudy',
                'id', id,
                'meta', jsonb_build_object(
                    'profile', jsonb_build_array( '{{ model.config.meta.profiles.research_study }}' )
                )
            )
        ) as resource
    from staged as stg
)

select
    id,
    resource_type,
    access_policy_id,
    resource
from built
