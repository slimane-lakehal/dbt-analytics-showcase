-- stg_orders.sql
-- Cleans and standardizes raw order data from Olist source.
-- One row per order.

with source as (
    select * from {{ source('olist', 'orders') }}
),

renamed as (
    select
        -- ids
        order_id,
        customer_id,

        -- status
        order_status,

        -- timestamps (cast to proper types)
        cast(order_purchase_timestamp  as timestamp) as purchased_at,
        cast(order_approved_at         as timestamp) as approved_at,
        cast(order_delivered_carrier_date as timestamp) as delivered_to_carrier_at,
        cast(order_delivered_customer_date as timestamp) as delivered_to_customer_at,
        cast(order_estimated_delivery_date as timestamp) as estimated_delivery_at,

        -- derived
        case
            when order_status = 'delivered' then true
            else false
        end as is_delivered,

        -- delivery time in days (null if not delivered)
        case
            when order_status = 'delivered'
                and order_delivered_customer_date is not null
                and order_purchase_timestamp is not null
            then datediff(
                'day',
                cast(order_purchase_timestamp as timestamp),
                cast(order_delivered_customer_date as timestamp)
            )
            else null
        end as delivery_time_days

    from source
    where order_id is not null
)

select * from renamed
