-- Staging model: clean and type raw service order data

select
    cast(order_id as int) as order_id,
    cast(customer_id as int) as customer_id,
    trim(order_type) as order_type,
    trim(status) as status,
    cast(order_date as date) as order_date,
    cast(completed_date as date) as completed_date,
    cast(amount as decimal(10,2)) as amount
from {{ ref('raw_service_orders') }}
