{{ config(materialized='view', alias='sys_ecom__customers') }}

select
    {{ dbt_utils.star(from=ref('stg_ecom__customers')) }}
from {{ ref('stg_ecom__customers') }}
