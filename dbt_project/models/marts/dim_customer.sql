select
    customer_id,
    customer_name,
    segment,
    first_order_date,
    year(first_order_date)      as first_order_year,
    last_order_date,
    order_count,
    order_count > 1             as is_repeat_customer,
    lifetime_sales,
    lifetime_profit
from {{ ref('int_customer_summary') }}
