-- Protects commercial metrics by ensuring no zero-value order is counted as a completed revenue event.
select
    order_id,
    order_total_cents,
    payment_operational_status,
    order_commercial_status,
    is_completed_order
from {{ ref('int_commerce__order_payment_position') }}
where order_total_cents = 0
  and is_completed_order
