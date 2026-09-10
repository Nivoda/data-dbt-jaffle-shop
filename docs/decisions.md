# Decisions And Deliberately Avoided Anti-Patterns

## Remove Starter Models From Active Model Paths

The original starter marts and staging models are removed from active model paths. This avoids retaining parallel staging or mart structures that make the reference architecture ambiguous.

## Source / JSON Landing Keeps Source Fidelity

JSON/CDC-shaped records are generated from explicit ecom raw seed tables. The architecture playground includes first-class seeds for users, customer-user relationships, addresses, customer-address relationships, and immutable order address snapshots so those canonical chains are executable rather than only documented. Payments are still derived from orders because the starter data has no payment seed, and `raw_items` is one row per purchased item, so order-line quantity is represented as `1`.

## Landing Owns Currentness

Current-record selection happens only in landing. The deterministic winner order is source update timestamp, ingestion timestamp, then ingestion event id. Staging, systems, core, logical, marts, reporting, semantic, and operational do not redo CDC deduplication.

## Systems Are Access Views, Not Transformation Models

Systems branch directly from staging and use only `dbt_utils.star()` projections. They do not join, aggregate, filter, classify, assign surrogate keys, or create business contracts. Systems are a terminal access branch and never feed core, logical, marts, reporting, semantic, or operational. Stable contracts belong in core, marts, and operational.

## Logical Models Use The `int_` Prefix

The architectural layer is named Logical, but models follow standard dbt intermediate naming in their model/file name (e.g. `int_order_payment_position`), while their physical alias drops the `int_` prefix (`logical.order_payment_position`) since the schema already communicates the layer. `int_order_payment_position` centralizes order/payment joins and statuses, `int_customer_order_sequence` centralizes first/repeat order logic, and `int_order_line_amounts` centralizes the product/order-line join needed for reusable commercial line calculations. Payment completeness and commercial status are based on captured payment value only, so pending non-zero payment attempts cannot create completed orders or settled revenue. Zero-value orders are explicitly `no_charge` / `not_required`; they are not completed revenue events.

## Core Is Canonical: No Behavioural Drift

Core exists to hold canonical durable business entities, relationships, and events at stable grains -- durable in the sense that a canonical entity's shape does not change because of *what happened to it downstream*. `core.customer` previously carried `first_ordered_at` / `last_ordered_at` / `lifetime_order_count` / `is_repeat_customer`, derived from order activity via a Logical dependency. This was a real bug in the previous iteration of this reference: it made the canonical Customer record change based on order behaviour, and it inverted the dependency direction (Core depending on Logical instead of the other way around). Those attributes now live in `marts.dim_customer`, sourced from `logical.customer_order_sequence`, which itself is now correctly built on `core.orders` (not staging). The rule going forward: before adding a column to a Core model, ask whether it describes the entity/event itself, or an interpretation of its downstream activity -- only the former belongs in Core.

Source-native relationship records (`core.customer_user`, `core.customer_address`) are the exception that proves the rule: they stay in Core, not Logical, because they carry their *own* source relationship id and validity window -- they are canonical facts, not a derived interpretation. The derived, enriched business view over those relationships (resolving current contact/address details) is `logical.customer_contact_profile`.

`core.order_line` is the canonical source order-line record built directly from staging. Commercial interpretation (extended line amounts, current product name/price context) is Logical's job (`logical.order_line_amounts`), not Core's. Those Logical columns are explicitly named `current_catalogue_*`/`current_product_name` because they reflect today's catalogue, not an at-purchase historical amount -- see the Order-Line Monetary Semantics decision below.

`core.customer` is the sole authority for `customer_sk`. Orders join to `core.customer` to carry the canonical Customer key into `core.orders`, and marts select that key from Core instead of regenerating it from source identifiers. `core.product` is the sole authority for `product_sk`; `core.order_line` carries `order_sk` from `core.orders` and `product_sk` from `core.product`, so downstream facts inherit canonical relationship keys rather than rebuilding them from natural identifiers.

`core.order`'s physical alias is `orders`, not `order` -- ORDER is a reserved word in Snowflake, so a real physical relation named `core.order` would require quoting everywhere it's queried. The dbt model/file/ref name stays `order` (`ref('order')`) to minimize churn; only the `config(alias=...)` changed, so the resulting relation is `core.orders`. The semantic-layer entity name `order` is independent of this and is unaffected.

## Marts Contain Only Reusable Facts And Dimensions

Marts contain analytical facts and dimensions -- nothing else. Reports and bounded decision views live in Reporting instead (see below); this reference previously put `mart_commerce__customer_360` under `models/4. marts/reports`, which blurred "reusable, general-purpose analytical shape" with "consumer-specific report," so Reports was removed from Marts entirely. This reference keeps `marts.fct_order`, `marts.fct_order_line`, and `marts.dim_customer`. The project still does not manufacture a product dimension because the canonical Core Product entity is enough for the current analytical surface.

## Dimensions Are A Mart Subtype, Not Core Synonyms

`dim_*` models belong to the mart layer when there is a real dimensional-consumption requirement. They are not automatically created for every canonical Core entity. `core.customer` is the canonical customer identity anchor, and `marts.fct_order` references `core.customer.customer_sk` directly. `marts.dim_customer` exists because it has a distinct purpose: it resolves a current analytical customer contact/address shape *and* repeat-order behavioural attributes (deliberately not stored in Core, see above) for analytical consumption. A future `dim_product` should be introduced only when it has a similarly distinct purpose -- an explicit SCD policy, role-playing usage, a deliberately selected analytical attribute set, or a performance/BI-consumption need -- not merely to mirror `core.product`.

## Reporting Is A Terminal Consumer-Facing Layer

`reporting.customer_360` (formerly `models/4. marts/reports/mart_commerce__customer_360`) is a bounded, consumer-facing decision view for customer identity, contactability, and commercial posture. It consumes `marts.dim_customer` and `marts.fct_order` directly because both are already reusable marts -- the shortest sensible trusted path -- rather than being forced through any additional hop. Nothing in Core, Logical, Marts, Semantic, or Operational may depend on Reporting; it is a strictly terminal leaf.

## Operational Delivery Contracts Do Not Depend On Reporting

`operational.customer_marketing_eligibility` (formerly `pump_customer_marketing_eligibility` under a generic `models/6. operations/pumps/` umbrella) is a narrow, frozen, machine-consumed delivery contract with an enforced dbt contract (explicit column types). It previously consumed `mart_commerce__customer_360`, which forced Operational through a linear Core -> Logical -> Marts -> Reporting -> Operational chain. It now reads `core.customer`, `marts.fct_order`, and `core.customer_marketing_exclusion` directly -- the shortest sensible trusted path -- and must never depend on Reporting. The small order-activity aggregation this model shares with `reporting.customer_360` was judged too trivial (a five-line `group by`) to extract into a shared Logical model under the rule of two; see docs/architecture.md.

## Quality Controls Are Cross-Cutting, Not A Layer

There is no generic `models/6. operations` serving layer. Tests, freshness, contracts, ownership, documentation, certification, and observability are cross-cutting concerns applied across every layer, expressed as YAML-declared tests/contracts/freshness on the models they protect, plus singular tests under `data-tests/quality/`. `models/6. operations/ops_order_count_reconciliation.sql` was removed because it provided nothing that `data-tests/quality/assert_order_count_reconciles.sql` couldn't compute itself as a self-contained singular test; keeping both was a needless extra materialized model in the serving path.

## The Manual Inputs Pattern

Not every governed business input is a raw system source or a static seed. `core.customer_marketing_exclusion` demonstrates the distinction: static, code-owned reference data can be a dbt seed (the ecom fixtures), while real business-maintained inputs (manual corrections, exclusions, overrides) belong in a governed Inputs location -- in production, `RAW.INPUTS.CUSTOMER_MARKETING_EXCLUSIONS`, populated by a governed process, with auditable validity windows (`valid_from`/`valid_to`) and ownership (`updated_by`/`updated_at`). The local `seeds/inputs/raw_customer_marketing_exclusions.csv` is declared as a proper dbt `source` (not an undocumented ad-hoc table bypassing modelling), materializes into its own local `inputs` schema (`inputs.raw_customer_marketing_exclusions`, distinct from the `raw` schema used by ordinary application seeds), and is a **fixture that demonstrates that production contract**, not a claim that every manual input becomes a seed. It flows `inputs.raw_customer_marketing_exclusions -> stg_inputs__customer_marketing_exclusions -> core.customer_marketing_exclusion -> operational.customer_marketing_eligibility`: staging reads the source directly (`models/1. staging/inputs/stg_inputs__customer_marketing_exclusions.sql`) and never through Landing or the JSON/CDC simulation models -- Manual Inputs bypass Landing by design, since they are not a CDC feed. Core treats it the same way as other source-native relationship records like `core.customer_address`.

## Model Maturity Is Orthogonal To Layer

Layer says where a model sits in the dependency chain; maturity (`meta.maturity`: `private` / `reusable` / `certified` / `consumer_specific`) says how safe it is to build on. They are set independently: Staging and Systems default to `private`; Logical defaults to `reusable`; Core, Marts facts, Semantic, and Operational default to `certified`; Reporting defaults to `consumer_specific`; Marts dimensions default to `reusable` rather than automatically `certified`, since a dimension's attribute selection is a deliberate analytical choice rather than an unambiguous canonical shape. See docs/architecture.md for the full table and the reasoning behind certifying every Core model in this specific (small, deliberately-scoped) reference.

## DuckDB (Local) Vs Snowflake (Production) Schema Mapping

`macros/generate_schema_name.sql` is target-aware: local DuckDB `dev` gets flat schemas that map 1:1 onto layer names (no `main_` or target-name prefix, since there is only one developer and one file); any other target (a shared Snowflake-style environment) falls back to dbt's default environment-safe `<target_schema>_<custom>` prefixing so concurrent developers/CI don't collide. The intended production Snowflake layout (`RAW.<source>` / `RAW.INPUTS`, `PRD.LANDING` / `PRD.STAGING` / `PRD.SYSTEMS` / `PRD.CORE` / `PRD.LOGICAL` / `PRD.MARTS` / `PRD.REPORTING` / `PRD.SEMANTIC` / `PRD.OPERATIONAL`) is documented rather than implemented, since it cannot be meaningfully faked against a single local DuckDB file. The local `source_json` layer (`ext_*` models) is local CDC-simulation machinery only, with no separate `PRD.SOURCE_JSON` production counterpart -- see docs/architecture.md's mapping table.

## Semantic Definitions Are Separate, Current, And Trusted

Semantic YAML lives under `models/5b. semantic/` and uses the dbt Core 1.12+ model-attached `semantic_model` pattern, not legacy top-level `semantic_models` and `measures`. It attaches Customer identity metadata to `core.customer` (narrow, no order-derived time dimension), Customer repeat-order behavioural metadata/metrics to `marts.dim_customer` (re-pointed here after the Core cleanup -- `repeat_customer_count` can no longer read `core.customer`), Order metrics to `marts.fct_order`, and line-grain metadata to `marts.fct_order_line`. The semantic YAML deliberately avoids Staging, Systems, Logical, Landing, and Reporting models so metric consumers are insulated from implementation details and from the terminal Reporting leaf. Metric metadata declares permitted dimensions/entities explicitly under `config.meta.permitted_dimensions`.

## Identity And Address Guardrails

Users and addresses are executable canonical patterns in the playground. A User relates to Customer through `core.customer_user` instead of being assumed to belong to exactly one customer. Addresses relate to Customer through `core.customer_address`, while orders retain `core.order_address_snapshot` as an immutable purchase-time snapshot rather than relying on a mutable current address. Payment belongs to Order, so payment records and facts should not redundantly carry Customer or Product keys unless a specific downstream contract requires denormalization.
