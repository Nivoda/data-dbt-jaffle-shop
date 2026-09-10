{{ config(alias='stg_ecom__products') }}

with source as (
    select * from {{ ref('lnd_ecom__products_current') }}
)

select
    cast(extracted_product_id as {{ dbt.type_string() }}) as product_id,
    trim(cast(extracted_product_name as {{ dbt.type_string() }})) as product_name,
    lower(trim(cast(extracted_product_type as {{ dbt.type_string() }}))) as product_type,
    trim(cast(extracted_product_description as {{ dbt.type_string() }})) as product_description,
    cast(extracted_price_cents as integer) as product_price_cents,
    {{ cents_to_dollars('cast(extracted_price_cents as integer)') }} as product_price,
    coalesce(lower(trim(cast(extracted_product_type as {{ dbt.type_string() }}))) = 'jaffle', false) as is_food_item,
    coalesce(lower(trim(cast(extracted_product_type as {{ dbt.type_string() }}))) = 'beverage', false) as is_drink_item,
    source_record_id,
    ingestion_event_id,
    operation_type as source_operation_type,
    ingested_at as source_ingested_at,
    source_updated_at
from source
