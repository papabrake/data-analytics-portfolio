-- Кейс: Анализ операционной нагрузки по типам задач
-- Стек: ClickHouse (Фильтрация массивов данных, расчет агрегатов Big Data)

WITH
  -- 1. Сбор и очистка данных по ключевым операциям
  FilteredTasks AS (
    SELECT
        dt.ReportMonth,
        dt.TaskID,
        dt.TaskType,
        dt.DurationSeconds
    FROM Fact_Warehouse_Operations dt
    LEFT JOIN Dim_Org_Structure bhd USING (LocationID)
    PREWHERE
        toHour(dt.StartTime) BETWEEN 8 AND 22 -- Только дневные смены
        AND toYear(ReportMonth) = 2025
        -- Фокусируемся на ключевых складских и логистических операциях
        AND TaskType IN (
          'Inventory_Check', 'Order_Picking', 'Customer_Delivery', 
          'Loading_Unloading', 'Internal_Transfer', 'Labeling', 'Sorting'
        )
    WHERE
        bhd.IsDeleted = 0
  )

-- 2. Расчет KPI: среднее время, общие трудозатраты и объем задач
SELECT
    TaskType AS `Operation_Type`,
    ROUND(AVG(DurationSeconds)) AS `Avg_Time_Sec`,
    SUM(DurationSeconds) AS `Total_Labor_Time_Sec`,
    COUNT(DISTINCT TaskID) AS `Task_Volume`
FROM
    FilteredTasks
GROUP BY
    TaskType
ORDER BY
    `Task_Volume` DESC
-- Оптимизация для обработки миллионов строк
SETTINGS 
    max_bytes_before_external_group_by = 10000000000,
    max_bytes_before_external_sort = 10000000000;