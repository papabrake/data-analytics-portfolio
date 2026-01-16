-- Кейс: Анализ корреляции между опытом сотрудника (Tenure) и скоростью выполнения задач
-- Стек: ClickHouse (dateDiff, агрегатные фильтры, оптимизация памяти)

WITH
-- 1. Определение даты начала работы для каждого сотрудника
Employee_Onboarding AS (
    SELECT
        UserID,
        MIN(toStartOfMonth(EventDate)) AS HireMonth
    FROM Fact_Employee_History
    WHERE EventType = 'Hired'
    GROUP BY UserID
),

-- 2. Сбор данных по операциям за текущий период
Operational_Tasks AS (
    SELECT
        ReportMonth,
        TaskID,
        UserID,
        DurationSeconds
    FROM Fact_Operations
    PREWHERE toHour(TaskStartTime) BETWEEN 8 AND 22 -- Учитываем только дневные смены
      AND toYear(ReportMonth) = 2025
    WHERE IsActive = 1
),

-- 3. Расчет стажа (в месяцах) на момент выполнения каждой задачи
Tenure_Calculation AS (
    SELECT
        t.ReportMonth,
        t.TaskID,
        t.DurationSeconds,
        dateDiff('month', e.HireMonth, t.ReportMonth) AS Months_Exp
    FROM Operational_Tasks t
    LEFT JOIN Employee_Onboarding e ON t.UserID = e.UserID
),

-- 4. Сегментация сотрудников по группам опыта
Experience_Segments AS (
    SELECT
        ReportMonth,
        TaskID,
        DurationSeconds,
        CASE
            WHEN Months_Exp < 1 THEN 'Newbie (0-1 mo)'
            WHEN Months_Exp < 3 THEN 'Junior (1-3 mo)'
            WHEN Months_Exp < 6 THEN 'Intermediate (3-6 mo)'
            ELSE 'Experienced (6+ mo)'
        END AS Experience_Level
    FROM Tenure_Calculation
)

-- 5. Итоговая статистика производительности по группам
SELECT
    formatDateTime(ReportMonth, '%m/%y') AS `Period`,
    Experience_Level,
    countDistinct(TaskID) AS `Total_Tasks`,
    ROUND(AVG(DurationSeconds)) AS `Avg_Processing_Time_Sec`
FROM Experience_Segments
GROUP BY ReportMonth, Experience_Level
ORDER BY ReportMonth DESC, Experience_Level
SETTINGS max_bytes_before_external_group_by = 10000000000;