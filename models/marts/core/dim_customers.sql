-- dim_customers.sql
-- Customer dimension. One row per unique customer (customer_unique_id).
-- Computes lifetime metrics: order count, revenue, first/last order, etc.

with orders as (
    select * from {{ ref('int_orders_enriched') }}
    where order_status not in ('canceled', 'unavailable')
),

customer_orders as (
    select
        customer_unique_id,
        customer_state,
        customer_city,

        count(distinct order_id)                as lifetime_order_count,
        sum(total_order_value)                  as lifetime_revenue,
        avg(total_order_value)                  as avg_order_value,
        min(purchased_at)                       as first_order_at,
        max(purchased_at)                       as last_order_at,
        avg(delivery_time_days)                 as avg_delivery_time_days,
        sum(case when has_credit_card then 1 else 0 end) as credit_card_orders

    from orders
    group by customer_unique_id, customer_state, customer_city
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['customer_unique_id']) }} as customer_key,
        customer_unique_id,
        customer_city,
        customer_state,

        lifetime_order_count,
        round(lifetime_revenue, 2)              as lifetime_revenue,
        round(avg_order_value, 2)               as avg_order_value,
        first_order_at,
        last_order_at,
        round(avg_delivery_time_days, 1)        as avg_delivery_time_days,

        -- customer segment based on revenue
        case
            when lifetime_revenue >= 1000 then 'VIP'
            when lifetime_revenue >= 300  then 'Regular'
            else 'Occasional'
        end as customer_segment,

        -- repeat buyer flag
        case when lifetime_order_count > 1 then true else false end as is_repeat_buyer

    from customer_orders
)

select * from final
