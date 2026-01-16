-- Кейс: Влияние системы мотивации (Сдельная vs Фикс) на скорость выполнения операций
-- Стек: ClickHouse (агрегатные функции maxIf/sumIf, сложная логика CASE)

WITH
  -- 1. Сбор данных об операциях и их длительности
  Operations_Log AS (
    SELECT
      dt.OperationDate,
      dt.TaskID,
      bhd.RegionID,
      -- Флаг успешного принятия задачи пользователем
      maxIf(1, dt.Status = 'Accepted') AS is_accepted,
      sum(dt.DurationSeconds) AS TotalDuration
    FROM Fact_Detailed_Operations AS dt
    LEFT JOIN Dim_Org_Structure AS bhd USING (RegionID) 
    PREWHERE toHour(dt.Timestamp) BETWEEN 8 AND 22 -- Фильтр операционного времени
      AND toYear(dt.OperationDate) >= 2024
    WHERE bhd.IsActive = 1
    GROUP BY dt.TaskID, dt.OperationDate, bhd.RegionID
  ),

  -- 2. Определение типа мотивации на уровне подразделения
  Motivation_Type AS (
    SELECT
      PeriodDate AS OperationDate,
      RegionID,
      -- Группировка филиалов по типу оплаты (Сдельная/Оклад)
      maxIf(1, PaymentModel IN ('Piecework', 'Performance_Based')) AS IsIncentivized
    FROM Dim_Compensation_Models
    GROUP BY OperationDate, RegionID
  )

-- 3. Финальный расчет KPI по месяцам
SELECT
  -- Форматирование даты для отчета
  formatDateTime(ol.OperationDate, '%b. %Y') AS `Month_Year`,
  CASE
    WHEN mt.IsIncentivized = 1 THEN 'Incentive-Based Pay'
    ELSE 'Fixed Salary'
  END AS `Payment_Model`,
  -- Расчет среднего времени на одну принятую задачу
  ROUND(sum(ol.TotalDuration) / countIf(ol.is_accepted = 1)) AS `Avg_Time_Sec`
FROM Operations_Log AS ol
LEFT JOIN Motivation_Type AS mt USING (RegionID, OperationDate)
WHERE ol.is_accepted = 1
  AND ol.OperationDate < toStartOfMonth(today())
GROUP BY ol.OperationDate, mt.IsIncentivized
ORDER BY ol.OperationDate DESC