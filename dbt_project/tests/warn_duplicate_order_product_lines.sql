{{ config(severity='warn') }}
-- Known data quirk: a few orders contain the same product on more than one line.
-- They may be legitimate separate lines, so we keep them and only warn.
select order_id, product_id, count(*) as line_count
from {{ ref('stg_superstore') }}
group by order_id, product_id
having count(*) > 1
