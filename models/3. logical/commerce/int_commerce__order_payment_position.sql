{{ config(alias='int_commerce__order_payment_position') }}

with orders as (
    select * from {{ ref('stg_ecom__orders') }}
),

payments as (
    select * from {{ ref('stg_ecom__payments') }}
),

payment_rollup as (
    select
        order_id,
        count(*) as total_payment_attempt_count,
        sum(case when source_payment_status = 'pending' then 1 else 0 end) as pending_payment_count,
        sum(payment_amount_cents) as total_attempted_amount_cents,
        sum(payment_amount) as total_attempted_amount,
        sum(case when source_payment_status = 'captured' then payment_amount_cents else 0 end) as captured_paid_amount_cents,
        sum(case when source_payment_status = 'captured' then payment_amount else 0 end) as captured_paid_amount,
        max(paid_at) as latest_payment_at,
        max(case when source_payment_status = 'captured' then paid_at end) as latest_captured_payment_at,
        max(case when source_payment_status = 'captured' then 1 else 0 end) = 1 as has_captured_payment
    from payments
    group by 1
)

select
    orders.order_id,
    orders.customer_id,
    orders.ordered_at,
    orders.order_total_cents,
    orders.order_total,
    coalesce(payment_rollup.total_payment_attempt_count, 0) as total_payment_attempt_count,
    coalesce(payment_rollup.pending_payment_count, 0) as pending_payment_count,
    coalesce(payment_rollup.total_attempted_amount_cents, 0) as total_attempted_amount_cents,
    coalesce(payment_rollup.total_attempted_amount, 0) as total_attempted_amount,
    coalesce(payment_rollup.captured_paid_amount_cents, 0) as captured_paid_amount_cents,
    coalesce(payment_rollup.captured_paid_amount, 0) as captured_paid_amount,
    case
        when orders.order_total_cents = 0 then null
        else coalesce(payment_rollup.captured_paid_amount_cents, 0)::numeric / orders.order_total_cents
    end as captured_payment_completeness,
    payment_rollup.latest_payment_at,
    payment_rollup.latest_captured_payment_at,
    coalesce(payment_rollup.has_captured_payment, false) as has_captured_payment,
    case
        when orders.order_total_cents = 0 then 'not_required'
        when coalesce(payment_rollup.captured_paid_amount_cents, 0) = 0 then 'unpaid'
        when payment_rollup.captured_paid_amount_cents < orders.order_total_cents then 'partially_paid'
        when payment_rollup.captured_paid_amount_cents = orders.order_total_cents then 'paid'
        when payment_rollup.captured_paid_amount_cents > orders.order_total_cents then 'overpaid'
    end as payment_operational_status,
    case
        when orders.order_total_cents = 0 then 'no_charge'
        when coalesce(payment_rollup.captured_paid_amount_cents, 0) = orders.order_total_cents then 'completed'
        when coalesce(payment_rollup.captured_paid_amount_cents, 0) < orders.order_total_cents then 'open'
        when payment_rollup.captured_paid_amount_cents > orders.order_total_cents then 'exception'
        else 'unknown'
    end as order_commercial_status,
    orders.order_total_cents > 0
        and coalesce(payment_rollup.captured_paid_amount_cents, 0) = orders.order_total_cents as is_completed_order,
    coalesce(payment_rollup.captured_paid_amount_cents, 0) > orders.order_total_cents as is_overpaid,
    coalesce(payment_rollup.captured_paid_amount_cents, 0) > orders.order_total_cents as requires_reconciliation
from orders
left join payment_rollup on orders.order_id = payment_rollup.order_id
