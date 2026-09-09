{{ config(materialized='view', alias='sys_ecom__order_lines') }}

select
    {{ dbt_utils.star(from=ref('stg_ecom__order_lines')) }}
from {{ ref('stg_ecom__order_lines') }}
