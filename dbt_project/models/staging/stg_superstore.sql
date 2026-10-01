-- Staging: 1-to-1 with the raw table. Only renaming, casting and light cleaning.
--   * snake_case column names
--   * proper data types
--   * postal codes restored to 5 digits (Excel dropped the leading zero, e.g. 6120 -> 06120)

select
    cast("Row ID" as integer)                          as row_id,
    trim("Order ID")                                   as order_id,
    cast("Order Date" as date)                         as order_date,
    cast("Ship Date" as date)                          as ship_date,
    trim("Ship Mode")                                  as ship_mode,
    trim("Customer ID")                                as customer_id,
    trim("Customer Name")                              as customer_name,
    trim("Segment")                                    as segment,
    trim("Country")                                    as country,
    trim("City")                                       as city,
    trim("State")                                      as state,
    lpad(cast("Postal Code" as varchar), 5, '0')       as postal_code,
    trim("Region")                                     as region,
    trim("Product ID")                                 as product_id,
    trim("Category")                                   as category,
    trim("Sub-Category")                               as sub_category,
    trim("Product Name")                               as product_name,
    cast("Sales" as decimal(18, 4))                    as sales,
    cast("Quantity" as integer)                        as quantity,
    cast("Discount" as decimal(5, 2))                  as discount,
    cast("Profit" as decimal(18, 4))                   as profit
from {{ source('ods', 'superstore_raw') }}
