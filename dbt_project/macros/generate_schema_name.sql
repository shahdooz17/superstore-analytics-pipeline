{#- By default dbt names schemas <target_schema>_<custom_schema> (e.g. main_marts).
    This override uses the custom schema name as-is, so we get clean schemas:
    staging, intermediate, marts, seeds. -#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
