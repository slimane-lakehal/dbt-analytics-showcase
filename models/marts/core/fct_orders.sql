-- fct_orders.sql
-- Fact table: one row per order with all metrics.
-- The central table for revenue and operational analytics.

with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

customers as (
    select customer_unique_id, customer_key
    from {{ ref('dim_customers') }}
),

products_per_order as (
    -- Most common category per order
    select
        oi.order_id,
        sp.product_category,
        count(*) as category_count,
        row_number() over (
            partition by oi.order_id
            order by count(*) desc
        ) as rn
    from {{ ref('stg_order_items') }} oi
    left join {{ ref('stg_products') }} sp on oi.product_id = sp.product_id
    group by oi.order_id, sp.product_category
),

main_category as (
    select order_id, product_category as main_product_category
    from products_per_order
    where rn = 1
),

final as (
    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['o.order_id']) }} as order_key,

        -- natural keys
        o.order_id,
        o.customer_id,
        c.customer_key,

        -- foreign keys for dimensions
        o.order_date,
        o.order_week,
        o.order_month,
        o.order_year,

        -- status
        o.order_status,
        o.is_delivered,

        -- product
        mc.main_product_category,

        -- location
        o.customer_state,
        o.customer_city,

        -- metrics
        o.item_count,
        o.items_revenue,
        o.total_freight,
        o.total_order_value,
        o.total_paid,
        o.delivery_time_days,
        o.max_installments,
        o.has_credit_card,

        -- timestamps
        o.purchased_at,
        o.approved_at,
        o.delivered_to_customer_at,
        o.estimated_delivery_at

    from orders o
    left join customers c       on o.customer_unique_id = c.customer_unique_id
    left join main_category mc  on o.order_id = mc.order_id
)

select * from final
