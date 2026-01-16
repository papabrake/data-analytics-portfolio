-- Кейс: Анализ эффективности региональных подразделений в сравнении с эталонным регионом
-- Стек: ClickHouse (использование PREWHERE и функций времени)

WITH
-- 1. Подготовка данных с фильтрацией по рабочим часам и исключение помеченных объектов
TargetData AS (
    SELECT
        RegionName,
        LocationName,
        ExecuteDuration
    FROM Fact_Logistics_Operations
    LEFT JOIN Dim_Org_Structure USING (LocationID)
    PREWHERE 
        toHour(TaskStart) BETWEEN 8 AND 22 -- Фильтр операционного времени
        AND toYear(ReportMonth) = 2025
    WHERE
        IsActive = 1
        AND OperationType = 'Standard_Shipping'
),

-- 2. Расчет эталонного значения (Benchmark) на основе выбранного топ-региона
Benchmark AS (
    SELECT
        ROUND(AVG(ExecuteDuration)) AS Benchmark_Avg
    FROM Fact_Logistics_Operations
    LEFT JOIN Dim_Org_Structure USING (LocationID)
    PREWHERE 
        toHour(TaskStart) BETWEEN 8 AND 22
        AND toYear(ReportMonth) = 2025
    WHERE
        IsActive = 1
        AND RegionName = 'Strategic_North_Region' -- Эталонная группа
)

-- 3. Вывод подразделений, чья эффективность выше или равна эталонной
SELECT
    t.LocationName AS `Branch`,
    ROUND(AVG(t.ExecuteDuration)) AS `Avg_Processing_Time`,
    b.Benchmark_Avg AS `Target_Benchmark`
FROM TargetData t
CROSS JOIN Benchmark b
GROUP BY t.LocationName, b.Benchmark_Avg
HAVING AVG(t.ExecuteDuration) <= b.Benchmark_Avg 
   AND AVG(t.ExecuteDuration) > 0
ORDER BY `Avg_Processing_Time` ASC
