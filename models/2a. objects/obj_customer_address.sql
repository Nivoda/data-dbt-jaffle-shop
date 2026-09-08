{{ config(alias='obj_customer_address') }}

with customer_addresses as (
    select * from {{ ref('stg_ecom__customer_addresses') }}
),

customers as (
    select
        customer_sk,
        customer_id
    from {{ ref('obj_customer') }}
),

addresses as (
    select
        address_sk,
        address_id
    from {{ ref('obj_address') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_addresses.customer_address_relationship_id']) }} as customer_address_sk,
    customer_addresses.customer_address_relationship_id,
    customers.customer_sk,
    addresses.address_sk,
    customer_addresses.customer_id,
    customer_addresses.address_id,
    customer_addresses.address_usage,
    customer_addresses.is_default_address,
    customer_addresses.valid_from,
    customer_addresses.valid_to,
    customer_addresses.source_record_id,
    customer_addresses.source_ingested_at,
    customer_addresses.source_updated_at
from customer_addresses
left join customers on customer_addresses.customer_id = customers.customer_id
left join addresses on customer_addresses.address_id = addresses.address_id
