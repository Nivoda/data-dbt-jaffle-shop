{{ config(alias='customer_order_sequence') }}

-- Retargeted to read core.order (not staging) so dependency direction is
-- Staging -> Core -> Logical, never the reverse.
with orders as (
    select * from {{ ref('order') }}
),

sequenced as (
    select
        orders.*,
        row_number() over (
            partition by customer_id
            order by ordered_at, order_id
        ) as customer_order_number
    from orders
),

history as (
    select
        customer_id,
        count(*) as lifetime_order_count,
        min(ordered_at) as first_ordered_at,
        max(ordered_at) as last_ordered_at
    from orders
    group by 1
)

select
    sequenced.order_id,
    sequenced.customer_id,
    sequenced.ordered_at,
    sequenced.customer_order_number,
    sequenced.customer_order_number = 1 as is_first_order,
    sequenced.customer_order_number > 1 as is_repeat_order,
    history.lifetime_order_count,
    history.first_ordered_at,
    history.last_ordered_at,
    history.lifetime_order_count > 1 as is_repeat_customer
from sequenced
inner join history on sequenced.customer_id = history.customer_id
