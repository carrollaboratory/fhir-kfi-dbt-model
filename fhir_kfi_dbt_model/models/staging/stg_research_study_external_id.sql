-- models/staging/stg_research_study_external_id.sql
-- Stage 1: INCLUDE Access Model → ResearchStudy staging (child)
-- FHIR R4 target: ResearchStudy.identifier[n]
-- LinkML source: Study.external_id (multivalued)
--
-- One row per (study_id, external_id) pair, matching source grain. No
-- aggregation here — array-building into ResearchStudy.identifier[] happens
-- in an intermediate model alongside the id/short_name/study_code identifiers
-- already carried on stg_research_study.

with source as (
  select * from {{ source('dev_include_access', 'study_external_id') }}
),
fhir_systems as (
    select
        trim(lower(curie_prefix)) as curie_prefix,
        fhir_system
    from {{ ref('prefix_fhir_systems') }}
),
renamed as (
  select

    source."Study_study_id"::text as study_id,
    -- Join key back to stg_research_study.study_id.

    source.external_id::text as external_id,
    -- FHIR: ResearchStudy.identifier[n].value

    'include'::text as _source_system,
    current_timestamp as meta_last_updated,
    {{ extract_curie_prefix('source.external_id') }} as extracted_prefix

  from source
),

final as (
    select
        r.study_id,
        r.external_id,
        r._source_system,
        r.meta_last_updated,
        f.fhir_system as system_prefix
    from renamed r
    left join fhir_systems f
        on r.extracted_prefix = f.curie_prefix
)

select * from final
