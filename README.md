# dbt Jaffle Shop Architecture Playground

This repository is a static, runnable reference implementation of a layered dbt architecture using a compact Jaffle Shop commerce domain.

Start here:

- [Architecture](docs/architecture.md)
- [Decisions](docs/decisions.md)

## Architecture Shape

```text
Source / JSON landing -> landing -> staging
                                      |-> systems
                                      `-> logical -> objects -> marts
                                                           |-> operations / pumps
                                                           `-> semantic
```

The active project intentionally has one unambiguous path through each layer. The original starter staging and mart models have been removed from active model paths so they do not compete with the reference architecture.

## What This Demonstrates

- Source-faithful JSON/CDC ingestion with metadata.
- Deterministic landing currentness and deduplication.
- Source-specific staging with casts, renames, and standardisation.
- A no-logic systems access branch over staging.
- Reusable logical transformations for sequencing, reconciliation, and derived states.
- Canonical objects for Customer, User, Address, Product, Order, Order Line, Payment, and relationship/snapshot objects.
- Marts with distinct dimensions, facts, reports, and bounded decision marts.
- An enforced operational pump contract.
- dbt Core 1.12+ model-attached semantic metadata and metrics.
- Operations controls for reconciliation, landing uniqueness, payment overage, zero-value order policy, and freshness.

## Source Fixtures

The static source fixture set lives in `seeds/jaffle-data/` and is loaded into the `raw` schema:

- `raw_customers`
- `raw_users`
- `raw_customer_users`
- `raw_addresses`
- `raw_customer_addresses`
- `raw_order_address_snapshots`
- `raw_orders`
- `raw_items`
- `raw_products`

These seed files are part of the reference implementation. Keep them in the repo unless the architecture is deliberately changed.

## Local Validation

Use the project profile in this repository:

```bash
uv sync
uv run dbt deps
uv run dbt parse --profiles-dir .
uv run dbt seed --full-refresh --vars '{"load_source_data": true}' --profiles-dir .
uv run dbt build --profiles-dir .
uv run dbt test --profiles-dir .
uv run dbt source freshness --profiles-dir .
```

DuckDB takes a file lock on `target/jaffle_shop.duckdb`, so run dbt commands serially.

## Active Model Estate

- `models/0. landing/0. external/json/ecom`: source-faithful JSON/CDC external views.
- `models/0. landing/1. raw/ecom`: current trusted landing records.
- `models/1. staging/ecom`: source-specific staging views.
- `models/2a. objects`: canonical business objects, events, relationships, and snapshots.
- `models/2b. systems/commerce`: controlled staging access views with no transformation logic.
- `models/3. logical/commerce`: reusable internal transformations.
- `models/4. marts/dimensions`: analytical dimensions.
- `models/4. marts/facts`: conformed analytical facts.
- `models/4. marts/reports`: reports and bounded decision marts.
- `models/5. semantic`: semantic support model and model-attached semantic YAML.
- `models/6. operations`: reconciliation controls and pump delivery contracts.
