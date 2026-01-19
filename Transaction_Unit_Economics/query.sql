-- Кейс: Анализ удельной стоимости транзакции (Cost per Transaction)
-- Стек: ClickHouse (Финансовая агрегация sumIf, LEFT JOIN по времени и филиалу)

WITH
  -- 1. Подсчет объема транзакций по филиалам
  Monthly_Sales_Volume AS (
    SELECT
      StartOfMonth,
      BranchID,
      COUNT(InvoiceID) AS Total_Transactions
    FROM Fact_Sales_Summary
    LEFT JOIN Dim_Org_Structure USING(BranchID)
    WHERE PositiveAmount = 1
      AND StartOfMonth BETWEEN '2023-01-01' AND '2027-01-01'
      AND IsActive = 1
    GROUP BY StartOfMonth, BranchID
  ),

  -- 2. Агрегация всех расходов на персонал (ФОТ)
  Personnel_Expenses AS (
    SELECT
      StartOfMonth,
      BranchID,
      SUM(DebitAmount) AS Total_Personnel_Cost
    FROM Fact_Financial_Ledger
    WHERE Expense_Category IN (
      'Salaries', 'Sick_Leave', 'Maternity_Leave', 'Business_Trips', 
      'Vacation_Pay', 'Labor_Taxes', 'Employee_Bonuses', 'Annual_Bonuses'
    )
    GROUP BY StartOfMonth, BranchID
  )

-- 3. Расчет средней стоимости обслуживания одной транзакции
SELECT
  formatDateTime(kt.StartOfMonth, '%b. %Y') AS `Period`,
  toYear(kt.StartOfMonth) AS `Year`,
  -- Суммируем ФОТ и делим на количество чеков
  SUM(pe.Total_Personnel_Cost) / SUM(kt.Total_Transactions) AS `Cost_Per_Transaction`
FROM Monthly_Sales_Volume kt
LEFT JOIN Personnel_Expenses pe ON kt.StartOfMonth = pe.StartOfMonth 
  AND kt.BranchID = pe.BranchID
GROUP BY StartOfMonth
ORDER BY StartOfMonth;