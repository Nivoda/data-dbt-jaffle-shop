{{ config(alias='ext_ecom__customers') }}

with source as (
    select * from {{ source('ecom', 'raw_customers') }}
),

events as (
    select
        cast(id as {{ dbt.type_string() }}) || ':customer:001' as ingestion_event_id,
        cast(id as {{ dbt.type_string() }}) as source_record_id,
        'I' as operation_type,
        {{ cast_timestamp("'2024-09-01 00:00:00'") }} as ingested_at,
        {{ cast_timestamp("'2024-09-01 00:00:00'") }} as source_updated_at,
        {{ customer_payload() }} as record_payload
    from source
)

select
    ingestion_event_id,
    source_record_id,
    operation_type,
    ingested_at,
    source_updated_at,
    record_payload,
    {{ json_get_string('record_payload', '$.customer_id') }} as extracted_customer_id,
    {{ json_get_string('record_payload', '$.customer_name') }} as extracted_customer_name
from events
