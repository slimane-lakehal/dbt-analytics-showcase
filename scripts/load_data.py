"""
scripts/load_data.py
--------------------
Loads all Olist CSV files from ./data/ into DuckDB (dev.duckdb).
Registers each CSV as a table named after the filename (without extension).

Usage:
    python scripts/load_data.py
"""

import duckdb
import glob
import os

DB_PATH = "./dev.duckdb"
DATA_DIR = "./data"

def load_csv_files():
    con = duckdb.connect(DB_PATH)
    csv_files = glob.glob(os.path.join(DATA_DIR, "*.csv"))

    if not csv_files:
        print(f"No CSV files found in {DATA_DIR}/")
        print("--> Download from: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce")
        return

    for filepath in csv_files:
        table_name = os.path.splitext(os.path.basename(filepath))[0]
        print(f"  Loading {table_name}...", end=" ")

        con.execute(f"""
            CREATE OR REPLACE TABLE "{table_name}" AS
            SELECT * FROM read_csv_auto('{filepath}', header=true)
        """)

        count = con.execute(f'SELECT COUNT(*) FROM "{table_name}"').fetchone()[0]
        print(f"{count:,} rows")

    print(f"\n All tables loaded into {DB_PATH}")
    con.close()


if __name__ == "__main__":
    os.makedirs(DATA_DIR, exist_ok=True)
    load_csv_files()
