-- stg_order_items.sql
-- One row per item per order. An order can have multiple items.

with source as (
    select * from {{ source('olist', 'order_items') }}
),

renamed as (
    select
        order_id,
        order_item_id,              -- position within the order (1, 2, 3...)
        product_id,
        seller_id,

        -- financials (in BRL)
        round(cast(price as decimal(10,2)), 2)          as item_price,
        round(cast(freight_value as decimal(10,2)), 2)  as freight_value,
        round(
            cast(price as decimal(10,2)) +
            cast(freight_value as decimal(10,2)), 2
        ) as total_item_value,

        cast(shipping_limit_date as timestamp) as shipping_limit_at

    from source
    where order_id is not null
      and product_id is not null
)

select * from renamed
