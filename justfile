_ensure_min_just_version := `min="1.51.0"; cur="$(just --version | cut -d' ' -f2)"; if [ "$(printf '%s\n%s\n' "$min" "$cur" | sort -V | head -n1)" != "$min" ]; then echo "just $cur is too old — this justfile requires just >= $min. See https://just.systems/man/en/pre-built-binaries.html" >&2; exit 1; fi`
PROJECT_DIR := "fhir_kfi_dbt_model"
export ACCESS_MODEL_SCHEMA := "dev_include_access"


# Let's just default to running the unit tests. We may bump this up to the fhir
# stuff by default later, but this should be a good starting point.
default: test

# The unit tests will be defined as YAML files, but the DBT unittests want
# CSVs.
flatten-test-data:
  uv run python scripts/flatten_test_fixtures.py

start-pgsql:
  docker start dbt-test-pg || true

create-schema: start-pgsql
  psql service=dbt-test -c "DROP SCHEMA IF EXISTS {{ACCESS_MODEL_SCHEMA}} CASCADE; CREATE SCHEMA {{ACCESS_MODEL_SCHEMA}};"
  psql service=dbt-test -f tests/fixtures/sql/common-access-model.sql

[working-directory(PROJECT_DIR)]
test: flatten-test-data start-pgsql
  uv run dbt test --select "test_type:unit"

[working-directory(PROJECT_DIR)]
run-pipeline: flatten-test-data start-pgsql
  uv run dbt build
  uv run python ../scripts/spit-fhir.py
