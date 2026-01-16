-- Кейс: Рейтинг личной производительности сотрудников по должностям
-- Стек: ClickHouse (двойной CTE, многоуровневый JOIN по дате, филиалу и ID)

WITH
  -- 1. Сбор данных по выполненным задачам
  Task_Log AS (
    SELECT
        bhd.LocationName,
        dt.UserID,
        dt.TaskID,
        dt.DurationSeconds,
        ReportMonth
    FROM Fact_Operations dt
    LEFT JOIN Dim_Org_Structure bhd USING (LocationID)
    PREWHERE toHour(dt.StartTime) BETWEEN 8 AND 22
      AND toYear(ReportMonth) = 2025
    WHERE bhd.IsActive = 1
  ),
  -- 2. Сбор данных о сотрудниках (Должность и ФИО) из системы мотивации
  Employee_Metadata AS (
    SELECT
      toStartOfMonth(Period) AS ReportMonth,
      LocationID,
      UserID,
      JobTitle,
      EmployeeName
    FROM Fact_Payroll_Incentives
    PREWHERE WorkingHours > 0
      AND toYear(ReportMonth) = 2025
    GROUP BY ReportMonth, LocationID, JobTitle, UserID, EmployeeName
  )

-- 3. Финальный расчет KPI: среднее время и объем работ на человека
SELECT
  formatDateTime(tl.ReportMonth, '%m/%y') AS `Period`,
  LocationName AS `Branch`,
  em.JobTitle,
  em.EmployeeName,
  ROUND(AVG(tl.DurationSeconds)) AS `Avg_Execution_Time_Sec`,
  COUNT(DISTINCT TaskID) AS `Total_Tasks_Completed`
FROM Task_Log tl
LEFT JOIN Employee_Metadata em ON tl.ReportMonth = em.ReportMonth
  AND tl.LocationID = em.LocationID
  AND tl.UserID = em.UserID
WHERE em.JobTitle != ''
GROUP BY tl.ReportMonth, LocationName, em.JobTitle, em.EmployeeName
ORDER BY tl.ReportMonth DESC, `Avg_Execution_Time_Sec` DESC
SETTINGS max_bytes_before_external_group_by = 10000000000;