{{ config(alias='lnd_ecom__order_address_snapshots_current') }}

with cdc_events as (
    select * from {{ ref('ext_ecom__order_address_snapshots') }}
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
    extracted_order_address_snapshot_id,
    extracted_order_id,
    extracted_customer_id,
    extracted_source_address_id,
    extracted_address_line_1,
    extracted_city,
    extracted_state,
    extracted_postal_code,
    extracted_country_code,
    extracted_captured_at,
    landing_current_rank,
    'source_updated_at desc, ingested_at desc, ingestion_event_id desc' as landing_deduplication_order
from ranked
where landing_current_rank = 1
