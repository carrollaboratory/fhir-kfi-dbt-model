-- models/fhir/fhir_consent.sql
-- Stage 2: Consent staging → FHIR R4 Consent JSON
-- FHIR R4 resource type: Consent
-- Source model: stg_consent
--
-- Each row is one FHIR Consent resource representing an INCLUDE Access Policy.
-- The resource column contains the complete FHIR R4 Consent JSON as jsonb.
--
-- TODO: confirm IG Consent profile canonical URL with IG team; replace all
--       'TODO: profile URL' and 'TODO: ig-extension-url/...' placeholders.
-- TODO: confirm DUO system URI (http://purl.obolibrary.org/obo/duo.owl is standard;
--       verify against NCPI IG2 Consent profile).
-- TODO: confirm accession identifier system URI (varies: dbGaP, etc.).
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
    (
      jsonb_build_object(
        'resourceType', 'Consent',
        'id', id,
        'meta', jsonb_build_object(
          'lastUpdated', to_char( meta_last_updated, 'YYYY-MM-DD"T"HH24:MI:SS"Z"' ),
          'profile', jsonb_build_array(
            '{{ model.config.meta.profiles.consent }}'
          )
        ),
        'status', 'active',
        'scope', '{
          "coding": [
            {
                "system": "http://hl7.org/fhir/ValueSet/consent-scope",
                "code": "research",
                "display": "Research"
            }
          ]
        }'::jsonb,
        'category', '[
          {
            "coding" : [
              {
                "system" : "http://terminology.hl7.org/CodeSystem/consentcategorycodes",
                "code" : "research",
                "display" : "Research Information Access"
              }
            ]
          }
        ]'::jsonb,
        -- Inline Purpose Array Creation
        'provision', jsonb_build_object(
          'type', 'permit',
          'purpose', (
            jsonb_build_array(
              jsonb_build_object(
              'coding', {{ render_combined_coding('stg', 'data_use_permission', 'data_use_modifier', 'disease_limitation') }}
              )
            )
            || case
              when data_use_modifier is not null
                then jsonb_build_array(
                  jsonb_build_object(
                    'system', 'http://obolibrary.org',
                    'code', data_use_modifier
                  )
                )
              else '[]'::jsonb
            end
          )
        )
      )

      -- ── Optional: identifier (data_use_accession) ─────────────────────────
      || case
        when data_use_accession is not null
          then jsonb_build_object(
            'identifier', jsonb_build_array(
              jsonb_build_object(
                'system', 'TODO: accession system URI',
                'value', data_use_accession
              )
            )
          )
        else '{}'::jsonb
      end

      -- ── Optional: top-level extensions ────────────────────────────────────
      || case
        when (disease_limitation is not null or access_description is not null or website is not null)
          then jsonb_build_object(
            'extension', (
              case when disease_limitation is not null then jsonb_build_array(jsonb_build_object('url', 'TODO: ig-extension-url/disease-limitation', 'valueString', disease_limitation)) else '[]'::jsonb end ||
              case when access_description is not null then jsonb_build_array(jsonb_build_object('url', 'TODO: ig-extension-url/access-description', 'valueString', access_description)) else '[]'::jsonb end ||
              case when website is not null then jsonb_build_array(jsonb_build_object('url', 'TODO: ig-extension-url/website', 'valueUri', website)) else '[]'::jsonb end
            )
          )
        else '{}'::jsonb
      end
    ) as resource

  from staged AS stg
  left join {{ ref('concept_mappings') }} as map
    on stg.data_use_permission = map.local_code

)

select * from built
