{{ config(alias='stg_ecom__customer_addresses') }}

with source as (
    select * from {{ ref('lnd_ecom__customer_addresses_current') }}
)

select
    cast(extracted_customer_address_relationship_id as {{ dbt.type_string() }}) as customer_address_relationship_id,
    cast(extracted_customer_id as {{ dbt.type_string() }}) as customer_id,
    cast(extracted_address_id as {{ dbt.type_string() }}) as address_id,
    lower(trim(cast(extracted_address_usage as {{ dbt.type_string() }}))) as address_usage,
    cast(extracted_is_default_address as boolean) as is_default_address,
    {{ cast_timestamp('extracted_valid_from') }} as valid_from,
    {{ cast_timestamp('extracted_valid_to') }} as valid_to,
    source_record_id,
    ingestion_event_id,
    operation_type as source_operation_type,
    ingested_at as source_ingested_at,
    source_updated_at
from source
