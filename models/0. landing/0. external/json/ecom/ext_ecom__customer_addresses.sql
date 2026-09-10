{{ config(alias='ext_ecom__customer_addresses') }}

with source_records as (
    select * from {{ source('ecom', 'raw_customer_addresses') }}
),

events as (
    select
        cast(id as {{ dbt.type_string() }}) || ':customer_address:001' as ingestion_event_id,
        cast(id as {{ dbt.type_string() }}) as source_record_id,
        'I' as operation_type,
        {{ cast_timestamp('valid_from') }} + interval '4 minutes' as ingested_at,
        {{ cast_timestamp('valid_from') }} as source_updated_at,
        {{ customer_address_payload('id', 'customer_id', 'address_id', 'address_usage', 'is_default_address', 'valid_from', 'valid_to') }} as record_payload
    from source_records
)

select
    ingestion_event_id,
    source_record_id,
    operation_type,
    ingested_at,
    source_updated_at,
    record_payload,
    {{ json_get_string('record_payload', '$.customer_address_relationship_id') }} as extracted_customer_address_relationship_id,
    {{ json_get_string('record_payload', '$.customer_id') }} as extracted_customer_id,
    {{ json_get_string('record_payload', '$.address_id') }} as extracted_address_id,
    {{ json_get_string('record_payload', '$.address_usage') }} as extracted_address_usage,
    {{ json_get_string('record_payload', '$.is_default_address') }} as extracted_is_default_address,
    {{ json_get_string('record_payload', '$.valid_from') }} as extracted_valid_from,
    {{ json_get_string('record_payload', '$.valid_to') }} as extracted_valid_to
from events
