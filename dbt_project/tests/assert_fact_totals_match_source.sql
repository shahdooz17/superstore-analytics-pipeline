-- Reconciliation: fact_sales must contain exactly the sales and profit of the raw data.
-- Returns a row (= test failure) if anything was lost or duplicated in the transformations.
with raw as (
    select sum(cast("Sales" as double)) as sales, sum(cast("Profit" as double)) as profit, count(*) as n
    from {{ source('ods', 'superstore_raw') }}
),
fact as (
    select sum(cast(sales as double)) as sales, sum(cast(profit as double)) as profit, count(*) as n
    from {{ ref('fact_sales') }}
)
select raw.n as raw_rows, fact.n as fact_rows, raw.sales as raw_sales, fact.sales as fact_sales
from raw, fact
where raw.n <> fact.n
   or abs(raw.sales  - fact.sales)  > 0.01
   or abs(raw.profit - fact.profit) > 0.01
