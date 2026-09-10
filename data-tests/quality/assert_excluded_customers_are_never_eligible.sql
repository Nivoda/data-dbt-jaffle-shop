-- Protects the Manual Inputs pattern: a customer with a current manual marketing
-- exclusion (core.customer_marketing_exclusion) must never come out of
-- operational.customer_marketing_eligibility as eligible for the post-purchase journey.
select
    eligibility.customer_id,
    eligibility.is_eligible_for_post_purchase_journey,
    eligibility.eligibility_reason
from {{ ref('customer_marketing_eligibility') }} as eligibility
inner join {{ ref('customer_marketing_exclusion') }} as exclusion
    on eligibility.customer_id = exclusion.customer_id
    and exclusion.valid_to is null
    and exclusion.is_excluded
where eligibility.is_eligible_for_post_purchase_journey
   or eligibility.eligibility_reason != 'exclude_manual_marketing_exclusion'
