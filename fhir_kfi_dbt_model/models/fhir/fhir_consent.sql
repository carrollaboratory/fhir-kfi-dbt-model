-- models/fhir/fhir_consent.sql
-- Stage 2: Consent staging → FHIR R4 Consent JSON
-- FHIR R4 resource type: Consent
-- Source model: stg_consent
--
-- The following Access Policy fields remain unclear in how they should be
-- used in FHIR
--  data_use_accession - This doesn't really seem like an identifier
--
-- Each row is one FHIR Consent resource representing an INCLUDE Access Policy.
-- The resource column contains the complete FHIR R4 Consent JSON as jsonb.
--
-- TODO: confirm IG Consent profile canonical URL with IG team; replace all
--       'TODO: profile URL' and 'TODO: ig-extension-url/...' placeholders.
-- TODO: confirm DUO system URI (http://purl.obolibrary.org/obo/duo.owl is standard;
--       verify against NCPI IG2 Consent profile).
-- TODO: confirm accession identifier system URI (varies: dbGaP, etc.).

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

built as (
    select
        -- ── Search / key columns ──────────────────────────────────────────────────
        id::text as id,
        'Consent'::text as resource_type,
        access_policy_id::text as access_policy_id,

        -- ── FHIR resource ─────────────────────────────────────────────────────────
        jsonb_strip_nulls(
            jsonb_build_object(
                'resourceType', 'Consent',
                'id', id,
                'meta', jsonb_build_object(
                    'lastUpdated', to_char( meta_last_updated, 'YYYY-MM-DD"T"HH24:MI:SS"Z"' ),
                    'profile', jsonb_build_array( '{{ model.config.meta.profiles.consent }}' )
                ),
                'status', 'active',
                'scope', '{ "coding": [ { "system": "http://hl7.org/fhir/ValueSet/consent-scope", "code": "research", "display": "Research" } ] }'::jsonb,
                'category', '[ { "coding" : [ { "system" : "http://terminology.hl7.org/CodeSystem/consentcategorycodes", "code" : "research", "display" : "Research Information Access" } ] } ]'::jsonb,

                'provision', jsonb_build_object(
                    'type', 'permit',
                    'purpose', (
                        jsonb_build_array(
                            jsonb_build_object(
                                'coding', {{ render_combined_coding('stg', 'data_use_permission', 'data_use_modifier', 'disease_limitation') }}
                            )
                        )
                    )
                ),

                'extension', (
                    (case when access_description is not null then
                        jsonb_build_array(
                            jsonb_build_object( 'url', '{{ description_url }}', 'valueMarkdown', access_description )
                        )
                     else '[]'::jsonb end)
                    ||
                    (case when website is not null then
                        jsonb_build_array(
                            jsonb_build_object( 'url', '{{ website_url }}', 'valueUrl', website )
                        )
                     else '[]'::jsonb end)
                )
            )
        ) as resource

    from staged AS stg
    left join {{ ref('concept_mappings') }} as map
        on stg.data_use_permission = map.local_code
)

select * from built
