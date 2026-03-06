-- analyses/top_customers.sql
-- Ad-hoc analysis: Top 20 customers by lifetime revenue.
-- Run with: dbt compile --select top_customers
-- Then execute the compiled SQL in your DuckDB client.

select
    customer_unique_id,
    customer_state,
    customer_segment,
    lifetime_order_count,
    lifetime_revenue,
    avg_order_value,
    avg_delivery_time_days,
    is_repeat_buyer,
    first_order_at,
    last_order_at,

    -- days since last order (recency)
    datediff('day', last_order_at, current_date) as days_since_last_order

from {{ ref('dim_customers') }}
order by lifetime_revenue desc
limit 20
