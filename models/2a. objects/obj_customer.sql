{{ config(alias='obj_customer') }}

with customers as (
    select * from {{ ref('stg_ecom__customers') }}
),

customer_order_sequence as (
    select
        customer_id,
        max(lifetime_order_count) as lifetime_order_count,
        min(first_ordered_at) as first_ordered_at,
        max(last_ordered_at) as last_ordered_at,
        max(case when is_repeat_customer then 1 else 0 end) = 1 as is_repeat_customer
    from {{ ref('int_commerce__customer_order_sequence') }}
    group by 1
)

select
    {{ dbt_utils.generate_surrogate_key(['customers.customer_id']) }} as customer_sk,
    customers.customer_id,
    customers.customer_name,
    customer_order_sequence.first_ordered_at,
    customer_order_sequence.last_ordered_at,
    coalesce(customer_order_sequence.lifetime_order_count, 0) as lifetime_order_count,
    coalesce(customer_order_sequence.is_repeat_customer, false) as is_repeat_customer,
    customers.source_record_id,
    customers.source_ingested_at,
    customers.source_updated_at
from customers
left join customer_order_sequence on customers.customer_id = customer_order_sequence.customer_id
