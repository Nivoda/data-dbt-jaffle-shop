{{ config(alias='stg_ecom__orders') }}

with source as (
    select * from {{ ref('lnd_ecom__orders_current') }}
)

select
    cast(extracted_order_id as {{ dbt.type_string() }}) as order_id,
    cast(extracted_customer_id as {{ dbt.type_string() }}) as customer_id,
    cast(extracted_store_id as {{ dbt.type_string() }}) as store_id,
    {{ cast_timestamp('extracted_ordered_at') }} as ordered_at,
    cast(extracted_subtotal_cents as integer) as subtotal_cents,
    cast(extracted_tax_paid_cents as integer) as tax_paid_cents,
    cast(extracted_order_total_cents as integer) as order_total_cents,
    {{ cents_to_dollars('cast(extracted_subtotal_cents as integer)') }} as subtotal,
    {{ cents_to_dollars('cast(extracted_tax_paid_cents as integer)') }} as tax_paid,
    {{ cents_to_dollars('cast(extracted_order_total_cents as integer)') }} as order_total,
    source_record_id,
    ingestion_event_id,
    operation_type as source_operation_type,
    ingested_at as source_ingested_at,
    source_updated_at
from source
