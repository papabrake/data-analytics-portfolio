-- Кейс: Комплексный анализ эффективности розничных точек (Efficiency Scorecard)
-- Стек: ClickHouse (Multi-CTE, complex JOINs, productivity metrics)

WITH
  -- 1. Финансовые показатели (Оборот и ФОТ)
  Finance_Metrics AS (
    SELECT
      ReportMonth,
      LocationID,
      LocationName,
      Turnover,
      Payroll_Total / Turnover AS Payroll_to_Turnover_Ratio
    FROM Fact_Branch_Finances
    LEFT JOIN Dim_Org_Structure USING(LocationID)
    WHERE IsActive = 1
      AND ReportMonth = '2025-11-01' -- Фильтр по периоду
  ),

  -- 2. Операционные показатели (Площади и Транзакции)
  Operations_Metrics AS (
    SELECT
      ReportMonth,
      LocationID,
      last_value(TotalSquare) AS Total_Area,
      last_value(SalesArea) AS Sales_Area,
      COUNT(InvoiceID) AS Total_Invoices,
      SUM(ItemsCount) AS Total_Items,
      -- Расчет доли самообслуживания (Digital Sales Share)
      uniqIf(InvoiceID, CreationSource IN ('Self_Service_Kiosk', 'Website', 'Mobile_App')) AS Digital_Invoices
    FROM Fact_Sales_Summary
    GROUP BY ReportMonth, LocationID
  ),

  -- 3. HR-метрики (Количество персонала и отработанные часы)
  HR_Metrics AS (
    SELECT
      toStartOfMonth(WorkDate) AS ReportMonth,
      LocationID,
      COUNT(DISTINCT StaffID) AS Headcount,
      SUM(ActualHours) AS Total_Working_Hours
    FROM Fact_Timesheet
    WHERE ActualHours >= 1
    GROUP BY ReportMonth, LocationID
  )

-- 4. Финальный расчет KPI для "витрины" управления
SELECT
    f.LocationName AS `Branch`,
    o.Total_Area AS `Total_Sq_M`,
    o.Sales_Area AS `Sales_Sq_M`,
    f.Turnover AS `Revenue`,
    f.Payroll_to_Turnover_Ratio AS `Labor_Cost_Efficiency`,
    o.Digital_Invoices / o.Total_Invoices AS `Self_Service_Share`,
    o.Total_Invoices / h.Total_Working_Hours AS `Invoices_per_Hour`, -- Продуктивность
    ROUND(o.Total_Items / o.Total_Invoices, 2) AS `Items_per_Basket`,
    f.Turnover / o.Total_Invoices AS `Average_Check`,
    h.Headcount AS `Total_Staff`
FROM Finance_Metrics f
LEFT JOIN Operations_Metrics o ON f.LocationID = o.LocationID AND f.ReportMonth = o.ReportMonth
LEFT JOIN HR_Metrics h ON f.LocationID = h.LocationID AND f.ReportMonth = h.ReportMonth
ORDER BY Revenue DESC
LIMIT 1000;