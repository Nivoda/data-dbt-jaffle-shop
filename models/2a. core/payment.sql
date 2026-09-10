{{ config(alias='payment') }}

with payments as (
    select * from {{ ref('stg_ecom__payments') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['payment_id']) }} as payment_sk,
    payment_id,
    order_id,
    payment_method,
    source_payment_status,
    paid_at,
    payment_amount_cents,
    payment_amount,
    source_record_id,
    source_ingested_at,
    source_updated_at
from payments
