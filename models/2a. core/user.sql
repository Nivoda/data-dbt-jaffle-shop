{{ config(alias='user') }}

with users as (
    select * from {{ ref('stg_ecom__users') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['user_id']) }} as user_sk,
    user_id,
    user_name,
    email_address,
    phone_number,
    source_user_status,
    user_created_at,
    source_record_id,
    source_ingested_at,
    source_updated_at
from users
