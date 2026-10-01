-- 32 product IDs appear under more than one name in the source.
-- Rule: keep the name from the first row where the product appears (lowest row_id).

select
    product_id,
    arg_min(product_name, row_id)   as product_name,
    min(category)                   as category,
    min(sub_category)               as sub_category
from {{ ref('stg_superstore') }}
group by product_id
