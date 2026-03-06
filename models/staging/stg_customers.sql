-- stg_customers.sql
-- Cleans customer data. Note: customer_id is order-scoped in Olist,
-- customer_unique_id is the true unique customer identifier.

with source as (
    select * from {{ source('olist', 'customers') }}
),

renamed as (
    select
        customer_id,          -- order-scoped key (used to join with orders)
        customer_unique_id,   -- real customer identity across orders

        -- location
        {{ clean_string('customer_city') }}   as customer_city,
        {{ clean_string('customer_state') }}  as customer_state,
        customer_zip_code_prefix              as customer_zip_prefix

    from source
    where customer_id is not null
)

select * from renamed
