-- Protects operational reconciliation by flagging captured payment totals above the related order total.
select
    orders.order_id,
    orders.order_total_cents,
    sum(payments.payment_amount_cents) as paid_amount_cents
from {{ ref('order') }} as orders
inner join {{ ref('payment') }} as payments on orders.order_id = payments.order_id
where payments.source_payment_status = 'captured'
group by 1, 2
having sum(payments.payment_amount_cents) > orders.order_total_cents
