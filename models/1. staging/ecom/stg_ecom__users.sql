{{ config(alias='stg_ecom__users') }}

with source as (
    select * from {{ ref('lnd_ecom__users_current') }}
)

select
    cast(extracted_user_id as {{ dbt.type_string() }}) as user_id,
    trim(cast(extracted_user_name as {{ dbt.type_string() }})) as user_name,
    lower(trim(cast(extracted_email_address as {{ dbt.type_string() }}))) as email_address,
    trim(cast(extracted_phone_number as {{ dbt.type_string() }})) as phone_number,
    lower(trim(cast(extracted_user_status as {{ dbt.type_string() }}))) as source_user_status,
    {{ cast_timestamp('extracted_created_at') }} as user_created_at,
    source_record_id,
    ingestion_event_id,
    operation_type as source_operation_type,
    ingested_at as source_ingested_at,
    source_updated_at
from source
