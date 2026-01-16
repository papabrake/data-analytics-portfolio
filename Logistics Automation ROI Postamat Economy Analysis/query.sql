-- Кейс: Расчет финансовой экономии от внедрения постаматов (ROI Analysis)
-- Стек: ClickHouse (Сложные вложенные агрегаты, расчет стоимости часа)

WITH 
  -- 1. Выделяем филиалы с активными постаматами
  Active_Postamats AS (
    SELECT BranchID, RegionName FROM Dim_Org_Structure
    WHERE BranchID IN (SELECT DISTINCT BranchID FROM Fact_Postamat_Metrics)
      AND BranchType = 'Retail'
  ),

  -- 2. Считаем объем выдач через постаматы по месяцам
  Postamat_Volume AS (
    SELECT 
        toStartOfMonth(ReportDate) as ReportMonth,
        BranchID,
        SUM(PostamatIssuedCount) as IssuedDocs
    FROM Fact_Postamat_Metrics
    GROUP BY ReportMonth, BranchID
  ),

  -- 3. Считаем среднее время ручной выдачи заказа (Benchmark)
  Manual_Issuance_Time AS (
    SELECT 
        toStartOfMonth(StartTime) as ReportMonth,
        BranchID,
        avgMerge(ProcessingTime) as AvgManualTime
    FROM Aggregate_Sales_Logs
    WHERE OrderSource LIKE 'Website%' -- Анализируем только интернет-заказы
    GROUP BY ReportMonth, BranchID
  ),

  -- 4. Рассчитываем стоимость человеко-часа для каждого филиала
  Staff_Cost_Per_Hour AS (
    SELECT 
        toStartOfMonth(PayrollPeriod) as ReportMonth,
        BranchID,
        SUM(TotalPayroll) / SUM(ActualHours) as HourlyRate
    FROM Fact_Payroll_Data
    WHERE Role IN ('Warehouse_Staff', 'Sales_Consultant', 'Store_Manager')
    GROUP BY ReportMonth, BranchID
  )

-- Финальный расчет экономии: (Кол-во выдач * Время выдачи / 3600) * Стоимость часа
SELECT
    pv.ReportMonth AS `Date`,
    SUM(((mit.AvgManualTime * pv.IssuedDocs) / 3600) * sch.HourlyRate) AS `Savings_Amount_RUB`
FROM Postamat_Volume pv
JOIN Active_Postamats ap ON pv.BranchID = ap.BranchID
JOIN Manual_Issuance_Time mit ON pv.BranchID = mit.BranchID AND pv.ReportMonth = mit.ReportMonth
JOIN Staff_Cost_Per_Hour sch ON pv.BranchID = sch.BranchID AND pv.ReportMonth = sch.ReportMonth
WHERE pv.ReportMonth >= now() - INTERVAL 6 MONTH
GROUP BY pv.ReportMonth
ORDER BY pv.ReportMonth DESC;