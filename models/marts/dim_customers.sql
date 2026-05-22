-- Dimension: customer with aggregated metrics

select
    c.customer_id,
    c.customer_name,
    c.region,
    c.customer_type,
    c.created_date,
    count(distinct o.order_id) as total_orders,
    sum(o.amount) as total_order_amount,
    max(o.order_date) as last_order_date
from {{ ref('stg_customers') }} c
left join {{ ref('stg_service_orders') }} o
    on c.customer_id = o.customer_id
group by
    c.customer_id,
    c.customer_name,
    c.region,
    c.customer_type,
    c.created_date
