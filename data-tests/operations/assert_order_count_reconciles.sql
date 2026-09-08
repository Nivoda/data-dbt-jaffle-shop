-- Protects against accidental filtering or fanout between trusted staging, object, and fact order paths.
select *
from {{ ref('ops_order_count_reconciliation') }}
where not reconciles
