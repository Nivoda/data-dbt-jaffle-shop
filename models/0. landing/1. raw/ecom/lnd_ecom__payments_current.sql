{{ config(alias='lnd_ecom__payments_current') }}

with cdc_events as (
    select * from {{ ref('ext_ecom__payments') }}
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
    source_payment_status,
    extracted_payment_id,
    extracted_order_id,
    extracted_amount_cents,
    extracted_payment_method,
    extracted_paid_at,
    landing_current_rank,
    'source_updated_at desc, ingested_at desc, ingestion_event_id desc' as landing_deduplication_order
from ranked
where landing_current_rank = 1
