-- One row per distinct geography in the source (country, region, state, city, postal code).

select distinct
    md5(concat_ws('|', country, region, state, city, postal_code))  as location_key,
    country,
    region,
    state,
    city,
    postal_code
from {{ ref('stg_superstore') }}
