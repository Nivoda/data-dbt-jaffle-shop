{{ config(alias='ext_ecom__users') }}

with source_records as (
    select * from {{ source('ecom', 'raw_users') }}
),

events as (
    select
        cast(id as {{ dbt.type_string() }}) || ':user:001' as ingestion_event_id,
        cast(id as {{ dbt.type_string() }}) as source_record_id,
        'I' as operation_type,
        {{ cast_timestamp('created_at') }} + interval '1 minute' as ingested_at,
        {{ cast_timestamp('created_at') }} as source_updated_at,
        {{ user_payload('id', 'name', 'email', 'phone', 'status', 'created_at') }} as record_payload
    from source_records
)

select
    ingestion_event_id,
    source_record_id,
    operation_type,
    ingested_at,
    source_updated_at,
    record_payload,
    {{ json_get_string('record_payload', '$.user_id') }} as extracted_user_id,
    {{ json_get_string('record_payload', '$.user_name') }} as extracted_user_name,
    {{ json_get_string('record_payload', '$.email_address') }} as extracted_email_address,
    {{ json_get_string('record_payload', '$.phone_number') }} as extracted_phone_number,
    {{ json_get_string('record_payload', '$.user_status') }} as extracted_user_status,
    {{ json_get_string('record_payload', '$.created_at') }} as extracted_created_at
from events
