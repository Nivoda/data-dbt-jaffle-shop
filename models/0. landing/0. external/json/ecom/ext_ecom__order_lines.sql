{{ config(alias='ext_ecom__order_lines') }}

with source as (
    select * from {{ source('ecom', 'raw_items') }}
)

select
    id || ':001' as ingestion_event_id,
    id as source_record_id,
    'I' as operation_type,
    {{ cast_timestamp("'2024-09-01 00:25:00'") }} as ingested_at,
    {{ cast_timestamp("'2024-09-01 00:00:00'") }} as source_updated_at,
    {{ order_line_payload() }} as record_payload,
    {{ json_get_string('record_payload', '$.order_line_id') }} as extracted_order_line_id,
    {{ json_get_string('record_payload', '$.order_id') }} as extracted_order_id,
    {{ json_get_string('record_payload', '$.product_id') }} as extracted_product_id,
    {{ json_get_string('record_payload', '$.quantity') }} as extracted_quantity
from source
