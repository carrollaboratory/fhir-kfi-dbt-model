CREATE TABLE dev_include_access.record (
	id SERIAL NOT NULL,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (id)
);

CREATE TABLE dev_include_access.access_policy (
	access_policy_id TEXT NOT NULL,
	data_use_accession TEXT,
	data_use_permission VARCHAR NOT NULL,
	data_use_modifier VARCHAR,
	disease_limitation TEXT,
	access_description TEXT,
	website TEXT,
	PRIMARY KEY (access_policy_id)
);

CREATE TABLE dev_include_access.concept (
	concept_curie TEXT NOT NULL,
	display TEXT,
	PRIMARY KEY (concept_curie)
);

CREATE TABLE dev_include_access.file_hash (
	id SERIAL NOT NULL,
	hash_type VARCHAR(4),
	hash_value TEXT,
	PRIMARY KEY (id)
);

CREATE TABLE dev_include_access.dataset (
	dataset_id TEXT NOT NULL,
	name TEXT,
	description TEXT,
	do_id TEXT,
	data_collection_start TEXT,
	data_collection_end TEXT,
	PRIMARY KEY (dataset_id)
);

CREATE TABLE dev_include_access.include_participant_race (
	"IncludeParticipant_subject_id" TEXT NOT NULL,
	race VARCHAR(41) NOT NULL,
	PRIMARY KEY ("IncludeParticipant_subject_id", race)
);

CREATE TABLE dev_include_access.include_participant_external_id (
	"IncludeParticipant_subject_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("IncludeParticipant_subject_id", external_id)
);

CREATE TABLE dev_include_access.record_external_id (
	"Record_id" INTEGER NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("Record_id", external_id)
);

CREATE TABLE dev_include_access.study_program (
	"Study_study_id" TEXT NOT NULL,
	program VARCHAR(7) NOT NULL,
	PRIMARY KEY ("Study_study_id", program)
);

CREATE TABLE dev_include_access.study_funding_source (
	"Study_study_id" TEXT NOT NULL,
	funding_source TEXT NOT NULL,
	PRIMARY KEY ("Study_study_id", funding_source)
);

CREATE TABLE dev_include_access.study_principal_investigator (
	"Study_study_id" TEXT NOT NULL,
	principal_investigator_id INTEGER NOT NULL,
	PRIMARY KEY ("Study_study_id", principal_investigator_id)
);

CREATE TABLE dev_include_access.study_contact (
	"Study_study_id" TEXT NOT NULL,
	contact_id INTEGER NOT NULL,
	PRIMARY KEY ("Study_study_id", contact_id)
);

CREATE TABLE dev_include_access.study_publication (
	"Study_study_id" TEXT NOT NULL,
	publication_id INTEGER NOT NULL,
	PRIMARY KEY ("Study_study_id", publication_id)
);

CREATE TABLE dev_include_access.study_external_id (
	"Study_study_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("Study_study_id", external_id)
);

CREATE TABLE dev_include_access.study_metadata_participant_lifespan_stage (
	"StudyMetadata_study_id" TEXT NOT NULL,
	participant_lifespan_stage VARCHAR(9) NOT NULL,
	PRIMARY KEY ("StudyMetadata_study_id", participant_lifespan_stage)
);

CREATE TABLE dev_include_access.study_metadata_study_design (
	"StudyMetadata_study_id" TEXT NOT NULL,
	study_design VARCHAR(23) NOT NULL,
	PRIMARY KEY ("StudyMetadata_study_id", study_design)
);

CREATE TABLE dev_include_access.study_metadata_clinical_data_source_type (
	"StudyMetadata_study_id" TEXT NOT NULL,
	clinical_data_source_type VARCHAR(31) NOT NULL,
	PRIMARY KEY ("StudyMetadata_study_id", clinical_data_source_type)
);

CREATE TABLE dev_include_access.study_metadata_data_category (
	"StudyMetadata_study_id" TEXT NOT NULL,
	data_category VARCHAR(38) NOT NULL,
	PRIMARY KEY ("StudyMetadata_study_id", data_category)
);

CREATE TABLE dev_include_access.study_metadata_research_domain (
	"StudyMetadata_study_id" TEXT NOT NULL,
	research_domain VARCHAR(32) NOT NULL,
	PRIMARY KEY ("StudyMetadata_study_id", research_domain)
);

CREATE TABLE dev_include_access.study_metadata_external_id (
	"StudyMetadata_study_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("StudyMetadata_study_id", external_id)
);

CREATE TABLE dev_include_access.virtual_biorepository_contact (
	"VirtualBiorepository_vbr_id" TEXT NOT NULL,
	contact_id INTEGER NOT NULL,
	PRIMARY KEY ("VirtualBiorepository_vbr_id", contact_id)
);

CREATE TABLE dev_include_access.virtual_biorepository_external_id (
	"VirtualBiorepository_vbr_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("VirtualBiorepository_vbr_id", external_id)
);

CREATE TABLE dev_include_access.doi_external_id (
	"DOI_do_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("DOI_do_id", external_id)
);

CREATE TABLE dev_include_access.investigator_external_id (
	"Investigator_id" INTEGER NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("Investigator_id", external_id)
);

CREATE TABLE dev_include_access.publication_external_id (
	"Publication_id" INTEGER NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("Publication_id", external_id)
);

CREATE TABLE dev_include_access.subject_external_id (
	"Subject_subject_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("Subject_subject_id", external_id)
);

CREATE TABLE dev_include_access.demographics_race (
	"Demographics_subject_id" TEXT NOT NULL,
	race VARCHAR(41) NOT NULL,
	PRIMARY KEY ("Demographics_subject_id", race)
);

CREATE TABLE dev_include_access.demographics_external_id (
	"Demographics_subject_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("Demographics_subject_id", external_id)
);

CREATE TABLE dev_include_access.family_external_id (
	"Family_family_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("Family_family_id", external_id)
);

CREATE TABLE dev_include_access.family_relationship_external_id (
	"FamilyRelationship_family_relationship_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("FamilyRelationship_family_relationship_id", external_id)
);

CREATE TABLE dev_include_access.family_member_external_id (
	"FamilyMember_id" INTEGER NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("FamilyMember_id", external_id)
);

CREATE TABLE dev_include_access.subject_assertion_concept (
	"SubjectAssertion_assertion_id" TEXT NOT NULL,
	concept_concept_curie TEXT NOT NULL,
	PRIMARY KEY ("SubjectAssertion_assertion_id", concept_concept_curie)
);

CREATE TABLE dev_include_access.subject_assertion_value_concept (
	"SubjectAssertion_assertion_id" TEXT NOT NULL,
	value_concept_concept_curie TEXT NOT NULL,
	PRIMARY KEY ("SubjectAssertion_assertion_id", value_concept_concept_curie)
);

CREATE TABLE dev_include_access.subject_assertion_external_id (
	"SubjectAssertion_assertion_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("SubjectAssertion_assertion_id", external_id)
);

CREATE TABLE dev_include_access.sample_processing (
	"Sample_sample_id" TEXT NOT NULL,
	processing TEXT NOT NULL,
	PRIMARY KEY ("Sample_sample_id", processing)
);

CREATE TABLE dev_include_access.sample_storage_method (
	"Sample_sample_id" TEXT NOT NULL,
	storage_method TEXT NOT NULL,
	PRIMARY KEY ("Sample_sample_id", storage_method)
);

CREATE TABLE dev_include_access.sample_external_id (
	"Sample_sample_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("Sample_sample_id", external_id)
);

CREATE TABLE dev_include_access.biospecimen_collection_external_id (
	"BiospecimenCollection_biospecimen_collection_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("BiospecimenCollection_biospecimen_collection_id", external_id)
);

CREATE TABLE dev_include_access.aliquot_external_id (
	"Aliquot_aliquot_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("Aliquot_aliquot_id", external_id)
);

CREATE TABLE dev_include_access.encounter_external_id (
	"Encounter_encounter_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("Encounter_encounter_id", external_id)
);

CREATE TABLE dev_include_access.encounter_definition_activity_definition_id (
	"EncounterDefinition_encounter_definition_id" TEXT NOT NULL,
	activity_definition_id_activity_definition_id TEXT NOT NULL,
	PRIMARY KEY ("EncounterDefinition_encounter_definition_id", activity_definition_id_activity_definition_id)
);

CREATE TABLE dev_include_access.encounter_definition_external_id (
	"EncounterDefinition_encounter_definition_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("EncounterDefinition_encounter_definition_id", external_id)
);

CREATE TABLE dev_include_access.activity_definition_external_id (
	"ActivityDefinition_activity_definition_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("ActivityDefinition_activity_definition_id", external_id)
);

CREATE TABLE dev_include_access.file_subject_id (
	"File_file_id" TEXT NOT NULL,
	subject_id_subject_id TEXT NOT NULL,
	PRIMARY KEY ("File_file_id", subject_id_subject_id)
);

CREATE TABLE dev_include_access.file_sample_id (
	"File_file_id" TEXT NOT NULL,
	sample_id_sample_id TEXT NOT NULL,
	PRIMARY KEY ("File_file_id", sample_id_sample_id)
);

CREATE TABLE dev_include_access.file_external_id (
	"File_file_id" TEXT NOT NULL,
	external_id TEXT NOT NULL,
	PRIMARY KEY ("File_file_id", external_id)
);

CREATE TABLE dev_include_access.dataset_file_id (
	"Dataset_dataset_id" TEXT NOT NULL,
	file_id_file_id TEXT NOT NULL,
	PRIMARY KEY ("Dataset_dataset_id", file_id_file_id)
);

CREATE TABLE dev_include_access.dataset_publication (
	"Dataset_dataset_id" TEXT NOT NULL,
	publication_id INTEGER NOT NULL,
	PRIMARY KEY ("Dataset_dataset_id", publication_id)
);

CREATE TABLE dev_include_access.study (
	parent_study TEXT,
	study_title TEXT NOT NULL,
	study_code TEXT NOT NULL,
	study_short_name TEXT,
	study_description TEXT NOT NULL,
	website TEXT,
	acknowledgments TEXT,
	citation_statement TEXT,
	do_id TEXT,
	access_policy_id TEXT,
	study_id TEXT NOT NULL,
	PRIMARY KEY (study_id)
);

CREATE TABLE dev_include_access.study_metadata (
	study_id TEXT NOT NULL,
	selection_criteria TEXT,
	vbr_id TEXT,
	expected_number_of_participants INTEGER NOT NULL,
	actual_number_of_participants INTEGER NOT NULL,
	access_policy_id TEXT,
	PRIMARY KEY (study_id)
);

CREATE TABLE dev_include_access.virtual_biorepository (
	vbr_id TEXT NOT NULL,
	name TEXT,
	institution TEXT,
	website TEXT,
	vbr_readme TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (vbr_id)
);

CREATE TABLE dev_include_access.doi (
	do_id TEXT NOT NULL,
	bibliographic_reference TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (do_id)
);

CREATE TABLE dev_include_access.investigator (
	id SERIAL NOT NULL,
	name TEXT,
	institution TEXT,
	investigator_title TEXT,
	email TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (id)
);

CREATE TABLE dev_include_access.publication (
	id SERIAL NOT NULL,
	bibliographic_reference TEXT,
	website TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (id)
);

CREATE TABLE dev_include_access.subject (
	subject_id TEXT NOT NULL,
	subject_type VARCHAR(15) NOT NULL,
	organism_type TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (subject_id)
);

CREATE TABLE dev_include_access.demographics (
	subject_id TEXT NOT NULL,
	sex VARCHAR(7) NOT NULL,
	ethnicity VARCHAR(22) NOT NULL,
	age_at_last_vital_status INTEGER,
	vital_status VARCHAR(5),
	age_at_first_engagement INTEGER,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (subject_id)
);

CREATE TABLE dev_include_access.family (
	family_id TEXT NOT NULL,
	family_type VARCHAR(12),
	family_description TEXT,
	consanguinity VARCHAR(13),
	family_study_focus TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (family_id)
);

CREATE TABLE dev_include_access.family_relationship (
	family_relationship_id TEXT NOT NULL,
	family_member_id TEXT NOT NULL,
	relationship_type TEXT NOT NULL,
	subject_id TEXT NOT NULL,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (family_relationship_id)
);

CREATE TABLE dev_include_access.family_member (
	id SERIAL NOT NULL,
	family_id TEXT NOT NULL,
	subject_id TEXT NOT NULL,
	family_role TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (id)
);

CREATE TABLE dev_include_access.subject_assertion (
	assertion_id TEXT NOT NULL,
	subject_id TEXT,
	encounter_id TEXT,
	assertion_provenance VARCHAR(31),
	age_at_assertion INTEGER,
	age_at_event INTEGER,
	age_at_resolution INTEGER,
	concept_source TEXT,
	value_number FLOAT,
	value_source TEXT,
	value_unit TEXT,
	value_unit_source TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (assertion_id)
);

CREATE TABLE dev_include_access.sample (
	sample_id TEXT NOT NULL,
	biospecimen_collection_id TEXT,
	parent_sample_id TEXT,
	sample_type TEXT NOT NULL,
	availablity_status VARCHAR(11),
	quantity_number FLOAT,
	quantity_unit TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (sample_id)
);

CREATE TABLE dev_include_access.biospecimen_collection (
	biospecimen_collection_id TEXT NOT NULL,
	age_at_collection FLOAT,
	method VARCHAR,
	site VARCHAR,
	spatial_qualifier VARCHAR,
	laterality VARCHAR,
	encounter_id TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (biospecimen_collection_id)
);

CREATE TABLE dev_include_access.aliquot (
	aliquot_id TEXT NOT NULL,
	sample_id TEXT,
	availablity_status VARCHAR(11),
	quantity_number FLOAT,
	quantity_unit TEXT,
	concentration_number FLOAT,
	concentration_unit TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (aliquot_id)
);

CREATE TABLE dev_include_access.encounter (
	encounter_id TEXT NOT NULL,
	subject_id TEXT,
	encounter_definition_id TEXT,
	age_at_event INTEGER,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (encounter_id)
);

CREATE TABLE dev_include_access.encounter_definition (
	encounter_definition_id TEXT NOT NULL,
	name TEXT,
	description TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (encounter_definition_id)
);

CREATE TABLE dev_include_access.activity_definition (
	activity_definition_id TEXT NOT NULL,
	name TEXT,
	description TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (activity_definition_id)
);

CREATE TABLE dev_include_access.file (
	file_id TEXT NOT NULL,
	filename TEXT,
	format VARCHAR,
	data_category VARCHAR(38),
	data_type VARCHAR,
	size INTEGER,
	staging_url TEXT,
	release_url TEXT,
	drs_uri TEXT,
	access_policy_id TEXT,
	study_id TEXT,
	hash_id INTEGER,
	PRIMARY KEY (file_id)
);

CREATE TABLE dev_include_access.include_participant (
	down_syndrome_status VARCHAR(3) NOT NULL,
	subject_id TEXT NOT NULL,
	sex VARCHAR(7) NOT NULL,
	ethnicity VARCHAR(22) NOT NULL,
	age_at_last_vital_status INTEGER,
	vital_status VARCHAR(5),
	age_at_first_engagement INTEGER,
	access_policy_id TEXT,
	study_id TEXT,
	PRIMARY KEY (subject_id)
);
