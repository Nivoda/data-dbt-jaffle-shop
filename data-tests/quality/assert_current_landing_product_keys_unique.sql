with key_counts as (
    select
        source_record_id,
        count(*) as record_count
    from {{ ref('lnd_ecom__products_current') }}
    group by 1
)

select *
from key_counts
where record_count != 1
