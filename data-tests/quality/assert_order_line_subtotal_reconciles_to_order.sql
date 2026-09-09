with order_line_summary as (
    select
        order_id,
        sum(line_amount_cents) as merchandise_subtotal_cents
    from {{ ref('int_order_line_amounts') }}
    group by 1
)

select
    orders.order_id,
    orders.subtotal_cents as order_subtotal_cents,
    coalesce(order_line_summary.merchandise_subtotal_cents, 0) as line_subtotal_cents
from {{ ref('order') }} as orders
left join order_line_summary on orders.order_id = order_line_summary.order_id
where orders.subtotal_cents != coalesce(order_line_summary.merchandise_subtotal_cents, 0)
