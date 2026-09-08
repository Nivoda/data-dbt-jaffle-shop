{{ config(alias='ext_ecom__order_address_snapshots') }}

with source_records as (
    select * from {{ source('ecom', 'raw_order_address_snapshots') }}
),

events as (
    select
        cast(id as {{ dbt.type_string() }}) || ':order_address_snapshot:001' as ingestion_event_id,
        cast(id as {{ dbt.type_string() }}) as source_record_id,
        'I' as operation_type,
        {{ cast_timestamp('captured_at') }} + interval '5 minutes' as ingested_at,
        {{ cast_timestamp('captured_at') }} as source_updated_at,
        {{ order_address_snapshot_payload('id', 'order_id', 'customer_id', 'source_address_id', 'address_line_1', 'city', 'state', 'postal_code', 'country_code', 'captured_at') }} as record_payload
    from source_records
)

select
    ingestion_event_id,
    source_record_id,
    operation_type,
    ingested_at,
    source_updated_at,
    record_payload,
    {{ json_get_string('record_payload', '$.order_address_snapshot_id') }} as extracted_order_address_snapshot_id,
    {{ json_get_string('record_payload', '$.order_id') }} as extracted_order_id,
    {{ json_get_string('record_payload', '$.customer_id') }} as extracted_customer_id,
    {{ json_get_string('record_payload', '$.source_address_id') }} as extracted_source_address_id,
    {{ json_get_string('record_payload', '$.address_line_1') }} as extracted_address_line_1,
    {{ json_get_string('record_payload', '$.city') }} as extracted_city,
    {{ json_get_string('record_payload', '$.state') }} as extracted_state,
    {{ json_get_string('record_payload', '$.postal_code') }} as extracted_postal_code,
    {{ json_get_string('record_payload', '$.country_code') }} as extracted_country_code,
    {{ json_get_string('record_payload', '$.captured_at') }} as extracted_captured_at
from events
