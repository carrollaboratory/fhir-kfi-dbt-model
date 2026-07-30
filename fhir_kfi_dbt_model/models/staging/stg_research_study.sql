-- models/staging/stg_research_study.sql
-- Stage 1: INCLUDE Access Model → ResearchStudy staging (parent)
-- FHIR R4 target resource: ResearchStudy
-- LinkML source class: Study (common-access-model)

{% set meta_extensions = config.meta_get('include', {}) %}
{% set system_prefix = meta_extensions.get('system_prefix') %}
{% set global_id_prefix = meta_extensions.get('global_id_prefix') %}

with source as (
  select * from {{ source('dev_include_access', 'study') }}
),

renamed as (
  select

    -- ── Identity / Key columns ────────────────────────────────────────────────
    source.study_id::text as id,
    source.study_id::text as study_id,
    -- Join key for all sibling staging models below.

    -- Identifier system strings, computed from model's meta config rather
    -- than a source column.
    '{{ global_id_prefix }}/' || source.study_id as study_id_system,
    '{{ system_prefix }}/' || source.study_short_name as study_short_name_system,
    '{{ system_prefix }}/' || source.study_code || '/researchstudy' as study_code_system,

    -- ── Scalar fields (0..1) ───────────────────────────────────────────────────
    source.study_short_name::text as short_name,
    -- FHIR: ResearchStudy.identifier[n].value (short-name system)

    source.study_code::text as study_code,
    -- FHIR: ResearchStudy.identifier[n].value (study-code system)

    source.access_policy_id::text as access_policy_id,
    -- Join key to stg_consent.access_policy_id (cross-resource reference).

    source.study_title::text as title,
    -- FHIR: ResearchStudy.title

    source.parent_study::text as part_of,
    -- FHIR: ResearchStudy.partOf

    source.acknowledgments::text as acknowledgments,
    -- FHIR: extension url TODO (acknowledgments extension)

    source.website::text as website,
    -- FHIR: extension url TODO (website extension)

    source.study_description::text as description,
    -- FHIR: ResearchStudy.description

    source.citation_statement::text as citation_statement,
    -- FHIR: extension url TODO (citation-statement extension)

    'completed'::text as status,

    source.do_id::text as do_id,
    -- Join key to stg_doi.do_id.


    -- ── Metadata ──────────────────────────────────────────────────────────────
    'include'::text as _source_system,
    current_timestamp as meta_last_updated

  from source
)

select * from renamed
