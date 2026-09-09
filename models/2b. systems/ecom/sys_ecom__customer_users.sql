{{ config(materialized='view', alias='sys_ecom__customer_users') }}

select
    {{ dbt_utils.star(from=ref('stg_ecom__customer_users')) }}
from {{ ref('stg_ecom__customer_users') }}
