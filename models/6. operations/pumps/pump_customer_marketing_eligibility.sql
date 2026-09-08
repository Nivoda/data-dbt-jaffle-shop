{{ config(alias='pump_customer_marketing_eligibility', contract={'enforced': true}) }}

with customers as (
    select * from {{ ref('rpt_customer_commercial_summary') }}
)

select
    cast(customer_id as varchar) as customer_id,
    cast(customer_name as varchar) as customer_name,
    cast(first_ordered_at as timestamp) as first_ordered_at,
    cast(last_ordered_at as timestamp) as last_ordered_at,
    cast(order_count as integer) as order_count,
    cast(completed_order_count as integer) as completed_order_count,
    cast(completed_revenue as decimal(16, 2)) as completed_revenue,
    cast(completed_order_count >= 1
        and completed_revenue > 0
        and has_repeat_order = false as boolean) as is_eligible_for_post_purchase_journey,
    cast(case
        when completed_order_count = 0 then 'exclude_no_completed_purchase'
        when completed_revenue <= 0 then 'exclude_no_revenue'
        when has_repeat_order then 'exclude_existing_repeat_customer'
        else 'eligible'
    end as varchar) as eligibility_reason,
    cast({{ cast_timestamp("'2024-09-02 09:00:00'") }} as timestamp) as _pumped_at
from customers
