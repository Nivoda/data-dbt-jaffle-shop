{{ config(alias='order_line') }}

-- core.order_line is the canonical source order-line record, built directly from
-- staging (not derived via Logical). Commercial interpretation such as extended
-- line amounts and joining to product for price/name context belongs in
-- logical.order_line_amounts, which reads core.order_line + core.product.
with order_lines as (
    select * from {{ ref('stg_ecom__order_lines') }}
),

orders as (
    select
        order_sk,
        order_id
    from {{ ref('order') }}
),

products as (
    select
        product_sk,
        product_id
    from {{ ref('product') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['order_lines.order_line_id']) }} as order_line_sk,
    order_lines.order_line_id,
    orders.order_sk,
    products.product_sk,
    order_lines.order_id,
    order_lines.product_id,
    order_lines.quantity,
    order_lines.source_record_id,
    order_lines.source_ingested_at,
    order_lines.source_updated_at
from order_lines
left join orders on order_lines.order_id = orders.order_id
left join products on order_lines.product_id = products.product_id
