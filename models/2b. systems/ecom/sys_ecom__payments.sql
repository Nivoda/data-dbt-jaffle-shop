{{ config(materialized='view', alias='sys_ecom__payments') }}

select
    {{ dbt_utils.star(from=ref('stg_ecom__payments')) }}
from {{ ref('stg_ecom__payments') }}
