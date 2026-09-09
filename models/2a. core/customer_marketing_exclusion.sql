{{ config(alias='customer_marketing_exclusion') }}

-- Canonical, business-maintained record of a customer marketing exclusion decision.
-- Treated the same way as the customer_user/customer_address relationship records:
-- it carries its own governed source identity (customer_id) and validity window,
-- so it belongs in Core rather than as a derived Logical view.
with exclusions as (
    select * from {{ ref('stg_inputs__customer_marketing_exclusions') }}
),

customers as (
    select
        customer_sk,
        customer_id
    from {{ ref('customer') }}
)

select
    customers.customer_sk,
    exclusions.customer_id,
    exclusions.is_excluded,
    exclusions.exclusion_reason,
    exclusions.valid_from,
    exclusions.valid_to,
    exclusions.updated_by,
    exclusions.updated_at
from exclusions
left join customers on exclusions.customer_id = customers.customer_id
