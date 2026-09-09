{{ config(alias='fct_order_line') }}

with order_lines as (
    select * from {{ ref('order_line') }}
),

order_line_amounts as (
    select * from {{ ref('int_order_line_amounts') }}
),

orders as (
    select
        order_sk,
        customer_sk,
        order_id,
        ordered_at
    from {{ ref('order') }}
),

order_payment_position as (
    select
        order_id,
        order_commercial_status
    from {{ ref('int_order_payment_position') }}
)

select
    order_lines.order_line_sk,
    order_lines.order_line_id,
    order_lines.order_sk,
    order_lines.product_sk,
    orders.customer_sk,
    order_lines.order_id,
    order_lines.product_id,
    order_line_amounts.current_product_name,
    orders.ordered_at,
    order_payment_position.order_commercial_status,
    order_lines.quantity,
    order_line_amounts.unit_price_cents,
    order_line_amounts.unit_price,
    order_line_amounts.line_amount_cents,
    order_line_amounts.line_amount
from order_lines
left join order_line_amounts on order_lines.order_line_id = order_line_amounts.order_line_id
left join orders on order_lines.order_sk = orders.order_sk
left join order_payment_position on orders.order_id = order_payment_position.order_id
