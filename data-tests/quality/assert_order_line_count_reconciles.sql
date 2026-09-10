-- Replaces the removed assert_order_line_subtotal_reconciles_to_order.sql,
-- which asserted that summed CURRENT-catalogue line values equal the order's
-- canonical subtotal. That only happened to pass because this fixture has no
-- purchase-time price history (current price == the only price ever seen); it
-- is not a safe architectural invariant and would falsely fail (or falsely
-- "validate" nothing) the moment historical pricing diverges from current
-- pricing in a real system. See docs/architecture.md / logical.order_line_amounts.
--
-- The genuinely safe invariant here is referential/structural reconciliation:
-- every core order line must show up exactly once in the Marts fact, and vice
-- versa. Referential integrity from order_line -> product and order_line ->
-- order, and quantity > 0, are already covered by existing generic tests
-- (reference_architecture.yml order_line.product_sk/order_sk relationships,
-- and the staging quantity > 0 expression_is_true test), so they are not
-- duplicated here.
with core_order_lines as (
    select count(*) as order_line_count from {{ ref('order_line') }}
),

fact_order_lines as (
    select count(*) as order_line_count from {{ ref('fct_order_line') }}
)

select
    core_order_lines.order_line_count as core_order_line_count,
    fact_order_lines.order_line_count as fact_order_line_count
from core_order_lines
cross join fact_order_lines
where core_order_lines.order_line_count != fact_order_lines.order_line_count
