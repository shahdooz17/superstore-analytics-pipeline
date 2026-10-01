-- Calendar table covering every full year between the first order and the last ship date.
-- No external package needed: DuckDB's generate_series builds the spine.

with bounds as (
    select
        cast(date_trunc('year', min(order_date)) as date)                                   as start_date,
        cast(date_trunc('year', max(ship_date)) + interval 1 year - interval 1 day as date) as end_date
    from {{ ref('stg_superstore') }}
),

spine as (
    select cast(d as date) as date_day
    from bounds, generate_series(start_date, end_date, interval 1 day) as t(d)
)

select
    cast(strftime(date_day, '%Y%m%d') as integer)   as date_key,
    date_day,
    year(date_day)                                  as year,
    quarter(date_day)                               as quarter,
    'Q' || quarter(date_day)                        as quarter_name,
    month(date_day)                                 as month_number,
    strftime(date_day, '%B')                        as month_name,
    strftime(date_day, '%b')                        as month_short,
    strftime(date_day, '%Y-%m')                     as year_month,
    cast(date_trunc('month', date_day) as date)     as month_start_date,
    weekofyear(date_day)                            as week_of_year,
    isodow(date_day)                                as day_of_week_number,
    strftime(date_day, '%A')                        as day_of_week_name,
    isodow(date_day) >= 6                           as is_weekend
from spine
