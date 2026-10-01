"""Run with:  astro dev pytest"""
import os

from airflow.models import DagBag

DAG_FOLDER = os.path.join(os.path.dirname(__file__), "..", "..", "dags")


def _bag():
    return DagBag(dag_folder=DAG_FOLDER, include_examples=False)


def test_no_import_errors():
    assert _bag().import_errors == {}


def test_superstore_dag_structure():
    dag = _bag().get_dag("superstore_pipeline")
    assert dag is not None
    assert [t.task_id for t in dag.topological_sort()] == [
        "load_to_ods", "dbt_run", "dbt_test", "export_marts",
    ]
