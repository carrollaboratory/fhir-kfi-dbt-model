# fhir-kfi-dbt-model

A dbt project that transforms the INCLUDE Access Model (PostgreSQL) into FHIR R4 resources, stored as JSONB. POC-stage: development happens locally against test fixture data until real access-model data is available; the goal is for these models to drop into the real environment largely unchanged once that data exists.

See the sidebar for design docs (e.g. the [curie → FHIR system registry](design/curie-registry.md)). This page is the practical getting-started + reference guide.

## Architecture

Two-stage pipeline, one pair of models per FHIR resource:

- **Stage 1 — `models/staging/stg_<resource>.sql`**: flat intermediate, one row per FHIR resource candidate, still shaped close to the source access-model tables.
- **Stage 2 — `models/fhir/fhir_<resource>.sql`**: scalar search columns plus the full JSONB `resource` column.

Sources are declared in `models/access/src_dev_include_access.yml`, reading from `tgt_access_model_<ClassName>`-style tables (dbt source name `include_access_model`, schema controlled by the `include_access_model_schema` var, default `public`). Multivalued fields on the LinkML-derived access model (e.g. `Study.external_id`) show up as separate linking tables — `study_external_id`, `sample_external_id`, etc. — each needing its own staging treatment as those resources get built out.

## Prerequisites

- [`uv`](https://docs.astral.sh/uv/) — Python dependency management
- [`just`](https://github.com/casey/just) (>= 1.51.0) — every workflow below goes through it
- [`docker`](https://www.docker.com/) — runs the local Postgres instance (`dbt-test-pg`) the pipeline builds against
- `psql` with a `dbt-test` [connection service](https://www.postgresql.org/docs/current/libpq-pgservice.html) defined in `~/.pg_service.conf`, pointing at that container
- `~/.dbt/profiles.yml` with a `fhir_kfi_dbt_model` profile matching the same Postgres instance

<!-- TODO: the exact `docker run` used to create `dbt-test-pg`, and a sample profiles.yml, should live here — not yet captured anywhere in the repo. -->

## First-time setup

```sh
uv sync          # install Python dependencies (dbt-core, dbt-postgres, spit-fhir, sqlfluff, ...)
just dbtdeps       # dbt deps — pulls dbt_utils per packages.yml
just start-pgsql    # start (or first-create) the dbt-test-pg container
just seed            # flatten test fixtures + load dbt seeds
just test             # run the unit test suite
```

A clean `just test` run means the environment is set up correctly.

## Command reference

### Postgres

| Command | What it does |
|---|---|
| `just start-pgsql` | `docker start dbt-test-pg` (starts the existing container) |
| `just stop-pgsql` | `docker stop dbt-test-pg` |
| `just create-schema` | Drops and recreates the `dev_include_access` schema, then loads the access-model DDL from `tests/fixtures/sql/include_access_model.sql` |

### dbt

| Command | What it does |
|---|---|
| `just dbtdeps` | `dbt deps` |
| `just seed` | Flattens test fixtures, then `dbt seed` |
| `just test` | Flattens test fixtures, then `dbt test --select "test_type:unit"` |
| `just run-pipeline` | Flattens test fixtures, `dbt build`, prints resource summary, dumps built FHIR resources to `output/dbt_fhir.json` |
| `just clean` | Removes `target/` and `logs/` (dbt's own `clean` doesn't play well with `just`) |

### FHIR validation

| Command | What it does |
|---|---|
| `just spit-fhir` | Validates existing output against `tests/spitfhir.yaml` via the [spit-fhir](https://github.com/carrollaboratory/spit-fhir) tool |
| `just validate-fhir` | `run-pipeline` + `spit-fhir` — the full "does this actually produce valid FHIR" check |

### Linting

| Command | What it does |
|---|---|
| `just lintit` | `sqlfluff lint` against `models/` (dbt-postgres dialect) |
| `just fluffit` | `sqlfluff fix` against `models/` |

## Testing philosophy

Test fixtures are authored once as YAML under `tests/fixtures/*.yaml` (one file per source model, e.g. `research_study.yaml`) and describe both the raw access-model rows (`access_content`) and the expected FHIR output (`resource_content`). `scripts/extract_fixtures.py` (run via `just flatten-test-data`, a dependency of `seed` and `test`) flattens these into the per-table CSVs dbt actually consumes — both as seed data and as `dbt test --select test_type:unit` fixtures. Edit the YAML, not the generated CSVs.

## Module workflow

Adding a new FHIR resource generally means, per resource:

1. A staging model (`models/staging/stg_<resource>.sql`) + its `_staging.yml` schema/column tests.
2. A FHIR model (`models/fhir/fhir_<resource>.sql`) + its `_fhir.yml`.
3. A fixture YAML under `tests/fixtures/` with representative input rows and expected output.
4. If the resource carries external identifiers, a `stg_<resource>_external_id.sql` staging model joining against the [curie registry](design/curie-registry.md) seed.
