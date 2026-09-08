{{ config(alias='mart_commerce__customer_360') }}

with customer_dimension as (
    select * from {{ ref('dim_customer') }}
),

commercial_summary as (
    select * from {{ ref('rpt_customer_commercial_summary') }}
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
    commercial_summary.first_ordered_at,
    commercial_summary.last_ordered_at,
    commercial_summary.order_count,
    commercial_summary.completed_order_count,
    commercial_summary.gross_revenue,
    commercial_summary.completed_revenue,
    commercial_summary.has_repeat_order,
    customer_dimension.is_repeat_customer,
    case
        when commercial_summary.completed_revenue >= 100 then 'high_value'
        when commercial_summary.completed_revenue > 0 then 'active_value'
        else 'no_completed_revenue'
    end as customer_value_band,
    customer_dimension.primary_email_address is not null as is_email_contactable,
    customer_dimension.primary_phone_number is not null as is_phone_contactable
from customer_dimension
left join commercial_summary on customer_dimension.customer_sk = commercial_summary.customer_sk
