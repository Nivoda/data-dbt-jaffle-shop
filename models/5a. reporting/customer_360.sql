{{ config(alias='customer_360') }}

-- Consumes marts.dim_customer and marts.fct_order directly: both are already
-- reusable, general-purpose marts (not purpose-built for this report), so this
-- is the shortest sensible trusted path -- there is nothing Core/Logical would
-- add here that dim_customer/fct_order don't already provide.
with customer_dimension as (
    select * from {{ ref('dim_customer') }}
),

orders as (
    select * from {{ ref('fct_order') }}
),

customer_commercial_position as (
    select
        customer_sk,
        min(ordered_at) as first_ordered_at,
        max(ordered_at) as last_ordered_at,
        count(*) as order_count,
        sum(case when is_completed_order then 1 else 0 end) as completed_order_count,
        sum(order_total) as gross_revenue,
        sum(case when is_completed_order then captured_paid_amount else 0 end) as completed_revenue,
        max(case when is_repeat_order then 1 else 0 end) = 1 as has_repeat_order
    from orders
    group by 1
)

select
    customer_dimension.customer_sk,
    customer_dimension.customer_id,
    customer_dimension.customer_name,
    customer_dimension.primary_email_address,
    customer_dimension.primary_phone_number,
    customer_dimension.default_city,
    customer_dimension.default_state,
    customer_dimension.default_country_code,
    customer_commercial_position.first_ordered_at,
    customer_commercial_position.last_ordered_at,
    coalesce(customer_commercial_position.order_count, 0) as order_count,
    coalesce(customer_commercial_position.completed_order_count, 0) as completed_order_count,
    coalesce(customer_commercial_position.gross_revenue, 0) as gross_revenue,
    coalesce(customer_commercial_position.completed_revenue, 0) as completed_revenue,
    coalesce(customer_commercial_position.has_repeat_order, false) as has_repeat_order,
    customer_dimension.is_repeat_customer,
    case
        when coalesce(customer_commercial_position.completed_revenue, 0) >= 100 then 'high_value'
        when coalesce(customer_commercial_position.completed_revenue, 0) > 0 then 'active_value'
        else 'no_completed_revenue'
    end as customer_value_band,
    customer_dimension.primary_email_address is not null as is_email_contactable,
    customer_dimension.primary_phone_number is not null as is_phone_contactable
from customer_dimension
left join customer_commercial_position on customer_dimension.customer_sk = customer_commercial_position.customer_sk
