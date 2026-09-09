{{ config(materialized='view', alias='sys_ecom__order_address_snapshots') }}

select
    {{ dbt_utils.star(from=ref('stg_ecom__order_address_snapshots')) }}
from {{ ref('stg_ecom__order_address_snapshots') }}
