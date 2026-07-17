-- models/staging/stg_consent.sql
-- Stage 1: INCLUDE Access Model → Consent staging
-- FHIR R4 target resource: Consent
-- LinkML source class: AccessPolicy (common-access-model)
--
-- One row per AccessPolicy record. All columns that could feed any element of the
-- FHIR Consent resource are present here as plain scalar columns. No FHIR JSON is
-- built at this stage.
--
-- Open questions / TODOs:
--   - Confirm actual table name with data team (currently assumes tgt_access_model_AccessPolicy)
--   - data_use_modifier is conceptually multivalued per DUO design; see NOTE below
--   - disease_limitation is free text; a future schema version may provide a structured code

with source as (
    select * from {{ source('dev_include_access', 'access_policy') }}
),

renamed as (
    select

        -- ── Identity / Key columns ────────────────────────────────────────────────
        source.access_policy_id::text as id,
        -- FHIR: Consent.id
        -- Dewrangle Global ID; minted before data lands in the access model.

        source.access_policy_id::text as access_policy_id,
        -- FHIR key column (equals id for this model; present on all FHIR models for
        -- cross-resource join support).

        -- ── Access accession (optional) ──────────────────────────────────────────
        source.data_use_accession::text as data_use_accession,
        -- FHIR: Consent.identifier[0].value
        -- A dbGaP phsID or other URI/CURIE identifying the controlled-access portal
        -- entry for this policy.

        -- ── DUO data use permission (required) ───────────────────────────────────
        source.data_use_permission::text as data_use_permission,
        -- FHIR: Consent.provision.purpose[0].code
        -- DUO term CURIE, e.g. "DUO:0000007" (disease-specific research use).
        -- System: http://purl.obolibrary.org/obo/duo.owl

        -- ── DUO data use modifier (optional) ─────────────────────────────────────
        -- NOTE: The LinkML slot data_use_modifier on AccessPolicy is not marked
        --   multivalued: true in the schema, but DUO modifiers are inherently multivalued
        --   (e.g. a policy may carry both IRB (DUO:0000045) and MOR (DUO:0000034)).
        --   Full support requires a junction table:
        --     tgt_access_model_AccessPolicy_data_use_modifier (access_policy_id, data_use_modifier)
        --   and a lateral join + jsonb_agg in the FHIR model to build purpose[1..n].
        --   This model handles the single-modifier case only.
        source.data_use_modifier::text as data_use_modifier,
        -- FHIR: Consent.provision.purpose[1].code  (when present)
        -- DUO modifier CURIE, e.g. "DUO:0000045" (IRB approval required).

        -- ── Disease limitation (optional free text) ───────────────────────────────
        -- NOTE: In DUO, disease-specific restrictions are expressed by combining
        --   DUO:0000007 (disease-specific research use) with a structured disease code
        --   annotation (Mondo, OMIM, etc.). The current schema stores only a free-text
        --   string. If structured disease codes are made available in a future schema
        --   version, this column should be replaced with:
        --     disease_limitation_curie  text   (Mondo/OMIM CURIE)
        --     disease_limitation_display text  (human-readable label)
        --   and mapped to a coded Consent extension or provision.condition element.
        source.disease_limitation::text as disease_limitation,
        -- FHIR: extension url TODO (disease-limitation extension)

        -- ── Access description (optional) ─────────────────────────────────────────
        source.access_description::text as access_description,
        -- FHIR: extension url TODO (access-description extension)

        -- ── Website (optional) ────────────────────────────────────────────────────
        source.website::text as website,
        -- FHIR: extension url TODO (website extension)

        -- ── Metadata ──────────────────────────────────────────────────────────────
        'include'::text as _source_system,
        current_timestamp as meta_last_updated

    from source

)

select * from renamed
