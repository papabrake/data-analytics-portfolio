#### **Project: ROI Analysis for Automated Parcel Lockers (Postamat Economy)**
**Business Problem:** The company invested in automated lockers (Postamats). Management needed to know the exact monetary value of the staff time saved by these devices.

**My Solution:**
I built a model that calculates savings by:
1. Identifying the **average manual issuance time** for similar online orders at each specific branch.
2. Calculating the **actual hourly rate** for retail staff at each branch (Total Payroll / Total Hours).
3. Multiplying the "freed-up" hours by the hourly rate to get a direct **monetary impact**.

[cite_start]**Outcome:** In Dec 2025, the economy reached **435k RUB** for the analyzed region[cite: 123, 173], justifying further expansion of the project.

**Technical Stack:** `ClickHouse SQL`, `Financial Modeling`, `ROI Calculation`.