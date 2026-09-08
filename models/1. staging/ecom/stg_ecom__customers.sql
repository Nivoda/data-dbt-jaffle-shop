{{ config(alias='stg_ecom__customers') }}

with source as (
    select * from {{ ref('lnd_ecom__customers_current') }}
)

select
    cast(extracted_customer_id as {{ dbt.type_string() }}) as customer_id,
    trim(cast(extracted_customer_name as {{ dbt.type_string() }})) as customer_name,
    source_record_id,
    ingestion_event_id,
    operation_type as source_operation_type,
    ingested_at as source_ingested_at,
    source_updated_at
from source
