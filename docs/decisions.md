# Decisions And Deliberately Avoided Anti-Patterns

## Remove Starter Models From Active Model Paths

The original Jaffle Shop starter marts and staging models are removed from active model paths. This avoids retaining parallel staging or mart structures that make the reference architecture ambiguous.

## Source / JSON Landing Keeps Source Fidelity

JSON/CDC-shaped records are generated from explicit ecom raw seed tables. The architecture playground includes first-class seeds for users, customer-user relationships, addresses, customer-address relationships, and immutable order address snapshots so those canonical chains are executable rather than only documented. Payments are still derived from orders because the starter data has no payment seed, and `raw_items` is one row per purchased item, so order-line quantity is represented as `1`.

## Landing Owns Currentness

Current-record selection happens only in landing. The deterministic winner order is source update timestamp, ingestion timestamp, then ingestion event id. Staging, logical, objects, marts, pumps, and semantic definitions do not redo CDC deduplication.

## Systems Are Access Views, Not Transformation Models

Systems branch directly from staging and use only `dbt_utils.star()` projections. They do not join, aggregate, filter, classify, assign surrogate keys, or create business contracts. Systems are terminal access views and never feed logical, objects, marts, pumps, or semantic definitions. Stable contracts belong in objects, marts, and pumps.

## Logical Models Use The `int_` Prefix

The architectural layer is named logical, but models follow standard dbt intermediate naming. `int_commerce__order_payment_position` centralizes order/payment joins and statuses, `int_commerce__customer_order_sequence` centralizes first/repeat order logic, and `int_commerce__order_line_amounts` centralizes the product/order-line join needed for reusable at-purchase line calculations. Payment completeness and commercial status are based on captured payment value only, so pending non-zero payment attempts cannot create completed orders or settled revenue. Zero-value orders are explicitly `no_charge` / `not_required`; they are not completed revenue events.

## Objects Are Canonical, Not Reports

`obj_customer`, `obj_user`, `obj_customer_user`, `obj_address`, `obj_customer_address`, `obj_order_address_snapshot`, `obj_order`, `obj_payment`, `obj_product`, and `obj_order_line` expose durable business concepts at stable grains. `obj_customer` acts as the reusable customer identity and relationship anchor for semantic relationships and downstream marts.

`obj_customer` is the sole authority for `customer_sk`. Orders join to `obj_customer` to carry the canonical Customer key into `obj_order`, and marts select that key from objects instead of regenerating it from source identifiers.

`obj_product` is the sole authority for `product_sk`. `obj_order_line` carries `order_sk` from `obj_order` and `product_sk` from `obj_product`, so downstream facts inherit canonical relationship keys rather than rebuilding them from natural identifiers.

## Marts Are Consumption Models

Marts contain analytical facts, dimensions, and purpose-specific reports or decision marts. This reference keeps `fct_order`, `fct_order_line`, `dim_customer`, `rpt_customer_commercial_summary`, and `mart_commerce__customer_360`. It still does not manufacture a product dimension because the canonical Product object is enough for the current analytical surface.

## Dimensions Are A Mart Subtype, Not Object Synonyms

`dim_*` models belong to the mart layer when there is a real dimensional-consumption requirement. They are not automatically created for every canonical object. In this reference, `obj_customer` is the canonical customer identity and relationship anchor, and `fct_order` references `obj_customer.customer_sk` directly.

`dim_customer` now exists because it has a distinct purpose: it resolves a current analytical customer contact/address shape through canonical identity and relationship objects. A future `dim_product` should be introduced only when it has a similarly distinct purpose, such as an explicit SCD policy, role-playing usage, a deliberately selected analytical attribute set, or a performance/BI-consumption need. The project deliberately avoids duplicating an object as a dimension when the two models would be materially identical.

## Pumps Are Operations Delivery Contracts

`pump_customer_marketing_eligibility` lives under `models/operations/pumps/`, consumes only marts, exposes `_pumped_at`, and uses an enforced dbt contract with explicit column types. It is a narrow machine-consumed contract, not a report renamed as an extract.

## Semantic Definitions Are Separate, Current, And Trusted

Semantic YAML lives under `models/5. semantic/` and uses the dbt Core 1.12+ model-attached `semantic_model` pattern, not legacy top-level `semantic_models` and `measures`. It attaches Customer metadata to `obj_customer`, Order metrics to `fct_order`, and line-grain metadata to `fct_order_line`, deliberately avoiding staging, systems, logical, landing, and Source / JSON landing models so metric consumers are insulated from implementation details. Metric metadata declares permitted dimensions/entities explicitly under `config.meta.permitted_dimensions`.

## Identity And Address Guardrails

Users and addresses are now executable canonical patterns in the playground. A User relates to Customer through `obj_customer_user` instead of being assumed to belong to exactly one customer. Addresses relate to Customer through `obj_customer_address`, while orders retain `obj_order_address_snapshot` as an immutable purchase-time snapshot rather than relying on a mutable current address. Payment belongs to Order, so payment objects and facts should not redundantly carry Customer or Product keys unless a specific downstream contract requires denormalization.
