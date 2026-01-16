-- Кейс: Анализ этапов жизненного цикла задач (Event Lifecycle)
-- Стек: ClickHouse (CTE, Inner Join для фильтрации воронки, сложный CASE)

WITH
  -- 1. Выделяем только те задачи, которые были успешно приняты в работу
  Accepted_Tasks AS (
    SELECT
      TaskID
    FROM Fact_Event_Log
    PREWHERE Event_Name = 'Task_Accepted_By_User'
      AND toYear(ReportDate) = 2025
      AND toHour(EventTimestamp) BETWEEN 8 AND 22
    GROUP BY TaskID
  )

-- 2. Расчет среднего времени нахождения задачи в каждом статусе
SELECT
  formatDateTime(dt.ReportDate, '%b. %Y') AS `Period`,
  dt.Event_Name AS `Status_Step`,
  ROUND(AVG(dt.StepDurationSeconds)) AS `Avg_Duration_Sec`
FROM Fact_Event_Log dt
INNER JOIN Accepted_Tasks USING (TaskID) -- Оставляем только "валидные" цепочки событий
LEFT JOIN Dim_Org_Structure bhd USING (LocationID)
PREWHERE toYear(dt.ReportDate) = 2025
  AND toHour(dt.EventTimestamp) BETWEEN 8 AND 22
WHERE bhd.IsActive = 1
GROUP BY ReportDate, Event_Name
ORDER BY ReportDate DESC, MIN(EventTimestamp) ASC
SETTINGS max_bytes_before_external_group_by = 5000000000;