{{ config(alias='ext_ecom__products') }}

with source as (
    select * from {{ source('ecom', 'raw_products') }}
)

select
    sku || ':001' as ingestion_event_id,
    sku as source_record_id,
    'I' as operation_type,
    {{ cast_timestamp("'2024-09-01 00:20:00'") }} as ingested_at,
    {{ cast_timestamp("'2024-09-01 00:00:00'") }} as source_updated_at,
    {{ product_payload() }} as record_payload,
    {{ json_get_string('record_payload', '$.product_id') }} as extracted_product_id,
    {{ json_get_string('record_payload', '$.product_name') }} as extracted_product_name,
    {{ json_get_string('record_payload', '$.product_type') }} as extracted_product_type,
    {{ json_get_string('record_payload', '$.price_cents') }} as extracted_price_cents,
    {{ json_get_string('record_payload', '$.product_description') }} as extracted_product_description
from source
