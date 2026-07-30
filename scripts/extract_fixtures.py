import io
import logging
from argparse import ArgumentParser
from collections import defaultdict
from csv import DictWriter
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml


# The following trick should allow the correct formatting of CSV data inline
# as unit test YAMLs...
class LiteralString(str):
    pass


def literal_presenter(dumper, data):
    clean_data = data.strip() + "\n"
    if "\n" in clean_data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", clean_data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", clean_data)


yaml.add_representer(LiteralString, literal_presenter)

from scripts import init_logging

logger = logging.getLogger(__name__)


def dump_to_csv(csv_filename: Path, content: list[dict[str, Any]]):
    if content:
        headers = content[0].keys()

        with csv_filename.open("wt") as f:
            writer = DictWriter(f, fieldnames=headers)
            writer.writeheader()
            writer.writerows(content)

        logger.info(f"Written: {csv_filename} ")


def exec(arguments: list[Any] | None = None):
    cwd = Path(".").absolute()

    default_project = cwd.stem.replace("-", "_")
    parser = ArgumentParser(
        description="Extract Fixture content into Unit tests and seed data"
    )
    parser.add_argument(
        "-log",
        "--log-level",
        choices=["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        default="INFO",
        help="Logging level tolerated (default is INFO)",
    )
    parser.add_argument(
        "-p",
        "--project-name",
        default=default_project,
        help=f"dbt project name. Default: {default_project.replace('-', '_')}",
    )
    parser.add_argument(
        "-f",
        "--fixtures-dir",
        default="tests/fixtures/",
        help="Directory where the test fixtures YAML files can be found",
    )
    parser.add_argument(
        "-s",
        "--seed",
        default=None,
        help="dbt fixture directory (for CSV files)",
    )
    parser.add_argument(
        "-unit", "--unit-filename", default="models/staging/stg_unit_tests.yml"
    )
    args = parser.parse_args(arguments)
    init_logging(args.log_level)

    if args.seed is None:
        args.seed = cwd / args.project_name / "seeds/"

    Path(args.seed).mkdir(exist_ok=True, parents=True)

    unit_tests = {"version": 2, "unit_tests": []}

    for yaml_filename in Path(args.fixtures_dir).glob("*.yaml"):
        logger.info(f"Extracting data from {yaml_filename}")
        # csv_filename = Path(args.seed) / f"{yaml_filename.stem}.csv"

        data = yaml.safe_load(yaml_filename.open("rt"))

        # We now can expect different tables, so we'll need to break them up
        # accordingly. This does assume that there won't be references to
        # tables in these tests that are referenced in other places. That is
        # probably a terrible assumption.
        access_content = defaultdict(list)
        for content in data.get("access_content", []):
            access_content[content["source_table"]].append(
                {k: v for k, v in content.items() if k != "source_table"}
            )

        @dataclass
        class SeedFixturePair:
            seed_filename: str = ""
            mock_fixture_fn: str = ""

        dbt_fixtures = Path(args.project_name) / "tests/fixtures"
        mock_fixtures = {}
        for table, table_data in access_content.items():
            filename = Path(args.seed) / f"{table}.csv"
            dump_to_csv(filename, table_data)
            mock_fixtures[table] = f"mock_{table}"

            mock_fixture_fn = (
                Path(args.project_name)
                / f"tests/fixtures/{data['model']}/{mock_fixtures[table]}.csv"
            )

            mock_fixture_fn.parent.mkdir(exist_ok=True, parents=True)
            mock_fixture_fn.unlink(missing_ok=True)
            mock_fixture_fn.symlink_to(filename)
            logger.info(filename)

        mock_expected_fn = (
            dbt_fixtures / f"{data['model']}/mock_results_{data['model']}.csv"
        )
        dump_to_csv(mock_expected_fn, data.get("resource_content"))
        # Now we'll prepare the unit test content for this one:
        unit_tests["unit_tests"].append(
            {
                "name": data["name"],
                "description": data["description"],
                "model": data["model"],
                "given": [],
                "expect": {
                    "format": "csv",
                    "fixture": f"mock_results_{data['model']}",
                },
                # "expect": {"rows": data.get("resource_content")},
            }
        )
        print(f"The length of unit tests: {len(unit_tests['unit_tests'])}")

        for table, table_data in access_content.items():
            # Let's invert these to look more like CSV data to bypass
            # the include as jinja keyword issue
            header = table_data[0].keys()
            buffer = io.StringIO()
            writer = DictWriter(buffer, fieldnames=header, lineterminator="\n")
            writer.writeheader()
            writer.writerows(table_data)
            test_data = (
                buffer.getvalue().strip().replace(",include", ",\"{{ 'include' }}\"")
            )
            # test_data = textwrap.indent(test_data, " " * 10)

            logger.info(test_data)
            unit_tests["unit_tests"][-1]["given"].append(
                {
                    "input": f"source('dev_include_access', '{table}')",
                    "format": "csv",
                    "fixture": mock_fixtures[table],
                    # "rows": LiteralString(test_data),
                }
            )

    """
    unit_path = cwd / args.project_name / args.unit_filename
    unit_path.parent.mkdir(exist_ok=True, parents=True)
    with unit_path.open("wt") as file:
        yaml.dump(unit_tests, file, default_flow_style=False, sort_keys=False)
    logger.info(f"Unit tests written to '{unit_path}'")
    """


if __name__ == "__main__":
    exec()
