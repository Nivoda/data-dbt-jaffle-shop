{{ config(alias='lnd_ecom__orders_current') }}

with cdc_events as (
    select * from {{ ref('ext_ecom__orders') }}
),

ranked as (
    select
        *,
        row_number() over (
            partition by source_record_id
            order by source_updated_at desc, ingested_at desc, ingestion_event_id desc
        ) as landing_current_rank
    from cdc_events
    where operation_type != 'D'
)

select
    ingestion_event_id,
    source_record_id,
    operation_type,
    ingested_at,
    source_updated_at,
    record_payload,
    extracted_order_id,
    extracted_customer_id,
    extracted_ordered_at,
    extracted_store_id,
    extracted_subtotal_cents,
    extracted_tax_paid_cents,
    extracted_order_total_cents,
    landing_current_rank,
    'source_updated_at desc, ingested_at desc, ingestion_event_id desc' as landing_deduplication_order
from ranked
where landing_current_rank = 1
