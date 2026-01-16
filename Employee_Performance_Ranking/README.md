#### **Project: Employee Performance Ranking & Productivity**
**Business Problem:** The objective was to create a granular ranking system to identify high-potential employees and those needing additional training within specific job roles.

**Analysis Logic:**
* **Multi-Source Joining:** Integrated operational data with HR payroll metadata using a composite key (Month + Location + UserID).
* **Data Quality:** Filtered out employees with zero working hours and empty job titles to ensure ranking accuracy.
* **Scalability:** Optimized for big data processing to handle thousands of employees across multiple regions.

**Technical Stack:** `ClickHouse SQL`, `Composite Joins`, `Performance Ranking`, `HR Analytics`.