{{ config(materialized='view', alias='sys_ecom__customer_addresses') }}

select
    {{ dbt_utils.star(from=ref('stg_ecom__customer_addresses')) }}
from {{ ref('stg_ecom__customer_addresses') }}
