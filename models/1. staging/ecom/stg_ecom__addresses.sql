{{ config(alias='stg_ecom__addresses') }}

with source as (
    select * from {{ ref('lnd_ecom__addresses_current') }}
)

select
    cast(extracted_address_id as {{ dbt.type_string() }}) as address_id,
    trim(cast(extracted_address_line_1 as {{ dbt.type_string() }})) as address_line_1,
    trim(cast(extracted_city as {{ dbt.type_string() }})) as city,
    upper(trim(cast(extracted_state as {{ dbt.type_string() }}))) as state,
    trim(cast(extracted_postal_code as {{ dbt.type_string() }})) as postal_code,
    upper(trim(cast(extracted_country_code as {{ dbt.type_string() }}))) as country_code,
    {{ cast_timestamp('extracted_created_at') }} as address_created_at,
    source_record_id,
    ingestion_event_id,
    operation_type as source_operation_type,
    ingested_at as source_ingested_at,
    source_updated_at
from source
