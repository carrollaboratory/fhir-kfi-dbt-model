import csv
import json
from argparse import ArgumentParser
from pathlib import Path
from typing import Any, Dict, List

import yaml


def dump_to_csv(csv_filename: Path, content: List[Dict[str, Any]]):
    if content:
        headers = content[0].keys()

        with csv_filename.open("wt") as f:
            writer = csv.DictWriter(f, fieldnames=headers)
            writer.writeheader()
            writer.writerows(content)

        print(f"Written: {csv_filename} ")


def exec(arguments: List[Any] | None = None):
    cwd = Path(".").absolute()
    parser = ArgumentParser(
        description="Flatten YAML Fixtures into dbt friendly CSV files"
    )
    parser.add_argument("-p", "--project-name", default=cwd.stem)
    parser.add_argument(
        "-f",
        "--fixtures-dir",
        default="tests/fixtures/",
        help="Directory where the test fixtures YAML files can be found",
    )
    parser.add_argument(
        "-o", "--output", default=None, help="dbt fixture directory (for CSV files)"
    )
    args = parser.parse_args(arguments)

    if args.output is None:
        args.output = cwd / args.project_name / "tests/fixtures"

    Path(args.output).mkdir(exist_ok=True, parents=True)

    for yaml_filename in Path(args.fixtures_dir).glob("*.yaml"):
        csv_filename = Path(args.output) / f"access_{yaml_filename.stem}.csv"

        data = yaml.safe_load(yaml_filename.open("rt"))

        access_content = data.get("access_content", [])
        dump_to_csv(csv_filename, access_content)

        csv_filename = Path(args.output) / f"resource_{yaml_filename.stem}.csv"
        resource_content = data.get("resource_content", [])
        dump_to_csv(csv_filename, resource_content)


if __name__ == "__main__":
    exec()
