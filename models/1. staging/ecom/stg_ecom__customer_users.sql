{{ config(alias='stg_ecom__customer_users') }}

with source as (
    select * from {{ ref('lnd_ecom__customer_users_current') }}
)

select
    cast(extracted_customer_user_relationship_id as {{ dbt.type_string() }}) as customer_user_relationship_id,
    cast(extracted_customer_id as {{ dbt.type_string() }}) as customer_id,
    cast(extracted_user_id as {{ dbt.type_string() }}) as user_id,
    lower(trim(cast(extracted_relationship_role as {{ dbt.type_string() }}))) as relationship_role,
    cast(extracted_is_primary_contact as boolean) as is_primary_contact,
    {{ cast_timestamp('extracted_valid_from') }} as valid_from,
    {{ cast_timestamp('extracted_valid_to') }} as valid_to,
    source_record_id,
    ingestion_event_id,
    operation_type as source_operation_type,
    ingested_at as source_ingested_at,
    source_updated_at
from source
