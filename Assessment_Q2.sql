-- Step 1: Count transactions per user per month
-- This subquery calculates how many transactions each user made in each month
WITH MonthlyTransactions AS (
  SELECT
    s.owner_id,
    DATE_FORMAT(s.transaction_date, '%Y-%m') AS txn_month,  -- Extract year and month from transaction date
    COUNT(*) AS monthly_txn_count         -- Count of transactions per user per month
  FROM savings_savingsaccount s
  GROUP BY
    s.owner_id,
    txn_month
),

-- Step 2: Calculate average monthly transactions per customer
-- This gives each user’s average number of transactions per month
AvgTxnPerCustomer AS (
  SELECT
    owner_id,
    ROUND(AVG(monthly_txn_count), 2) AS avg_txn_per_month     -- Average monthly transaction count per user
  FROM MonthlyTransactions
  GROUP BY owner_id
),

-- Step 3: Merge user table with transaction data and assign frequency categories
-- This assigns each user to a frequency category based on their avg monthly transactions
UserFrequencyCategory AS (
  SELECT
    u.id AS customer_id,
    COALESCE(a.avg_txn_per_month, 0) AS avg_txn_per_month,    -- Default to 0 if no transaction record exists
    CASE
      WHEN COALESCE(a.avg_txn_per_month, 0) >= 10 THEN 'High Frequency'
      WHEN COALESCE(a.avg_txn_per_month, 0) BETWEEN 3 AND 9.99 THEN 'Medium Frequency'
      WHEN COALESCE(a.avg_txn_per_month, 0) BETWEEN 0.01 AND 2.99 THEN 'Low Frequency'
      ELSE 'No Transaction'                    -- For truly zero or NULL values
    END AS frequency_category
  FROM users_customuser u
  LEFT JOIN AvgTxnPerCustomer a ON u.id = a.owner_id
)

-- Step 4: Final output
-- This part groups users by frequency category and calculates summary stats
SELECT
  frequency_category AS `Frequency Category`,       -- Label of frequency group
  COUNT(*) AS `Customer Count`,                  -- Number of users in this group
  ROUND(AVG(avg_txn_per_month), 2) AS `Avg. Transactions/Month` -- Average monthly txn per category
FROM UserFrequencyCategory
GROUP BY frequency_category
ORDER BY FIELD(frequency_category,
  'High Frequency',
  'Medium Frequency',
  'Low Frequency',
  'No Transaction'         -- sort frequency category for readability
);
