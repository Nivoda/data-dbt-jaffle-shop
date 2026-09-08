{{ config(alias='fct_order_line') }}

with order_lines as (
    select * from {{ ref('obj_order_line') }}
),

orders as (
    select
        order_sk,
        customer_sk,
        order_id,
        ordered_at
    from {{ ref('obj_order') }}
),

order_payment_position as (
    select
        order_id,
        order_commercial_status
    from {{ ref('int_commerce__order_payment_position') }}
)

select
    order_lines.order_line_sk,
    order_lines.order_line_id,
    order_lines.order_sk,
    order_lines.product_sk,
    orders.customer_sk,
    order_lines.order_id,
    order_lines.product_id,
    order_lines.product_name_snapshot,
    orders.ordered_at,
    order_payment_position.order_commercial_status,
    order_lines.quantity,
    order_lines.unit_price_cents,
    order_lines.unit_price,
    order_lines.line_amount_cents,
    order_lines.line_amount
from order_lines
left join orders on order_lines.order_sk = orders.order_sk
left join order_payment_position on orders.order_id = order_payment_position.order_id
