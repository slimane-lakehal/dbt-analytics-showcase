# Data Directory

CSV files are **not committed** to this repo (too large for Git).

## How to get the data

1. Create a Kaggle account at https://www.kaggle.com
2. Download the Olist Brazilian E-Commerce dataset:
   https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
3. Extract all CSV files into this `data/` directory

Expected files:
```
data/
├── olist_orders_dataset.csv
├── olist_customers_dataset.csv
├── olist_order_items_dataset.csv
├── olist_products_dataset.csv
├── olist_sellers_dataset.csv
├── olist_order_payments_dataset.csv
├── olist_order_reviews_dataset.csv
└── product_category_name_translation.csv
```

Then run:
```bash
make load
```
