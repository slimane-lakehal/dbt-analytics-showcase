-- mart_revenue_daily.sql
-- Daily revenue aggregation. Ready for dashboarding.
-- Includes rolling 7-day and 30-day averages for trend analysis.

with daily as (
    select
        order_date,
        order_year,
        order_month,
        customer_state,
        main_product_category,

        count(distinct order_id)            as order_count,
        count(distinct customer_id)         as unique_customers,
        sum(total_order_value)              as gross_revenue,
        sum(total_freight)                  as freight_revenue,
        sum(items_revenue)                  as items_revenue,
        avg(total_order_value)              as avg_order_value,
        sum(item_count)                     as total_items_sold,
        avg(delivery_time_days)             as avg_delivery_days,
        sum(case when is_delivered then 1 else 0 end) as delivered_orders,
        sum(case when has_credit_card then 1 else 0 end) as credit_card_orders

    from {{ ref('fct_orders') }}
    where order_status not in ('canceled', 'unavailable')
      and order_date >= '{{ var("start_date") }}'
    group by 1, 2, 3, 4, 5
),

with_rolling as (
    select
        *,
        round(
            avg(gross_revenue) over (
                partition by customer_state
                order by order_date
                rows between 6 preceding and current row
            ), 2
        ) as rolling_7d_revenue,

        round(
            avg(gross_revenue) over (
                partition by customer_state
                order by order_date
                rows between 29 preceding and current row
            ), 2
        ) as rolling_30d_revenue,

        round(
            100.0 * delivered_orders / nullif(order_count, 0), 1
        ) as delivery_rate_pct

    from daily
)

select * from with_rolling
order by order_date desc, gross_revenue desc
