{{ config(alias='customer') }}

-- Core Customer is the canonical entity only: identity plus source metadata.
-- Order-derived behavioural attributes (first/last ordered_at, lifetime_order_count,
-- is_repeat_customer) do not belong here because they would make the canonical
-- Customer record change shape based on order activity. That reusable order-sequence
-- interpretation now lives in logical.customer_order_sequence and is surfaced for
-- analytics in marts.dim_customer.
with customers as (
    select * from {{ ref('stg_ecom__customers') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['customers.customer_id']) }} as customer_sk,
    customers.customer_id,
    customers.customer_name,
    customers.source_record_id,
    customers.source_ingested_at,
    customers.source_updated_at
from customers
