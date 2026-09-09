{{ config(alias='order_address_snapshot') }}

with snapshots as (
    select * from {{ ref('stg_ecom__order_address_snapshots') }}
),

orders as (
    select
        order_sk,
        order_id
    from {{ ref('order') }}
),

customers as (
    select
        customer_sk,
        customer_id
    from {{ ref('customer') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['snapshots.order_address_snapshot_id']) }} as order_address_snapshot_sk,
    snapshots.order_address_snapshot_id,
    orders.order_sk,
    customers.customer_sk,
    snapshots.order_id,
    snapshots.customer_id,
    snapshots.source_address_id,
    snapshots.address_line_1,
    snapshots.city,
    snapshots.state,
    snapshots.postal_code,
    snapshots.country_code,
    snapshots.captured_at,
    snapshots.source_record_id,
    snapshots.source_ingested_at,
    snapshots.source_updated_at
from snapshots
left join orders on snapshots.order_id = orders.order_id
left join customers on snapshots.customer_id = customers.customer_id
