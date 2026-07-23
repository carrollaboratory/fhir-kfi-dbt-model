#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path
from posixpath import exists

import psycopg2
from psycopg2.extras import DictCursor


def main():
    parser = argparse.ArgumentParser(
        description="Export FHIR jsonb data from PostgreSQL tables to a JSON file."
    )
    parser.add_argument(
        "--db-uri",
        default="postgresql://postgres@localhost/postgres",
        help="PostgreSQL connection URI (e.g., postgresql://user:pass@host:port/dbname)",
    )
    parser.add_argument(
        "--output", required=True, help="Path to the target output .json file"
    )
    parser.add_argument(
        "--schema", default="dev_include_access", help="Schema data can be found inside"
    )
    parser.add_argument(
        "tables",
        nargs="+",
        help="One or more positional arguments for table names to export",
    )

    args = parser.parse_args()
    conn = None

    try:
        # Establish connection to your PostgreSQL instance
        conn = psycopg2.connect(args.db_uri)
        cur = conn.cursor(cursor_factory=DictCursor)

        exported_data = {}

        schema = args.schema
        for table in args.tables:
            full_table_name = f"{schema}.{table}"
            print(f"Extracting payloads from {schema}.{table}...")

            # Encapsulate identifiers cleanly to respect reserved keywords or mixed case names
            query = f'SELECT * FROM "{schema}"."{table}";'
            cur.execute(query)
            rows = cur.fetchall()

            # Map DictRows into standard python dict lists.
            # Psycopg2 maps JSONB fields straight to native dicts/lists instantly.
            table_rows = [dict(row) for row in rows]
            exported_data[full_table_name] = table_rows

        Path(args.output).parent.mkdir(exist_ok=True, parents=True)
        # Package it up cleanly into the designated target destination
        with open(args.output, "w", encoding="utf-8") as f:
            json.dump(exported_data, f, indent=2, default=str)

        print(f"Successfully packaged and written data to: {args.output}")

    except Exception as e:
        print(f"Database error or execution failure: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    main()
