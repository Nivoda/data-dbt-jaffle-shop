{{ config(alias='dim_customer') }}

-- Repeat-order behavioural attributes (first/last ordered_at, lifetime_order_count,
-- is_repeat_customer) live here, not in core.customer, because they are derived
-- from order activity and would make the canonical Customer record drift with
-- behaviour. This is the right place for that reusable analytical context.
with customers as (
    select * from {{ ref('customer') }}
),

customer_order_sequence as (
    select
        customer_id,
        max(lifetime_order_count) as lifetime_order_count,
        min(first_ordered_at) as first_ordered_at,
        max(last_ordered_at) as last_ordered_at,
        max(case when is_repeat_customer then 1 else 0 end) = 1 as is_repeat_customer
    from {{ ref('int_customer_order_sequence') }}
    group by 1
),

contact_profile as (
    select * from {{ ref('int_customer_contact_profile') }}
)

select
    customers.customer_sk,
    customers.customer_id,
    customers.customer_name,
    contact_profile.primary_user_id,
    contact_profile.primary_user_name,
    contact_profile.primary_email_address,
    contact_profile.primary_phone_number,
    contact_profile.primary_user_relationship_role,
    contact_profile.default_address_id,
    contact_profile.default_address_line_1,
    contact_profile.default_city,
    contact_profile.default_state,
    contact_profile.default_postal_code,
    contact_profile.default_country_code,
    contact_profile.default_address_usage,
    customer_order_sequence.first_ordered_at,
    customer_order_sequence.last_ordered_at,
    coalesce(customer_order_sequence.lifetime_order_count, 0) as lifetime_order_count,
    coalesce(customer_order_sequence.is_repeat_customer, false) as is_repeat_customer
from customers
left join customer_order_sequence on customers.customer_id = customer_order_sequence.customer_id
left join contact_profile on customers.customer_id = contact_profile.customer_id
