-- tests/assert_revenue_positive.sql
-- Singular test: ensures no order has negative revenue in fct_orders.
-- dbt will FAIL if this query returns any rows.

select
    order_id,
    total_order_value
from {{ ref('fct_orders') }}
where total_order_value < 0
