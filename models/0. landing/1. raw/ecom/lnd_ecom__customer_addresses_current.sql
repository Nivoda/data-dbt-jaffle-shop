{{ config(alias='lnd_ecom__customer_addresses_current') }}

with cdc_events as (
    select * from {{ ref('ext_ecom__customer_addresses') }}
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
    extracted_customer_address_relationship_id,
    extracted_customer_id,
    extracted_address_id,
    extracted_address_usage,
    extracted_is_default_address,
    extracted_valid_from,
    extracted_valid_to,
    landing_current_rank,
    'source_updated_at desc, ingested_at desc, ingestion_event_id desc' as landing_deduplication_order
from ranked
where landing_current_rank = 1
