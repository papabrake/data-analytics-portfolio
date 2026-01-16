#### **Project: Retail Efficiency Scorecard (Executive Dashboard)**
**Business Context:** A comprehensive "360-degree" view of branch performance, combining financial, operational, and HR data. This report was designed for executives to identify high-performing locations and optimize resource allocation.

**Key Metrics Analyzed:**
* **Labor Efficiency:** Payroll-to-turnover ratio.
* **Staff Productivity:** Invoices generated per working hour.
* **Digital Adoption:** Percentage of sales processed via self-service channels.
* **Real Estate ROI:** Revenue and staff density per square meter.

**Technical Highlights:**
* **Complex Data Modeling:** Synchronized 4 different data sources (Finance, Sales, HR, Assets) using multi-stage CTEs.
* **Big Data Logic:** Used `last_value` for area snapshots and `uniqIf` for high-speed conditional counting.

**Technical Stack:** `ClickHouse SQL`, `Business Intelligence`, `Resource Optimization`.