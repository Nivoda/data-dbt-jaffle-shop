{{ config(alias='ext_ecom__payments') }}

with source as (
    select * from {{ source('ecom', 'raw_orders') }}
),

payment_events as (
    select
        cast(id as {{ dbt.type_string() }}) || ':payment:001' as payment_id,
        cast(id as {{ dbt.type_string() }}) as order_id,
        order_total as amount_cents,
        case
            when row_number() over (order by ordered_at, id) % 10 = 0 then 'pending'
            else 'captured'
        end as source_payment_status,
        case
            when row_number() over (order by ordered_at, id) % 3 = 0 then 'gift_card'
            when row_number() over (order by ordered_at, id) % 3 = 1 then 'credit_card'
            else 'debit_card'
        end as payment_method,
        {{ cast_timestamp('ordered_at') }} + interval '2 minutes' as paid_at,
        {{ cast_timestamp('ordered_at') }} + interval '3 minutes' as ingested_at,
        {{ cast_timestamp('ordered_at') }} + interval '2 minutes' as source_updated_at
    from source
),

events as (
    select
        payment_id || ':event:001' as ingestion_event_id,
        payment_id as source_record_id,
        'I' as operation_type,
        ingested_at,
        source_updated_at,
        source_payment_status,
        {{ payment_payload('payment_id', 'order_id', 'amount_cents', 'payment_method', 'paid_at') }} as record_payload
    from payment_events
)

select
    ingestion_event_id,
    source_record_id,
    operation_type,
    ingested_at,
    source_updated_at,
    source_payment_status,
    record_payload,
    {{ json_get_string('record_payload', '$.payment_id') }} as extracted_payment_id,
    {{ json_get_string('record_payload', '$.order_id') }} as extracted_order_id,
    {{ json_get_string('record_payload', '$.amount_cents') }} as extracted_amount_cents,
    {{ json_get_string('record_payload', '$.payment_method') }} as extracted_payment_method,
    {{ json_get_string('record_payload', '$.paid_at') }} as extracted_paid_at
from events
