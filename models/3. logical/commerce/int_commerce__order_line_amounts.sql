{{ config(alias='int_commerce__order_line_amounts') }}

with order_lines as (
    select * from {{ ref('stg_ecom__order_lines') }}
),

products as (
    select * from {{ ref('stg_ecom__products') }}
)

select
    order_lines.order_line_id,
    order_lines.order_id,
    order_lines.product_id,
    products.product_name as product_name_snapshot,
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
