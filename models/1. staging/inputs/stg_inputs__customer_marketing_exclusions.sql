{{ config(alias='stg_inputs__customer_marketing_exclusions') }}

with source as (
    select * from {{ source('inputs', 'raw_customer_marketing_exclusions') }}
)

select
    cast(customer_id as {{ dbt.type_string() }}) as customer_id,
    cast(is_excluded as boolean) as is_excluded,
    trim(cast(exclusion_reason as {{ dbt.type_string() }})) as exclusion_reason,
    {{ cast_timestamp('valid_from') }} as valid_from,
    {{ cast_timestamp('valid_to') }} as valid_to,
    trim(cast(updated_by as {{ dbt.type_string() }})) as updated_by,
    {{ cast_timestamp('updated_at') }} as updated_at
from source
