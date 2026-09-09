-- Protects the landing contract: after CDC winner selection, each current customer source key appears once.
select source_record_id
from {{ ref('lnd_ecom__customers_current') }}
group by 1
having count(*) != 1
