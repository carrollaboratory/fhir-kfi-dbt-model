-- models/fhir/fhir_researchstudy.sql
-- Stage 2: research_study staging → FHIR R4 ResearchStudy JSON
-- FHIR R4 resource type: ResearchStudy
-- Source models: stg_research_study, stg_research_study_external_id
--
-- Each row is one FHIR ResearchStudy resource representing an INCLUDE Study.
-- The resource column contains the complete FHIR R4 ResearchStudy JSON as jsonb.
--
-- identifier[] assembly:
--   Every candidate identifier (global study id, study code, each external id)
--   is unioned into one identifier_rows CTE at row grain, filtered for a
--   non-null value BEFORE it's ever built into a jsonb object. That's what
--   keeps a null study_code from producing a half-empty {"system": "..."}
--   entry in the array -- jsonb_strip_nulls only strips null keys out of an
--   object, it won't remove the object itself from the array.
--
-- NOTE: assumes stg_research_study_external_id has been extended with a
-- system_prefix column built the same way as study_id_system /
-- study_code_system on stg_research_study (i.e. computed from the
-- dbt_project.yml meta config, not a raw source column).

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
    status,
    website,
    access_policy_id,
    title,
    part_of,
    citation_statement,
    description,
    study_short_name_system,
    study_id_system,
    study_code_system
  from {{ ref('stg_research_study') }}

),

-- One row per candidate identifier, from every source that can contribute
-- one. Add a new union arm here any time a new identifier source shows up --
-- the filtering and aggregation below don't need to change.
identifier_rows as (

    select
        id as study_id,
        study_id_system as system,
        id as value
    from staged
    where id is not null

    union all

    select
        id as study_id,
        study_code_system as system,
        study_code as value
    from staged
    where study_code is not null

    union all

    select
        study_id,
        system_prefix as system,
        external_id as value
    from {{ ref('stg_research_study_external_id') }}
    where external_id is not null

),

identifiers_agg as (

    select
        study_id,
        jsonb_agg(
            jsonb_build_object('system', system, 'value', value)
            order by system, value
        ) as identifiers
    from identifier_rows
    group by study_id

),

built as (
    select
        -- ── Search / key columns ──────────────────────────────────────────────────
        stg.id::text as id,
        'ResearchStudy'::text as resource_type,
        stg.access_policy_id::text as access_policy_id,

        -- ── FHIR resource ─────────────────────────────────────────────────────────
        jsonb_strip_nulls(
            jsonb_build_object(
                'resourceType', 'ResearchStudy',
                'id', stg.id,
                'meta', jsonb_build_object(
                    'profile', jsonb_build_array( '{{ model.config.meta.profiles.research_study }}' )
                ),
                'identifier', coalesce(ia.identifiers, '[]'::jsonb),
                'status', stg.status
            )
        ) as resource

    from staged as stg
    left join identifiers_agg as ia
        on stg.id = ia.study_id
)

select
    id,
    resource_type,
    access_policy_id,
    resource
from built
