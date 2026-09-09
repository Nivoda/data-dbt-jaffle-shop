{{ config(materialized='view', alias='sys_ecom__addresses') }}

select
    {{ dbt_utils.star(from=ref('stg_ecom__addresses')) }}
from {{ ref('stg_ecom__addresses') }}
