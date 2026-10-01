-- Fails if any order line ships before it was ordered.
select row_id, order_date, ship_date
from {{ ref('stg_superstore') }}
where ship_date < order_date
