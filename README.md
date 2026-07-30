# fhir-kfi-dbt-model

A dbt project that transforms the INCLUDE Access Model (PostgreSQL) into FHIR R4 resources. This is POC-stage: the models should be valid, but development happens locally against test fixture data until real access-model data is available.

Full docs, including design notes and a fuller command reference, are published at **https://carrollaboratory.github.io/fhir-kfi-dbt-model/**. This file covers just enough to get a local environment running.

## Prerequisites

- [`uv`](https://docs.astral.sh/uv/) — Python dependency management
- [`just`](https://github.com/casey/just) (>= 1.51.0) — command runner; all workflows below go through it
- [`docker`](https://www.docker.com/) — runs the local Postgres instance the pipeline builds against
- `psql` configured with a `dbt-test` [connection service](https://www.postgresql.org/docs/current/libpq-pgservice.html) (in `~/.pg_service.conf`) pointing at that Postgres instance
- A `dbt-test-pg` Docker container, and `~/.dbt/profiles.yml` with a `fhir_kfi_dbt_model` profile matching it

<!-- TODO: exact `docker run` invocation used to create the `dbt-test-pg` container, and a sample profiles.yml, aren't captured anywhere yet — fill in once you have them handy. -->

## Setup

```sh
uv sync                 # install Python dependencies
just dbtdeps             # install dbt packages (dbt_utils)
just seed                # load seed data
just test                 # run the unit test suite
```

If `just test` passes, your environment is wired up correctly.

## Everyday commands

See the [full command reference](https://carrollaboratory.github.io/fhir-kfi-dbt-model/#/) in the docs for the complete list — the essentials:

| Command | What it does |
|---|---|
| `just start-pgsql` / `just stop-pgsql` | Start / stop the local Postgres container |
| `just seed` | Load dbt seeds |
| `just test` | Run dbt unit tests |
| `just run-pipeline` | Full `dbt build` + dump resulting FHIR resources to `output/dbt_fhir.json` |
| `just validate-fhir` | `run-pipeline` plus schema validation of the output via `spit-fhir` |
| `just lintit` / `just fluffit` | Lint / auto-fix SQL with sqlfluff |
