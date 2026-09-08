{{ config(alias='obj_customer_user') }}

with customer_users as (
    select * from {{ ref('stg_ecom__customer_users') }}
),

customers as (
    select
        customer_sk,
        customer_id
    from {{ ref('obj_customer') }}
),

users as (
    select
        user_sk,
        user_id
    from {{ ref('obj_user') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_users.customer_user_relationship_id']) }} as customer_user_sk,
    customer_users.customer_user_relationship_id,
    customers.customer_sk,
    users.user_sk,
    customer_users.customer_id,
    customer_users.user_id,
    customer_users.relationship_role,
    customer_users.is_primary_contact,
    customer_users.valid_from,
    customer_users.valid_to,
    customer_users.source_record_id,
    customer_users.source_ingested_at,
    customer_users.source_updated_at
from customer_users
left join customers on customer_users.customer_id = customers.customer_id
left join users on customer_users.user_id = users.user_id
