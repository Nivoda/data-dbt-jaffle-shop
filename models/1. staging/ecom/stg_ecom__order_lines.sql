{{ config(alias='stg_ecom__order_lines') }}

with source as (
    select * from {{ ref('lnd_ecom__order_lines_current') }}
)

select
    cast(extracted_order_line_id as {{ dbt.type_string() }}) as order_line_id,
    cast(extracted_order_id as {{ dbt.type_string() }}) as order_id,
    cast(extracted_product_id as {{ dbt.type_string() }}) as product_id,
    cast(extracted_quantity as integer) as quantity,
    source_record_id,
    ingestion_event_id,
    operation_type as source_operation_type,
    ingested_at as source_ingested_at,
    source_updated_at
from source
