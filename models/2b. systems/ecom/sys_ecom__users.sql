{{ config(materialized='view', alias='sys_ecom__users') }}

select
    {{ dbt_utils.star(from=ref('stg_ecom__users')) }}
from {{ ref('stg_ecom__users') }}
