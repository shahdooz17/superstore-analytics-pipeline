-- Exploratory query (not materialised). Compile with `dbt compile`, run the result in DuckDB.
select
    discount_band,
    count(*)                                  as order_lines,
    round(sum(sales), 0)                      as sales,
    round(sum(profit), 0)                     as profit,
    round(sum(profit) / sum(sales), 3)        as margin
from {{ ref('fact_sales') }}
group by discount_band, discount_band_sort
order by discount_band_sort
