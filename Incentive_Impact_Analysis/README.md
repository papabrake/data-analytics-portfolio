Project: Impact of Incentive Pay on Operational Speed
Business Question: Does a piecework payment model actually speed up staff performance compared to a fixed salary model?

Analysis Logic:

Data Aggregation: Used maxIf and sumIf in ClickHouse to calculate metrics for only accepted tasks.

Integration: Joined operational logs with a dynamic motivation model table that tracks changes in payment types over time.

Formatting: Created a month-by-month performance comparison to see long-term trends.

Technical Stack: ClickHouse SQL, Complex Joins, Conditional Aggregations.