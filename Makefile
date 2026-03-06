.PHONY: help setup load build test docs clean run-all

# Default target
help:
	@echo ""
	@echo "  dbt-analytics-showcase — Makefile"
	@echo "  =================================="
	@echo ""
	@echo "  make setup       → Install dependencies"
	@echo "  make load        → Load Olist CSVs into DuckDB"
	@echo "  make build       → dbt run (create models)"
	@echo "  make test        → dbt test (run all tests)"
	@echo "  make docs        → Generate + serve dbt docs"
	@echo "  make run-all     → load + build + test (full pipeline)"
	@echo "  make clean       → Remove compiled artifacts"
	@echo ""

setup:
	@echo "Creating a virtual environment and installing dependencies..."
	python -m venv .venv
	.venv/bin/pip install --upgrade pip
	.venv/bin/pip install dbt-core dbt-duckdb
	.venv/bin/dbt deps
	@echo "Setup complete"


load:
	@echo "Loading data into DuckDB..."
	.venv/bin/python scripts/load_data.py

build:
	@echo "Running dbt models..."
	.venv/bin/dbt run --profiles-dir .

test:
	@echo "Running dbt tests..."
	.venv/bin/dbt test --profiles-dir .

docs:
	@echo "Generating dbt docs..."
	.venv/bin/dbt docs generate --profiles-dir .
	.venv/bin/dbt docs serve --profiles-dir . --port 8080

clean:
	@echo "Cleaning..."
	.venv/bin/dbt clean
	rm -f dev.duckdb

# Full pipeline in one shot
run-all: load build test
	@echo ""
	@echo "Pipeline complete. Run 'make docs' to explore."
