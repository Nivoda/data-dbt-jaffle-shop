{{ config(alias='rpt_customer_commercial_summary') }}

with customers as (
    select * from {{ ref('obj_customer') }}
),

orders as (
    select * from {{ ref('fct_order') }}
),

customer_order_summary as (
    select
        customer_id,
        count(*) as order_count,
        sum(case when is_completed_order then 1 else 0 end) as completed_order_count,
        sum(order_total) as gross_revenue,
        sum(case when is_completed_order then captured_paid_amount else 0 end) as completed_revenue,
        max(case when is_repeat_order then 1 else 0 end) = 1 as has_repeat_order,
        min(ordered_at) as first_ordered_at,
        max(ordered_at) as last_ordered_at
    from orders
    group by 1
)

select
    customers.customer_sk,
    customers.customer_id,
    customers.customer_name,
    customer_order_summary.first_ordered_at,
    customer_order_summary.last_ordered_at,
    coalesce(customer_order_summary.order_count, 0) as order_count,
    coalesce(customer_order_summary.completed_order_count, 0) as completed_order_count,
    coalesce(customer_order_summary.gross_revenue, 0) as gross_revenue,
    coalesce(customer_order_summary.completed_revenue, 0) as completed_revenue,
    coalesce(customer_order_summary.has_repeat_order, false) as has_repeat_order,
    coalesce(customer_order_summary.order_count, 0) > 1 as is_repeat_customer
from customers
left join customer_order_summary on customers.customer_id = customer_order_summary.customer_id
