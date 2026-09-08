{{ config(alias='ops_order_count_reconciliation') }}

with staging_orders as (
    select count(*) as order_count from {{ ref('stg_ecom__orders') }}
),

object_orders as (
    select count(*) as order_count from {{ ref('obj_order') }}
),

fact_orders as (
    select count(*) as order_count from {{ ref('fct_order') }}
)

select
    staging_orders.order_count as staging_order_count,
    object_orders.order_count as object_order_count,
    fact_orders.order_count as fact_order_count,
    staging_orders.order_count = object_orders.order_count
        and object_orders.order_count = fact_orders.order_count as reconciles
from staging_orders
cross join object_orders
cross join fact_orders
