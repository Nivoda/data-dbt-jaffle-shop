{{ config(alias='obj_address') }}

with addresses as (
    select * from {{ ref('stg_ecom__addresses') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['address_id']) }} as address_sk,
    address_id,
    address_line_1,
    city,
    state,
    postal_code,
    country_code,
    address_created_at,
    source_record_id,
    source_ingested_at,
    source_updated_at
from addresses
