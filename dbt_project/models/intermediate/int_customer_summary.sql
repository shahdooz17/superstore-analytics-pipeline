-- One row per customer with lifetime behaviour. Feeds dim_customer.

select
    customer_id,
    min(customer_name)                  as customer_name,
    min(segment)                        as segment,
    min(order_date)                     as first_order_date,
    max(order_date)                     as last_order_date,
    count(distinct order_id)            as order_count,
    sum(sales)                          as lifetime_sales,
    sum(profit)                         as lifetime_profit
from {{ ref('int_order_lines') }}
group by customer_id
