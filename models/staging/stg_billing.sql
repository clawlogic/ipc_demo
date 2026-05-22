-- Staging model: clean and type raw billing data

select
    cast(billing_id as int) as billing_id,
    cast(customer_id as int) as customer_id,
    trim(billing_period) as billing_period,
    cast(kwh_usage as decimal(12,2)) as kwh_usage,
    cast(amount_due as decimal(10,2)) as amount_due,
    cast(amount_paid as decimal(10,2)) as amount_paid,
    trim(payment_status) as payment_status
from {{ ref('raw_billing') }}
