-- int_orders_enriched.sql
-- Enriches orders with customer, items, and payment data.
-- Materialized as ephemeral (no table created, just a CTE reused by marts).
-- One row per order.

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

-- Aggregate items per order
order_items_agg as (
    select
        order_id,
        count(*)                    as item_count,
        sum(item_price)             as items_revenue,
        sum(freight_value)          as total_freight,
        sum(total_item_value)       as total_order_value
    from {{ ref('stg_order_items') }}
    group by order_id
),

-- Aggregate payments per order
payments_agg as (
    select
        order_id,
        sum(payment_value)          as total_paid,
        count(distinct payment_type) as payment_methods_count,
        max(installments)           as max_installments,
        -- flag orders paid with credit card
        max(case when payment_type = 'credit_card' then 1 else 0 end) as has_credit_card
    from {{ ref('stg_payments') }}
    group by order_id
),

enriched as (
    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.purchased_at,
        o.approved_at,
        o.delivered_to_customer_at,
        o.estimated_delivery_at,
        o.is_delivered,
        o.delivery_time_days,

        -- customer info
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,

        -- order financials
        coalesce(i.item_count, 0)       as item_count,
        coalesce(i.items_revenue, 0)    as items_revenue,
        coalesce(i.total_freight, 0)    as total_freight,
        coalesce(i.total_order_value, 0) as total_order_value,
        coalesce(p.total_paid, 0)       as total_paid,

        -- payment details
        p.payment_methods_count,
        p.max_installments,
        cast(p.has_credit_card as boolean) as has_credit_card,

        -- time features (useful for mart aggregations)
        date_trunc('day',  o.purchased_at) as order_date,
        date_trunc('week', o.purchased_at) as order_week,
        date_trunc('month',o.purchased_at) as order_month,
        date_part('year',  o.purchased_at) as order_year,
        date_part('month', o.purchased_at) as order_month_num

    from orders o
    left join customers c        on o.customer_id = c.customer_id
    left join order_items_agg i  on o.order_id = i.order_id
    left join payments_agg p     on o.order_id = p.order_id
)

select * from enriched
