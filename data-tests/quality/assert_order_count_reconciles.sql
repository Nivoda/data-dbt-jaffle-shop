-- Protects against accidental filtering or fanout between trusted staging, core, and fact order paths.
-- This is a self-contained singular test: it used to rely on a dedicated
-- models/6. operations/ops_order_count_reconciliation.sql model, but that model
-- provided nothing this test couldn't compute itself, so it was removed (quality
-- controls are cross-cutting, not a layer -- see docs/architecture.md).
with staging_orders as (
    select count(*) as order_count from {{ ref('stg_ecom__orders') }}
),

core_orders as (
    select count(*) as order_count from {{ ref('order') }}
),

fact_orders as (
    select count(*) as order_count from {{ ref('fct_order') }}
)

select
    staging_orders.order_count as staging_order_count,
    core_orders.order_count as core_order_count,
    fact_orders.order_count as fact_order_count
from staging_orders
cross join core_orders
cross join fact_orders
where not (
    staging_orders.order_count = core_orders.order_count
    and core_orders.order_count = fact_orders.order_count
)
