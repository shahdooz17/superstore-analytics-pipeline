-- Business logic at order-line level: delivery time, margin, loss flag, discount band.

with lines as (
    select * from {{ ref('stg_superstore') }}
),

bands as (
    select * from {{ ref('discount_bands') }}
)

select
    l.*,
    date_diff('day', l.order_date, l.ship_date)            as ship_days,
    round(l.profit / nullif(l.sales, 0), 4)                as profit_margin,
    l.profit < 0                                           as is_loss_making,
    b.discount_band,
    b.sort_order                                           as discount_band_sort
from lines l
left join bands b
    on l.discount >= b.min_discount
   and l.discount <  b.max_discount_exclusive
