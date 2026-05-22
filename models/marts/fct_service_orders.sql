-- Fact table: service orders enriched with customer info

select
    o.order_id,
    o.customer_id,
    c.customer_name,
    c.region,
    c.customer_type,
    o.order_type,
    o.status,
    o.order_date,
    o.completed_date,
    o.amount,
    datediff(day, o.order_date, o.completed_date) as days_to_complete
from {{ ref('stg_service_orders') }} o
left join {{ ref('stg_customers') }} c
    on o.customer_id = c.customer_id
