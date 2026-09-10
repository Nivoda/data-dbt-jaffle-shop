{{ config(alias='customer_contact_profile') }}

-- Retargeted to read core.customer_user and core.customer_address (the
-- source-native canonical relationship records), joining core.user / core.address
-- to resolve contact details. This is the derived/enriched business view of
-- "current contact profile" that core.customer_user / core.customer_address alone
-- do not provide -- they carry only the relationship pointers.
with customer_users as (
    select * from {{ ref('customer_user') }}
),

customer_addresses as (
    select * from {{ ref('customer_address') }}
),

users as (
    select * from {{ ref('user') }}
),

addresses as (
    select * from {{ ref('address') }}
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
    users.user_name as primary_user_name,
    users.email_address as primary_email_address,
    users.phone_number as primary_phone_number,
    primary_users.relationship_role as primary_user_relationship_role,
    primary_addresses.customer_address_relationship_id as default_customer_address_relationship_id,
    primary_addresses.address_id as default_address_id,
    addresses.address_line_1 as default_address_line_1,
    addresses.city as default_city,
    addresses.state as default_state,
    addresses.postal_code as default_postal_code,
    addresses.country_code as default_country_code,
    primary_addresses.address_usage as default_address_usage
from primary_users
left join users on primary_users.user_id = users.user_id
left join primary_addresses
    on primary_users.customer_id = primary_addresses.customer_id
    and primary_addresses.address_rank = 1
left join addresses on primary_addresses.address_id = addresses.address_id
where primary_users.contact_rank = 1
