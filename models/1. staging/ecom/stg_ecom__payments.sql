{{ config(alias='stg_ecom__payments') }}

with source as (
    select * from {{ ref('lnd_ecom__payments_current') }}
)

select
    cast(extracted_payment_id as {{ dbt.type_string() }}) as payment_id,
    cast(extracted_order_id as {{ dbt.type_string() }}) as order_id,
    lower(trim(cast(extracted_payment_method as {{ dbt.type_string() }}))) as payment_method,
    lower(trim(cast(source_payment_status as {{ dbt.type_string() }}))) as source_payment_status,
    {{ cast_timestamp('extracted_paid_at') }} as paid_at,
    cast(extracted_amount_cents as integer) as payment_amount_cents,
    {{ cents_to_dollars('cast(extracted_amount_cents as integer)') }} as payment_amount,
    source_record_id,
    ingestion_event_id,
    operation_type as source_operation_type,
    ingested_at as source_ingested_at,
    source_updated_at
from source
