# Data dbt Architecture Playground

This repository is a static, runnable reference implementation of a governed layered dbt architecture using a compact commerce domain.

Start here:

- [Architecture](docs/architecture.md)
- [Decisions](docs/decisions.md)

## Architecture Shape

Foundation is layered. Consumption is branched.

```text
Source / JSON landing -> landing -> staging -> {systems (terminal)
                                                 core -> logical (optional) -> marts (optional facts+dimensions)}

core, logical, and marts may each feed reporting, semantic, and operational directly.
```

The mandatory discipline is the trusted business foundation through Core (Staging -> Core). After Core, models take the shortest sensible trusted path to Reporting/Semantic/Operational -- Logical and Marts are used only where they add reuse or value, never as mandatory toll booths. The original starter staging and mart models have been removed from the active model estate.

## What This Demonstrates

- Source-faithful JSON/CDC ingestion with metadata.
- Deterministic landing currentness and deduplication.
- Source-specific staging with casts, renames, and standardisation.
- A no-logic systems access branch over staging.
- Reusable logical transformations for sequencing, reconciliation, and derived states, correctly built on top of Core (not Staging).
- A canonical Core layer for Customer, User, Address, Product, Order, Order Line, Payment, and relationship/snapshot records, free of order-derived behavioural drift.
- Marts containing only reusable facts and dimensions.
- A Reporting layer for consumer-facing decision reports.
- An enforced Operational delivery contract that reads Core/Marts directly (not through Reporting).
- A governed Manual Inputs pattern (seed fixture standing in for a production governed input) feeding Core.
- dbt Core 1.12+ model-attached semantic metadata and metrics.
- Cross-cutting quality controls (tests, freshness, contracts) rather than a dedicated "operations" layer.

## Source Fixtures

The static source fixture set lives in `seeds/ecom/` and `seeds/inputs/`:

Application/source seeds load into the `raw` schema:

- `raw_customers`
- `raw_users`
- `raw_customer_users`
- `raw_addresses`
- `raw_customer_addresses`
- `raw_order_address_snapshots`
- `raw_orders`
- `raw_items`
- `raw_products`

The Manual Inputs fixture loads into its own `inputs` schema, kept physically
distinct from `raw` so it is never mistaken for ordinary source-system data
(see docs/architecture.md):

- `raw_customer_marketing_exclusions` -> `inputs.raw_customer_marketing_exclusions`

These seed files are part of the reference implementation. Keep them in the repo unless the architecture is deliberately changed.

## Local Validation

This repository commits a local-only, credential-free DuckDB `profiles.yml` at
the repo root, so a clean clone works with no manual profile setup. Use the
project profile in this repository:

```bash
uv sync
uv run dbt deps
uv run dbt parse --profiles-dir .
uv run dbt seed --full-refresh --vars '{"load_source_data": true}' --profiles-dir .
uv run dbt build --profiles-dir .
uv run dbt test --profiles-dir .
uv run dbt source freshness --profiles-dir .
```

DuckDB takes a file lock on `target/data_dbt_architecture.duckdb`, so run dbt commands serially.

## Active Model Estate

- `models/0. landing/0. external/json/ecom`: source-faithful JSON/CDC external views.
- `models/0. landing/1. raw/ecom`: current trusted landing records.
- `models/1. staging/ecom`: source-specific staging views.
- `models/1. staging/inputs`: staging view over the Manual Inputs marketing-exclusions source.
- `models/2a. core`: canonical business entities, events, relationships, and the manual marketing-exclusion input.
- `models/2b. systems/ecom`: controlled staging access views with no transformation logic (terminal).
- `models/3. logical`: reusable transformations built on top of Core.
- `models/4. marts/dimensions`: analytical dimensions.
- `models/4. marts/facts`: conformed analytical facts.
- `models/5a. reporting`: consumer-facing, terminal reports.
- `models/5b. semantic`: semantic support model and model-attached semantic YAML.
- `models/5c. operational`: frozen, enforced-contract delivery models.
