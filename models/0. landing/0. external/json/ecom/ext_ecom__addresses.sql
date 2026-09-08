{{ config(alias='ext_ecom__addresses') }}

with source_records as (
    select * from {{ source('ecom', 'raw_addresses') }}
),

events as (
    select
        cast(id as {{ dbt.type_string() }}) || ':address:001' as ingestion_event_id,
        cast(id as {{ dbt.type_string() }}) as source_record_id,
        'I' as operation_type,
        {{ cast_timestamp('created_at') }} + interval '3 minutes' as ingested_at,
        {{ cast_timestamp('created_at') }} as source_updated_at,
        {{ address_payload('id', 'address_line_1', 'city', 'state', 'postal_code', 'country_code', 'created_at') }} as record_payload
    from source_records
)

select
    ingestion_event_id,
    source_record_id,
    operation_type,
    ingested_at,
    source_updated_at,
    record_payload,
    {{ json_get_string('record_payload', '$.address_id') }} as extracted_address_id,
    {{ json_get_string('record_payload', '$.address_line_1') }} as extracted_address_line_1,
    {{ json_get_string('record_payload', '$.city') }} as extracted_city,
    {{ json_get_string('record_payload', '$.state') }} as extracted_state,
    {{ json_get_string('record_payload', '$.postal_code') }} as extracted_postal_code,
    {{ json_get_string('record_payload', '$.country_code') }} as extracted_country_code,
    {{ json_get_string('record_payload', '$.created_at') }} as extracted_created_at
from events
