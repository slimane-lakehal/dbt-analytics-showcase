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
	@echo "Installing dependencies with uv..."
	uv sync
	uv run dbt deps
	@echo "Setup complete"


load:
	@echo "Loading data into DuckDB..."
	uv run python scripts/load_data.py

build:
	@echo "Running dbt models..."
	uv run dbt run --profiles-dir .

test:
	@echo "Running dbt tests..."
	uv run dbt test --profiles-dir .

docs:
	@echo "Generating dbt docs..."
	uv run dbt docs generate --profiles-dir .
	uv run dbt docs serve --profiles-dir . --port 8080

clean:
	@echo "Cleaning..."
	uv run dbt clean
	rm -f dev.duckdb

# Full pipeline in one shot
run-all: load build test
	@echo ""
	@echo "Pipeline complete. Run 'make docs' to explore."
