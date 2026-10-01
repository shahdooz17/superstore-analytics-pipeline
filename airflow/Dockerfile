FROM astrocrpublic.azurecr.io/runtime:3.3-8
# >>> APPEND THESE LINES to the END of your existing airflow/Dockerfile (keep the FROM line as is) <<<

# Pipeline tools (dbt + DuckDB + pandas) in an isolated virtualenv so they cannot clash with Airflow's packages
COPY include/pipeline-requirements.txt /tmp/pipeline-requirements.txt
RUN python -m venv /usr/local/airflow/pipeline_venv && \
    /usr/local/airflow/pipeline_venv/bin/pip install --no-cache-dir -r /tmp/pipeline-requirements.txt