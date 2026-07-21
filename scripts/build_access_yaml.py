import logging
import sys
from argparse import ArgumentParser
from csv import DictReader, DictWriter
from genericpath import exists
from pathlib import Path
from string import Template
from typing import Any, Dict, List

from yaml import safe_dump, safe_load

from scripts import init_logging

stage_lookup = {"access_policy": "consent", "research_study": "research_study"}

dbt_model_template = Template("""
with source as (
    select * from {{ source('$source_schema', '$table_name')  }}
),

renamed as (
    select
        $cols
    from source
)

select * from renamed
""")


def exec():
    cwd = Path(".").absolute()
    default_project = cwd.stem.replace("-", "_")
    default_schema = f"{default_project}/models/access/src_dev_include_access.yml"
    parser = ArgumentParser(
        description="Pulls column names out of a dbt yml file and creates a stub for the yaml test fixture"
    )
    parser.add_argument(
        "-m",
        "--model",
        default=default_schema,
        help=f"Which dbt model to use (default: {default_schema})",
    )
    parser.add_argument("-o", "--output", default=f"tests/fixtures/{default_project}")
    parser.add_argument(
        "-a",
        "--access-model",
        default="dev_include_access",
        help="The schema associated with the incoming data for the dbt transforms",
    )
    parser.add_argument(
        "-log",
        "--log-level",
        choices=["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        default="INFO",
        help="Logging level tolerated (default is INFO)",
    )
    args = parser.parse_args()

    init_logging(args.log_level)
    if not Path(args.model).exists():
        logging.error(
            f"Specified dbt model, '{args.model}', does not exist. Unable to continue"
        )
        sys.exit(1)

    with open(args.model) as inf:
        dbt_model = safe_load(inf)

        for schema in dbt_model["sources"]:
            dest = Path(f"{args.output}/{schema['name']}")
            dest.mkdir(exist_ok=True, parents=True)

            for table in schema["tables"]:
                stage_name = None
                varnames = []
                for column in table["columns"]:
                    varnames.append(column["name"])

                if table["name"] in stage_lookup:
                    stage_name = stage_lookup[table["name"]]

                    # YAML Test fixture
                    outfilename = Path(dest / f"{schema['name']}/{table['name']}.yml")
                    outfilename.parent.mkdir(exist_ok=True, parents=True)
                    testdata = {
                        "name": f"{table['name']} to TBD",
                        "description": table.get("description"),
                        "model": stage_name,
                        "source_table": table["name"],
                        "access_content": [[f"{name}:" for name in varnames]],
                        "resource_content": [[f"{name}:" for name in varnames]],
                    }
                    with outfilename.open("wt") as outf:
                        safe_dump(testdata, outf)
                    logging.info(outfilename)

                # dbt model stub
                stage_prefix = dest / f"{schema['name']}/{table['name']}_stg_"
                if stage_name is None:
                    outfilename = Path(
                        dest / f"{schema['name']}/extras/{table['name']}.sql"
                    )
                else:
                    outfilename = Path(
                        dest / f"{schema['name']}/{table['name']}_stg_{stage_name}.sql"
                    )
                outfilename.parent.mkdir(exist_ok=True, parents=True)
                context = {
                    "source_schema": schema["name"],
                    "table_name": table["name"],
                    "cols": ",\n        ".join(
                        f"source.{name}::text as {name}" for name in varnames
                    ),
                }

                with outfilename.open("wt", encoding="utf-8", newline="") as outf:
                    outf.write(dbt_model_template.substitute(context))
                logging.info(outfilename)
            else:
                logging.warning(f"Skipping unstaged table, {table['name']}")


if __name__ == "__main__":
    exec()
