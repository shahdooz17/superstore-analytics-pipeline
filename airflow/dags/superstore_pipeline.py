"""Superstore pipeline: Excel -> DuckDB (ods) -> dbt (staging/intermediate/marts) -> tests -> CSV export.

Runs inside the Astro (Docker) containers. Folders from the repo are mounted by
airflow/docker-compose.override.yml, and all tools run from an isolated virtualenv
(/usr/local/airflow/pipeline_venv, built in the Dockerfile) so they never clash with Airflow's packages.
"""
from datetime import datetime, timedelta

from airflow import DAG

# Airflow 3 moved BashOperator into the "standard" provider; fall back for Airflow 2.
try:
    from airflow.providers.standard.operators.bash import BashOperator
except ImportError:  # pragma: no cover
    from airflow.operators.bash import BashOperator

HOME = "/usr/local/airflow"
PYTHON = f"{HOME}/pipeline_venv/bin/python"
DBT = f"{HOME}/pipeline_venv/bin/dbt"
DBT_DIR = f"{HOME}/dbt_project"

default_args = {
    "owner": "data-engineering",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

with DAG(
    dag_id="superstore_pipeline",
    description="Load Superstore.xlsx into DuckDB, run dbt models + tests, export marts for Power BI",
    default_args=default_args,
    start_date=datetime(2025, 1, 1),
    schedule="@daily",
    catchup=False,          # don't backfill past days - the pipeline is a full refresh anyway
    max_active_runs=1,      # DuckDB allows one writer at a time
    tags=["superstore", "dbt", "duckdb"],
    doc_md=__doc__,
) as dag:

    load_to_ods = BashOperator(
        task_id="load_to_ods",
        bash_command=f"{PYTHON} {HOME}/scripts/load_to_ods.py",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"cd {DBT_DIR} && {DBT} seed --profiles-dir . && {DBT} run --profiles-dir .",
        env={"DBT_SEND_ANONYMOUS_USAGE_STATS": "False"},
        append_env=True,
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {DBT_DIR} && {DBT} test --profiles-dir .",
        env={"DBT_SEND_ANONYMOUS_USAGE_STATS": "False"},
        append_env=True,
    )

    export_marts = BashOperator(
        task_id="export_marts",
        bash_command=f"{PYTHON} {HOME}/scripts/export_marts.py",
    )

    load_to_ods >> dbt_run >> dbt_test >> export_marts
