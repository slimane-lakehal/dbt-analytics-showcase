# dbt Analytics Showcase 🦆

> A production-grade analytics engineering project built with **dbt Core + DuckDB** on the Olist Brazilian E-Commerce dataset. Demonstrates modern data modeling patterns: Medallion architecture, dimensional modeling, data quality testing, and automated CI/CD.

---

## Problem Statement

Raw transactional data is rarely ready for business decisions. This project transforms 100k+ raw e-commerce orders into a clean, tested, documented analytics layer — enabling revenue tracking, customer segmentation, and delivery performance analysis.

---

## Architecture

```
Raw CSVs (Kaggle)
      │
      ▼
┌─────────────┐     ┌──────────────────┐     ┌────────────────────┐
│   Staging   │────▶│  Intermediate    │────▶│      Marts         │
│  (Views)    │     │  (Ephemeral)     │     │   (Tables)         │
│             │     │                  │     │                    │
│ stg_orders  │     │ int_orders_      │     │ dim_customers      │
│ stg_customers     │  enriched        │     │ fct_orders         │
│ stg_products│     │                  │     │ mart_revenue_daily │
│ stg_payments│     └──────────────────┘     └────────────────────┘
│ stg_items   │
└─────────────┘
```

**Layer responsibilities:**

| Layer | Materialization | Role |
|-------|----------------|------|
| **Staging** | Views | 1-to-1 with sources. Rename, cast, clean only. |
| **Intermediate** | Ephemeral | Join & enrich staging. No business logic yet. |
| **Marts** | Tables | Business-facing. Ready for BI tools. |

---

## Key Models

### `fct_orders` — Fact Table
One row per order. Central table for all revenue reporting.

| Column | Description |
|--------|-------------|
| `order_id` | Natural key |
| `total_order_value` | Items + freight (BRL) |
| `is_delivered` | Delivery boolean |
| `delivery_time_days` | Purchase → delivery |
| `main_product_category` | Most purchased category |

### `dim_customers` — Customer Dimension
One row per unique customer with lifetime metrics.

| Column | Description |
|--------|-------------|
| `customer_unique_id` | True customer identity |
| `lifetime_revenue` | All-time spend (BRL) |
| `customer_segment` | VIP / Regular / Occasional |
| `is_repeat_buyer` | Purchased more than once |

### `mart_revenue_daily` — Analytics Mart
Daily revenue aggregated by state & category. Includes rolling 7-day and 30-day averages.

---

## Quick Start

```bash
# 1. Clone & setup
git clone https://github.com/slimane-lakehal/dbt-analytics-showcase.git
cd dbt-analytics-showcase
make setup

# 2. Download Olist dataset from Kaggle → put CSVs in ./data/
#    https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

# 3. Load data + run models + run tests
make run-all

# 4. Explore the docs
make docs   # Opens at http://localhost:8080
```

---

## Data Quality

This project uses **dbt tests** + **dbt_expectations** to validate data at every layer:

```bash
dbt test --profiles-dir .
```

Tests include:
- `unique` and `not_null` on all primary keys
- `accepted_values` for status fields
- `expect_column_values_to_be_between` for prices and delivery times
- Custom singular test: `assert_revenue_positive`
- Referential integrity between orders and customers

**Test coverage:** 25+ tests across 5 staging models + 2 mart models

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| **dbt Core 1.8** | Transformation layer |
| **DuckDB** | Local OLAP database (zero config) |
| **dbt_utils** | Surrogate keys, test macros |
| **dbt_expectations** | Great Expectations-style tests |
| **GitHub Actions** | Automated CI on every push |
| **Python** | Data loading script |

---

## Project Structure

```
dbt-analytics-showcase/
├── models/
│   ├── staging/          # Source-aligned views
│   ├── intermediate/     # Ephemeral enrichment
│   └── marts/
│       ├── core/         # dim & fct tables
│       └── analytics/    # Aggregated marts for BI
├── macros/
│   └── clean_string.sql  # Reusable string normalization
├── tests/
│   └── assert_revenue_positive.sql
├── analyses/
│   └── top_customers.sql
├── scripts/
│   └── load_data.py      # CSV → DuckDB loader
├── .github/workflows/
│   └── dbt-ci.yml        # CI pipeline
├── dbt_project.yml
├── profiles.yml
├── packages.yml
└── Makefile
```

---

## Key Design Decisions

**Why DuckDB?** Zero setup, runs in-process, handles analytical queries 10-100x faster than Pandas. Ideal for local development and small-to-medium datasets.

**Why ephemeral for intermediate?** No persistent table = no extra storage cost. The enrichment logic becomes a CTE compiled into each mart — keeping the warehouse lean.

**Why surrogate keys?** `customer_id` in Olist is order-scoped (not truly unique per customer). Surrogate keys built on `customer_unique_id` ensure stable joins across the warehouse.

---

## CI/CD

Every push to `main` or `develop` triggers:
1. `dbt deps` — install packages
2. `dbt build` — compile, run, test all models
3. `dbt docs generate` — publish docs as CI artifact

See [`.github/workflows/dbt-ci.yml`](.github/workflows/dbt-ci.yml)

---

## Sample Insights

*(Generated from `mart_revenue_daily` and `dim_customers`)*

- **~96,000** orders processed across 2 years
- **Top states by revenue:** SP, RJ, MG
- **Average delivery time:** ~12 days
- **Credit card** is the dominant payment method (~75%)
- **Repeat buyers** account for <5% of customers but >15% of revenue

---

## Author

**Slimane** — Data Analyst & Analytics Engineer  
Instructor @ Le Wagon · Founder @ AuditGuard AI · LIFO.AI

[LinkedIn](https://www.linkedin.com/in/lakehal-slimane/) · [Portfolio](https://slimane-lakehal.github.io/portfolio/) · [GitHub](https://github.com/slimane-lakehal)

---

*Built as part of a public portfolio. Dataset: [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (CC BY-NC-SA 4.0)*
