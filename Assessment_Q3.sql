-- Step 1: Get the most recent transaction date from the savings_savingsaccount table
WITH max_transaction_date AS (
  SELECT 
    MAX(transaction_date) AS latest_date 
  FROM 
    savings_savingsaccount
)

-- Step 2: Identify plans (savings or investments) that have been inactive for over a year
SELECT 
  p.id AS plan_id,                 -- Unique ID of the plan
  p.owner_id,                  -- Owner of the plan

  -- Determine plan type (Savings or Investment)
  CASE 
    WHEN p.is_regular_savings = 1 THEN 'Savings'
    WHEN p.is_a_fund = 1 THEN 'Investment'
    ELSE 'Unknown'
  END AS type,

  -- Fetch the most recent transaction associated with the plan
  MAX(s.transaction_date) AS last_transaction_date,

  -- Calculate days since last transaction using the global latest transaction date
  DATEDIFF(
    (SELECT latest_date FROM max_transaction_date), 
    MAX(s.transaction_date)
  ) AS inactivity_days

FROM 
  plans_plan p

  -- Join with transactions to link plans with their activity
  LEFT JOIN savings_savingsaccount s 
    ON p.id = s.plan_id

WHERE 
  -- Consider only active savings or investment plans
  (p.is_regular_savings = 1 OR p.is_a_fund = 1)
  AND p.is_deleted = 0

GROUP BY 
  p.id, 
  p.owner_id, 
  p.is_regular_savings, 
  p.is_a_fund

HAVING 
  -- Only include plans that have at least one transaction in the past
  last_transaction_date IS NOT NULL

  -- And have been inactive for more than 365 days (1 year)
  AND DATEDIFF(
    (SELECT latest_date FROM max_transaction_date), 
    last_transaction_date
  ) > 365;
