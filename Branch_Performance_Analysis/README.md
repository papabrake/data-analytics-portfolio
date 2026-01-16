Project: Branch Performance Benchmarking (ClickHouse SQL)
Business Problem: The management needed to identify regional branches that perform more efficiently than the company's "Gold Standard" (the Far East Division). The goal was to highlight top-performing units and investigate their best practices.

Technical Challenges:

Optimizing queries for large datasets in ClickHouse using PREWHERE.

Calculating a static benchmark (Reference point) that doesn't change when filtering specific branches.

Filtering out-of-hours operations (8:00 AM - 10:00 PM) to ensure data cleaness.

SQL Logic Explained:

TargetData CTE: Pre-filters the main dataset by operating hours and active status.

Benchmark CTE: Calculates the average execution time specifically for the 'Far East' region for the entire year.

Final Output: Uses a CROSS JOIN to compare every branch against the benchmark and a HAVING clause to filter only those that are faster (lower time) than the reference.

Key Skills: CTEs, Cross Joins, ClickHouse Optimization, Data Aggregation
