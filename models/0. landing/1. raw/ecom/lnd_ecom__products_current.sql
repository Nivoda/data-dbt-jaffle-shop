{{ config(alias='lnd_ecom__products_current') }}

with cdc_events as (
    select * from {{ ref('ext_ecom__products') }}
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
    extracted_product_id,
    extracted_product_name,
    extracted_product_type,
    extracted_price_cents,
    extracted_product_description,
    landing_current_rank,
    'source_updated_at desc, ingested_at desc, ingestion_event_id desc' as landing_deduplication_order
from ranked
where landing_current_rank = 1
