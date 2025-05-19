-- Step 1: Create a Common Table Expression (CTE) to gather relevant plan data for each user
WITH ALL_USER_PLAN AS (
    SELECT
        u.id AS owner_id,         -- Unique ID of the user
        u.first_name,             -- First name of the user
        u.last_name,             -- Last name of the user
        p.id AS plan_id,             -- Unique ID of the plan
        p.is_a_fund,                -- Flag indicating if the plan is an investment fund
        p.is_regular_savings,       -- Flag indicating if the plan is a regular savings plan
        s.amount                     -- Amount saved or invested under the plan
    FROM savings_savingsaccount s
    LEFT JOIN plans_plan p 
        ON s.plan_id = p.id           -- Join savings with plan details
    LEFT JOIN users_customuser u 
        ON p.owner_id = u.id         -- Join plans with the user who owns the plan
)

-- Step 2: Use the CTE to compute required metrics per user
SELECT
    owner_id,                                               -- User ID
    CONCAT(first_name, ' ', last_name) AS Name,          -- Full name of the user
    COUNT(DISTINCT CASE 
        WHEN is_regular_savings = 1 AND amount > 0 THEN plan_id 
    END) AS Savings_Count,            -- Count of distinct active savings plans

    COUNT(DISTINCT CASE 
        WHEN is_a_fund = 1 AND amount > 0 THEN plan_id 
    END) AS Investment_Count,       -- Count of distinct active investment plans

    SUM(amount) AS Total_Deposits        -- Total amount deposited by the user
FROM ALL_USER_PLAN
GROUP BY 
    owner_id, 
    first_name, 
    last_name

-- Step 3: Filter only users who have both savings and investment plans with positive amounts
HAVING 
    COUNT(DISTINCT CASE 
        WHEN is_regular_savings = 1 AND amount > 0 THEN plan_id 
    END) >= 1

    AND 

    COUNT(DISTINCT CASE 
        WHEN is_a_fund = 1 AND amount > 0 THEN plan_id 
    END) >= 1

-- Step 4: Sort the result by total amount deposited in descending order
ORDER BY 
    Total_Deposits DESC;
