with research_study as (
  select * from {{ source('dev_include_access', 'study') }}
),

external_ids as (
  select * from {{ source('dev_include_access', 'study_external_id') }}
),

study_principal_investigators as (
  select *
  from {{ source('dev_include_access', 'study_principal_investigator') }}
),

investigators as (
  select * from {{ source('dev_include_access', 'investigator') }}
),

study_contact as (
  select * from {{ source('dev_include_access', 'study_contact') }}
),

doi as (
  select * from {{ source('dev_include_access', 'doi') }}
),

doi_exts as (
  select * from {{ source('dev_include_access', 'doi_external_id') }}
),

study_publication as (
  select * from {{ source('dev_include_access', 'study_publication') }}
),

publication as (
  select * from {{ source('dev_include_access', 'publication') }}
),

pub_exts as (
  select * from {{ source('dev_include_access', 'publication_external_id') }}
),

programs as (
    select * from {{ source('dev_include_access', 'study_program') }}
),

joined_source as (
  select
    rs.study_id,
    rs.study_short_name,
    rs.study_code,
    rs.access_policy_id,
    rs.study_title,
    rs.parent_study,
    rs.acknowledgments,
    rs.website,
    rs.study_description,
    rs.citation_statement,
    rs.do_id,

    coalesce(
      jsonb_agg(distinct ext.external_id) filter (
        where ext.external_id is not null
      ),
      '[]'::jsonb
    ) as external_ids,

    coalesce(
      jsonb_agg(distinct to_jsonb(inv)) filter (where inv.id is not null),
      '[]'::jsonb
    ) as investigators,

    coalesce(
      jsonb_agg(distinct to_jsonb(contacts)) filter (
        where contacts.id is not null
      ),
      '[]'::jsonb
    ) as contacts,

    -- I'm carrying this along, just in case we need it down the line. If we
    -- do, this will probably change the doi to be inside a jsonb object
    coalesce(
      jsonb_agg(distinct to_jsonb(doi_exts)) filter (
        where doi_exts."DOI_do_id" is not null
      ),
      '[]'::jsonb
    ) as doi_exts,

    coalesce(
      jsonb_agg(distinct to_jsonb(pub)) filter (where pub.id is not null),
      '[]'::jsonb
    ) as pub,

    coalesce(
      jsonb_agg(distinct to_jsonb(st_pub)) filter (
        where st_pub.publication_id is not null
      ),
      '[]'::jsonb
    ) as st_pub,

    coalesce(
      jsonb_agg(distinct to_jsonb(pub_exts)) filter (
        where pub_exts.external_id is not null
      ),
      '[]'::jsonb
    ) as pub_exts,

    coalesce(
      jsonb_agg(distinct to_jsonb(programs)) filter (
        where programs.program is not null
      ),
      '[]'::jsonb
    ) as programs

  from research_study as rs
  left join external_ids as ext
    on rs.study_id = ext."Study_study_id"
  left join study_principal_investigators as spi
    on rs.study_id = spi."Study_study_id"
  left join investigators as inv
    on spi.principal_investigator_id = inv.id
  left join study_contact as sc
    on rs.study_id = sc."Study_study_id"
  left join investigators as contacts
    on sc.contact_id = contacts.id
  left join doi
    on rs.do_id = doi.do_id
  left join doi_exts
    on doi.do_id = doi_exts."DOI_do_id"
  left join study_publication as st_pub
    on rs.study_id = st_pub."Study_study_id"
  left join publication as pub
    on st_pub.publication_id = pub.id
  left join pub_exts
    on pub.id = pub_exts."Publication_id"
  left join programs
    on programs."Study_study_id" = rs.study_id

  group by
    rs.study_id,
    rs.study_short_name,
    rs.study_code,
    rs.access_policy_id,
    rs.study_title,
    rs.parent_study,
    rs.study_description,
    rs.do_id,
    rs.citation_statement,
    rs.website,
    rs.acknowledgments
)

select
  joined_source.study_id::text as id,
  joined_source.do_id::text as do_id,
  joined_source.study_short_name::text as short_name, -- identifiers[]
  joined_source.study_code::text as study_code, -- identifiers[]??
  joined_source.acknowledgments::text as acknowledgments,
  joined_source.website::text as website,
  joined_source.investigators,
  joined_source.contacts,
  joined_source.pub as publications,
  joined_source.external_ids,
  joined_source.access_policy_id::text as access_policy_id,
  joined_source.study_title::text as title,
  joined_source.parent_study::text as part_of,
  joined_source.citation_statement::text as citation_statement,
  joined_source.study_description::text as description
from joined_source
