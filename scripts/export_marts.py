"""Export every table in the `marts` schema to CSV (data/cleaned/).

Power BI can read these CSVs directly - a simple fallback to the DuckDB ODBC driver.
"""
import os
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DUCKDB_PATH = Path(os.getenv("DUCKDB_PATH", ROOT / "dbt_project" / "dev.duckdb"))
OUT_DIR = Path(os.getenv("EXPORT_DIR", ROOT / "data" / "cleaned"))


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    with duckdb.connect(str(DUCKDB_PATH), read_only=True) as con:
        tables = [r[0] for r in con.execute(
            "SELECT table_name FROM information_schema.tables "
            "WHERE table_schema = 'marts' ORDER BY 1").fetchall()]
        if not tables:
            raise RuntimeError("No tables found in schema 'marts' - did dbt run?")
        for t in tables:
            target = OUT_DIR / f"{t}.csv"
            con.execute(f"COPY marts.{t} TO '{target.as_posix()}' (HEADER, DELIMITER ',')")
            n = con.execute(f"SELECT count(*) FROM marts.{t}").fetchone()[0]
            print(f"Exported marts.{t:<14} {n:>6,} rows -> {target.name}")


if __name__ == "__main__":
    main()
