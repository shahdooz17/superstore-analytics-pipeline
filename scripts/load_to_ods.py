"""Load Superstore.xlsx into DuckDB (schema `ods`) - the raw landing layer.

Idempotent: running it again simply rebuilds ods.superstore_raw.
Paths can be overridden with env vars (used inside the Airflow container):
    SOURCE_XLSX  -> path to the Excel file
    DUCKDB_PATH  -> path to the DuckDB database file
"""
import os
from pathlib import Path

import duckdb
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
SOURCE_XLSX = Path(os.getenv("SOURCE_XLSX", ROOT / "data" / "raw" / "Superstore.xlsx"))
DUCKDB_PATH = Path(os.getenv("DUCKDB_PATH", ROOT / "dbt_project" / "dev.duckdb"))


def main() -> None:
    if not SOURCE_XLSX.exists():
        raise FileNotFoundError(f"Source file not found: {SOURCE_XLSX}")

    print(f"Reading {SOURCE_XLSX}")
    df = pd.read_excel(SOURCE_XLSX, sheet_name=0)  # single sheet: 'Sample - Superstore'
    print(f"  {len(df):,} rows, {len(df.columns)} columns")

    with duckdb.connect(str(DUCKDB_PATH)) as con:
        con.execute("CREATE SCHEMA IF NOT EXISTS ods")
        con.register("src_df", df)
        con.execute(
            """
            CREATE OR REPLACE TABLE ods.superstore_raw AS
            SELECT *, current_timestamp AS _loaded_at FROM src_df
            """
        )
        n = con.execute("SELECT count(*) FROM ods.superstore_raw").fetchone()[0]
    print(f"Loaded {n:,} rows into {DUCKDB_PATH.name} -> ods.superstore_raw")


if __name__ == "__main__":
    main()
