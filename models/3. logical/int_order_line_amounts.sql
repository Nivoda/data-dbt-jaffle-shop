{{ config(alias='order_line_amounts') }}

-- Retargeted to read core.order_line + core.product (not staging) so dependency
-- direction is Staging -> Core -> Logical, never the reverse.
-- NOTE ON NAMING: product_name / unit_price here are the CURRENT product record
-- joined onto the order line at transformation time, not a historical
-- at-purchase snapshot. The seed/source data carries no purchase-time price or
-- name history, so we do not claim a snapshot semantic -- if the source ever
-- captures price/name as of the purchase moment, this column should be renamed
-- to make that snapshot explicit (e.g. product_name_at_purchase).
with order_lines as (
    select * from {{ ref('order_line') }}
),

products as (
    select * from {{ ref('product') }}
)

select
    order_lines.order_line_id,
    order_lines.order_id,
    order_lines.product_id,
    products.product_name as current_product_name,
    order_lines.quantity,
    products.product_price_cents as unit_price_cents,
    products.product_price as unit_price,
    order_lines.quantity * products.product_price_cents as line_amount_cents,
    order_lines.quantity * products.product_price as line_amount,
    order_lines.source_record_id,
    order_lines.source_ingested_at,
    order_lines.source_updated_at
from order_lines
left join products on order_lines.product_id = products.product_id
