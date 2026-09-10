{{ config(alias='product') }}

with products as (
    select * from {{ ref('stg_ecom__products') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_sk,
    product_id,
    product_name,
    product_type,
    product_description,
    product_price_cents,
    product_price,
    is_food_item,
    is_drink_item,
    source_record_id,
    source_ingested_at,
    source_updated_at
from products
