{{ config(alias='ext_ecom__customer_users') }}

with source_records as (
    select * from {{ source('ecom', 'raw_customer_users') }}
),

events as (
    select
        cast(id as {{ dbt.type_string() }}) || ':customer_user:001' as ingestion_event_id,
        cast(id as {{ dbt.type_string() }}) as source_record_id,
        'I' as operation_type,
        {{ cast_timestamp('valid_from') }} + interval '2 minutes' as ingested_at,
        {{ cast_timestamp('valid_from') }} as source_updated_at,
        {{ customer_user_payload('id', 'customer_id', 'user_id', 'relationship_role', 'is_primary_contact', 'valid_from', 'valid_to') }} as record_payload
    from source_records
)

select
    ingestion_event_id,
    source_record_id,
    operation_type,
    ingested_at,
    source_updated_at,
    record_payload,
    {{ json_get_string('record_payload', '$.customer_user_relationship_id') }} as extracted_customer_user_relationship_id,
    {{ json_get_string('record_payload', '$.customer_id') }} as extracted_customer_id,
    {{ json_get_string('record_payload', '$.user_id') }} as extracted_user_id,
    {{ json_get_string('record_payload', '$.relationship_role') }} as extracted_relationship_role,
    {{ json_get_string('record_payload', '$.is_primary_contact') }} as extracted_is_primary_contact,
    {{ json_get_string('record_payload', '$.valid_from') }} as extracted_valid_from,
    {{ json_get_string('record_payload', '$.valid_to') }} as extracted_valid_to
from events
