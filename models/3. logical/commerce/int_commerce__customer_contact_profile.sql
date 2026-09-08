{{ config(alias='int_commerce__customer_contact_profile') }}

with customer_users as (
    select * from {{ ref('stg_ecom__customer_users') }}
),

customer_addresses as (
    select * from {{ ref('stg_ecom__customer_addresses') }}
),

primary_users as (
    select
        customer_users.customer_id,
        customer_users.customer_user_relationship_id,
        customer_users.user_id,
        customer_users.relationship_role,
        row_number() over (
            partition by customer_users.customer_id
            order by customer_users.is_primary_contact desc, customer_users.valid_from desc, customer_users.customer_user_relationship_id
        ) as contact_rank
    from customer_users
    where customer_users.valid_to is null
),

primary_addresses as (
    select
        customer_addresses.customer_id,
        customer_addresses.customer_address_relationship_id,
        customer_addresses.address_id,
        customer_addresses.address_usage,
        row_number() over (
            partition by customer_addresses.customer_id
            order by customer_addresses.is_default_address desc, customer_addresses.valid_from desc, customer_addresses.customer_address_relationship_id
        ) as address_rank
    from customer_addresses
    where customer_addresses.valid_to is null
)

select
    primary_users.customer_id,
    primary_users.customer_user_relationship_id as primary_customer_user_relationship_id,
    primary_users.user_id as primary_user_id,
    primary_users.relationship_role as primary_user_relationship_role,
    primary_addresses.customer_address_relationship_id as default_customer_address_relationship_id,
    primary_addresses.address_id as default_address_id,
    primary_addresses.address_usage as default_address_usage
from primary_users
left join primary_addresses
    on primary_users.customer_id = primary_addresses.customer_id
    and primary_addresses.address_rank = 1
where primary_users.contact_rank = 1
