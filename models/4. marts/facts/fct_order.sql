{{ config(alias='fct_order') }}

with orders as (
    select * from {{ ref('obj_order') }}
),

order_payment_position as (
    select * from {{ ref('int_commerce__order_payment_position') }}
),

customer_order_sequence as (
    select * from {{ ref('int_commerce__customer_order_sequence') }}
),

order_line_summary as (
    select
        order_sk,
        count(*) as order_line_count,
        sum(quantity) as item_quantity,
        sum(line_amount_cents) as merchandise_subtotal_cents,
        sum(line_amount) as merchandise_subtotal
    from {{ ref('obj_order_line') }}
    group by 1
)

select
    orders.order_sk,
    orders.customer_sk,
    orders.order_id,
    orders.customer_id,
    orders.store_id,
    orders.ordered_at,
    orders.subtotal_cents,
    orders.tax_paid_cents,
    orders.order_total_cents,
    orders.subtotal,
    orders.tax_paid,
    orders.order_total,
    coalesce(order_line_summary.order_line_count, 0) as order_line_count,
    coalesce(order_line_summary.item_quantity, 0) as item_quantity,
    coalesce(order_line_summary.merchandise_subtotal_cents, 0) as merchandise_subtotal_cents,
    coalesce(order_line_summary.merchandise_subtotal, 0) as merchandise_subtotal,
    order_payment_position.total_payment_attempt_count,
    order_payment_position.pending_payment_count,
    order_payment_position.total_attempted_amount_cents,
    order_payment_position.total_attempted_amount,
    order_payment_position.captured_paid_amount_cents,
    order_payment_position.captured_paid_amount,
    order_payment_position.captured_payment_completeness,
    order_payment_position.latest_payment_at,
    order_payment_position.latest_captured_payment_at,
    order_payment_position.has_captured_payment,
    order_payment_position.payment_operational_status,
    order_payment_position.order_commercial_status,
    order_payment_position.is_completed_order,
    order_payment_position.is_overpaid,
    order_payment_position.requires_reconciliation,
    customer_order_sequence.customer_order_number,
    customer_order_sequence.is_first_order,
    customer_order_sequence.is_repeat_order
from orders
inner join order_payment_position on orders.order_id = order_payment_position.order_id
inner join customer_order_sequence on orders.order_id = customer_order_sequence.order_id
left join order_line_summary on orders.order_sk = order_line_summary.order_sk
