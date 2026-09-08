{{ config(alias='obj_order') }}

with orders as (
    select * from {{ ref('stg_ecom__orders') }}
),

customers as (
    select
        customer_sk,
        customer_id
    from {{ ref('obj_customer') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['orders.order_id']) }} as order_sk,
    orders.order_id,
    customers.customer_sk,
    orders.customer_id,
    orders.store_id,
    orders.ordered_at,
    orders.subtotal_cents,
    orders.tax_paid_cents,
    orders.order_total_cents,
    orders.subtotal,
    orders.tax_paid,
    orders.order_total,
    orders.source_record_id,
    orders.source_ingested_at,
    orders.source_updated_at
from orders
left join customers on orders.customer_id = customers.customer_id
