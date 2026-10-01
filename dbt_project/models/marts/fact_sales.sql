-- Fact table. Grain: one row per order line (row_id).
-- order_date_key is the main date relationship; ship_date_key is the second date role.

select
    row_id,
    order_id,
    cast(strftime(order_date, '%Y%m%d') as integer)                          as order_date_key,
    cast(strftime(ship_date,  '%Y%m%d') as integer)                          as ship_date_key,
    customer_id,
    product_id,
    md5(concat_ws('|', country, region, state, city, postal_code))           as location_key,
    ship_mode,
    discount_band,
    discount_band_sort,
    sales,
    quantity,
    discount,
    profit,
    profit_margin,
    ship_days,
    is_loss_making
from {{ ref('int_order_lines') }}
