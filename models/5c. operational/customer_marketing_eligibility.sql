{{ config(alias='customer_marketing_eligibility', contract={'enforced': true}) }}

-- Consumes core.customer + marts.fct_order + core.customer_marketing_exclusion
-- directly -- the shortest sensible trusted path. It must NOT depend on
-- reporting.customer_360 (Operational is refactored away from the old linear
-- Reporting -> Operational chain). The order-activity aggregation below is a
-- small (5-line) GROUP BY that also appears in reporting.customer_360; per the
-- "rule of two" this is judged too trivial to justify a new shared Logical
-- model purely to deduplicate it -- see docs/architecture.md.
with customers as (
    select * from {{ ref('customer') }}
),

orders as (
    select * from {{ ref('fct_order') }}
),

order_activity as (
    select
        customer_sk,
        min(ordered_at) as first_ordered_at,
        max(ordered_at) as last_ordered_at,
        count(*) as order_count,
        sum(case when is_completed_order then 1 else 0 end) as completed_order_count,
        sum(case when is_completed_order then captured_paid_amount else 0 end) as completed_revenue,
        max(case when is_repeat_order then 1 else 0 end) = 1 as has_repeat_order
    from orders
    group by 1
),

current_exclusions as (
    select
        customer_id,
        is_excluded,
        exclusion_reason
    from {{ ref('customer_marketing_exclusion') }}
    where valid_to is null
)

select
    cast(customers.customer_id as varchar) as customer_id,
    cast(customers.customer_name as varchar) as customer_name,
    cast(order_activity.first_ordered_at as timestamp) as first_ordered_at,
    cast(order_activity.last_ordered_at as timestamp) as last_ordered_at,
    cast(coalesce(order_activity.order_count, 0) as integer) as order_count,
    cast(coalesce(order_activity.completed_order_count, 0) as integer) as completed_order_count,
    cast(coalesce(order_activity.completed_revenue, 0) as decimal(16, 2)) as completed_revenue,
    cast(
        coalesce(order_activity.completed_order_count, 0) >= 1
        and coalesce(order_activity.completed_revenue, 0) > 0
        and coalesce(order_activity.has_repeat_order, false) = false
        and coalesce(current_exclusions.is_excluded, false) = false
    as boolean) as is_eligible_for_post_purchase_journey,
    cast(case
        when coalesce(current_exclusions.is_excluded, false) then 'exclude_manual_marketing_exclusion'
        when coalesce(order_activity.completed_order_count, 0) = 0 then 'exclude_no_completed_purchase'
        when coalesce(order_activity.completed_revenue, 0) <= 0 then 'exclude_no_revenue'
        when coalesce(order_activity.has_repeat_order, false) then 'exclude_existing_repeat_customer'
        else 'eligible'
    end as varchar) as eligibility_reason,
    cast({{ cast_timestamp("'2024-09-02 09:00:00'") }} as timestamp) as _pumped_at
from customers
left join order_activity on customers.customer_sk = order_activity.customer_sk
left join current_exclusions on customers.customer_id = current_exclusions.customer_id
