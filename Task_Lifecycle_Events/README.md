#### **Project: Task Lifecycle & Event Duration Analysis**
**Business Problem:** The management needed to visualize the "internal life" of a task. Which specific events (e.g., "Accepted", "In Progress", "Paused") take the most time, and where are the operational bottlenecks?

**Analysis Logic:**
* **Funnel Filtering:** Used an `INNER JOIN` with a CTE to isolate only the tasks that reached the "Accepted" stage, ensuring data integrity.
* **Time Formatting:** Implemented a custom `CASE` (or `formatDateTime`) logic to provide a readable monthly timeline.
* **Performance:** Handled granular event data using ClickHouse's optimized `PREWHERE` and memory settings.

**Technical Stack:** `ClickHouse SQL`, `Event Analytics`, `Inner Joins`, `Data Granularity`.