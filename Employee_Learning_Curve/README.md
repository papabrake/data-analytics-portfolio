Project: Learning Curve Analysis (Tenure vs. Performance)
Business Problem: The goal was to visualize the "learning curve" of new employees. We needed to understand how many months it takes for a new hire to reach the average processing speed of experienced staff.

Analysis Logic:

Cohort Analysis: Created employee cohorts based on their hire date using MIN(date).

Time Intelligence: Used dateDiff to calculate the exact experience in months for every single operation.

Segmentation: Grouped staff into 4 categories (Newbies to Experienced) to compare productivity gaps.

Technical Stack: ClickHouse SQL, dateDiff, Cohort Analysis, Big Data Optimization.