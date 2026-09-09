{{ config(materialized='view', alias='sys_ecom__orders') }}

select
    {{ dbt_utils.star(from=ref('stg_ecom__orders')) }}
from {{ ref('stg_ecom__orders') }}
