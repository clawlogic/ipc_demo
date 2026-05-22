-- Fact table: billing summary per customer

select
    b.customer_id,
    c.customer_name,
    c.region,
    count(b.billing_id) as total_bills,
    sum(b.kwh_usage) as total_kwh,
    sum(b.amount_due) as total_amount_due,
    sum(b.amount_paid) as total_amount_paid,
    sum(b.amount_due) - sum(b.amount_paid) as outstanding_balance
from {{ ref('stg_billing') }} b
left join {{ ref('stg_customers') }} c
    on b.customer_id = c.customer_id
group by
    b.customer_id,
    c.customer_name,
    c.region
