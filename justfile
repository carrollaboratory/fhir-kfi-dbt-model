
PROJECT_DIR := fhir_kfi_dbt_model

# Let's just default to running the unit tests. We may bump this up to the fhir
# stuff by default later, but this should be a good starting point.
default: test

# The unit tests will be defined as YAML files, but the DBT unittests want
# CSVs.
flatten-test-data:
  uv run python scripts/flatten_test_fixtures.py

start-pgsql:
  docker start dbt-test-pg || true

[working-directory(PROJECT_DIR)]
test: flatten-test-data start-pgsql
  uv run dbt test --select "test_type:unit"

[working-directory(PROJECT_DIR)]
run-pipeline: flatten-test-data start-pgsql
  uv run dbt build
  uv run python ../scripts/spit-fhir.py
