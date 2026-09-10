{{ config(alias='ext_ecom__orders') }}

with source as (
    select * from {{ source('ecom', 'raw_orders') }}
),

events as (
    select
        cast(id as {{ dbt.type_string() }}) || ':order:001' as ingestion_event_id,
        cast(id as {{ dbt.type_string() }}) as source_record_id,
        'I' as operation_type,
        {{ cast_timestamp('ordered_at') }} + interval '1 minute' as ingested_at,
        {{ cast_timestamp('ordered_at') }} as source_updated_at,
        {{ order_payload() }} as record_payload
    from source
)

select
    ingestion_event_id,
    source_record_id,
    operation_type,
    ingested_at,
    source_updated_at,
    record_payload,
    {{ json_get_string('record_payload', '$.order_id') }} as extracted_order_id,
    {{ json_get_string('record_payload', '$.customer_id') }} as extracted_customer_id,
    {{ json_get_string('record_payload', '$.ordered_at') }} as extracted_ordered_at,
    {{ json_get_string('record_payload', '$.store_id') }} as extracted_store_id,
    {{ json_get_string('record_payload', '$.subtotal_cents') }} as extracted_subtotal_cents,
    {{ json_get_string('record_payload', '$.tax_paid_cents') }} as extracted_tax_paid_cents,
    {{ json_get_string('record_payload', '$.order_total_cents') }} as extracted_order_total_cents
from events
