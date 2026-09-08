{{ config(alias='obj_order_line') }}

with order_line_amounts as (
    select * from {{ ref('int_commerce__order_line_amounts') }}
),

orders as (
    select
        order_sk,
        order_id
    from {{ ref('obj_order') }}
),

products as (
    select
        product_sk,
        product_id
    from {{ ref('obj_product') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['order_line_amounts.order_line_id']) }} as order_line_sk,
    order_line_amounts.order_line_id,
    orders.order_sk,
    products.product_sk,
    order_line_amounts.order_id,
    order_line_amounts.product_id,
    order_line_amounts.product_name_snapshot,
    order_line_amounts.quantity,
    order_line_amounts.unit_price_cents,
    order_line_amounts.unit_price,
    order_line_amounts.line_amount_cents,
    order_line_amounts.line_amount,
    order_line_amounts.source_record_id,
    order_line_amounts.source_ingested_at,
    order_line_amounts.source_updated_at
from order_line_amounts
left join orders on order_line_amounts.order_id = orders.order_id
left join products on order_line_amounts.product_id = products.product_id
