{% macro generate_schema_name(custom_schema_name, node) %}

    {# seeds go into whatever schema they're configured with in dbt_project.yml,
       regardless of target -- ordinary application seeds default to `raw`, but
       the Manual Inputs seed folder overrides this to `inputs` so it is never
       mistaken for source-system data. See docs/architecture.md. #}
    {% if node.resource_type == 'seed' %}
        {{ custom_schema_name | trim }}

    {# non-specified schemas go to the default target schema #}
    {% elif custom_schema_name is none %}
        {{ target.schema }}

    {# Local DuckDB dev: flat, clean schemas that map 1:1 to architecture layers
       (core, logical, marts, reporting, ...). There is only ever one developer
       and one file, so there is no collision risk to guard against, and a
       `main_core` style prefix would just be noise against the layer names this
       repo is trying to teach. In a real Snowflake-backed environment (a
       non-dev target, or any target that isn't DuckDB) we fall back to dbt's
       default environment-safe behavior of prefixing the custom schema with the
       target schema (e.g. `<target_schema>_<custom>`) so that multiple
       developers/CI runs sharing one database don't collide. See
       docs/architecture.md for the intended production Snowflake layout
       (RAW.<source> / RAW.INPUTS, then PRD.LANDING / PRD.STAGING / PRD.SYSTEMS /
       PRD.CORE / PRD.LOGICAL / PRD.MARTS / PRD.REPORTING / PRD.SEMANTIC /
       PRD.OPERATIONAL), which is a docs concern -- it can't be faked against a
       single local DuckDB file. Local `source_json` is CDC-simulation machinery
       only and has no separate PRD.SOURCE_JSON production counterpart. #}
    {% elif target.name == 'dev' and target.type == 'duckdb' %}
        {{ custom_schema_name | trim }}

    {% else %}
        {{ target.schema }}_{{ custom_schema_name | trim }}
    {% endif %}

{% endmacro %}
