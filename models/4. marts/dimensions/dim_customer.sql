{{ config(alias='dim_customer') }}

with customers as (
    select * from {{ ref('obj_customer') }}
),

contact_profile as (
    select * from {{ ref('int_commerce__customer_contact_profile') }}
),

customer_users as (
    select * from {{ ref('obj_customer_user') }}
),

users as (
    select * from {{ ref('obj_user') }}
),

customer_addresses as (
    select * from {{ ref('obj_customer_address') }}
),

addresses as (
    select * from {{ ref('obj_address') }}
)

select
    customers.customer_sk,
    customers.customer_id,
    customers.customer_name,
    users.user_id as primary_user_id,
    users.user_name as primary_user_name,
    users.email_address as primary_email_address,
    users.phone_number as primary_phone_number,
    customer_users.relationship_role as primary_user_relationship_role,
    addresses.address_id as default_address_id,
    addresses.address_line_1 as default_address_line_1,
    addresses.city as default_city,
    addresses.state as default_state,
    addresses.postal_code as default_postal_code,
    addresses.country_code as default_country_code,
    customer_addresses.address_usage as default_address_usage,
    customers.first_ordered_at,
    customers.last_ordered_at,
    customers.lifetime_order_count,
    customers.is_repeat_customer
from customers
left join contact_profile on customers.customer_id = contact_profile.customer_id
left join customer_users
    on contact_profile.primary_customer_user_relationship_id = customer_users.customer_user_relationship_id
left join users on customer_users.user_sk = users.user_sk
left join customer_addresses
    on contact_profile.default_customer_address_relationship_id = customer_addresses.customer_address_relationship_id
left join addresses on customer_addresses.address_sk = addresses.address_sk
