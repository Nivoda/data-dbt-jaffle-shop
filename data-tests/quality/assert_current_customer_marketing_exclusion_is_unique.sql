-- Protects the Manual Inputs invariant: core.customer_marketing_exclusion has
-- grain "one customer marketing-exclusion decision", and
-- operational.customer_marketing_eligibility filters `valid_to is null` to get
-- the CURRENT decision per customer. If more than one row per customer_id is
-- ever open (valid_to is null) at once, "the current decision" is ambiguous and
-- downstream eligibility logic silently picks one arbitrarily.
select
    customer_id,
    count(*) as open_exclusion_row_count
from {{ ref('customer_marketing_exclusion') }}
where valid_to is null
group by 1
having count(*) > 1
