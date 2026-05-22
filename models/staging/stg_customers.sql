-- Staging model: clean and type raw customer data
-- Source: seed file (simulating a raw source system feed)

select
    cast(customer_id as int) as customer_id,
    trim(customer_name) as customer_name,
    trim(region) as region,
    trim(customer_type) as customer_type,
    cast(created_date as date) as created_date
from {{ ref('raw_customers') }}
