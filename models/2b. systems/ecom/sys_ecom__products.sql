{{ config(materialized='view', alias='sys_ecom__products') }}

select
    {{ dbt_utils.star(from=ref('stg_ecom__products')) }}
from {{ ref('stg_ecom__products') }}
