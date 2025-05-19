-- Step 1: Calculate total number of transactions and total profit (in kobo) per customer
WITH customer_transaction_profits AS (
    SELECT
        owner_id,
        COUNT(id) AS total_transactions,
        SUM(transaction_profit) AS total_profit
    FROM (
        -- Sub-query 1: Calculate profit from savings transactions (0.1% of confirmed amount)
        SELECT
            owner_id,
            id,
            confirmed_amount * 0.001 AS transaction_profit
        FROM
            savings_savingsaccount
        WHERE
            transaction_status = 'successful' 
            AND confirmed_amount > 0

        UNION ALL

        -- Sub-query 2: Calculate profit from withdrawals (0.1% of amount withdrawn)
        SELECT
            owner_id,
            id,
            amount_withdrawn * 0.001 AS transaction_profit
        FROM
            withdrawals_withdrawal
        WHERE
            transaction_status_id IN (3, 4)  -- Replace with actual successful withdrawal status IDs
            AND amount_withdrawn > 0

    ) AS transactions_with_profit
    GROUP BY
        owner_id
),

-- Step 2: Join the transaction profit data with user data
customer_data AS (
    SELECT
        u.id AS customer_id,
        u.first_name,
        u.last_name,
        u.date_joined,

        -- Use COALESCE to default to 0 if the customer has no transactions
        COALESCE(ctp.total_transactions, 0) AS total_transactions,
        COALESCE(ctp.total_profit, 0) AS total_profit_kobo
    FROM
        users_customuser u
    LEFT JOIN
        customer_transaction_profits ctp 
        ON u.id = ctp.owner_id
)

-- Step 3: Final result set calculating CLV and formatting output
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,

    -- Calculate account tenure in months from signup date to fixed reference date
    TIMESTAMPDIFF(MONTH, date_joined, '2025-05-19') AS account_tenure_months,
    total_transactions,

    -- Calculate CLV using formula:
    -- CLV = (total_transactions / tenure_months) * 12 * average_profit_per_transaction
    -- Then convert from kobo to naira by dividing by 100
    ROUND(
        CASE
            WHEN TIMESTAMPDIFF(MONTH, date_joined, '2025-05-19') > 0 
                 AND total_transactions > 0
            THEN (
                (total_transactions / TIMESTAMPDIFF(MONTH, date_joined, '2025-05-19')) * 12 *
                (total_profit_kobo / total_transactions)
            ) / 100  -- Convert kobo to naira
            ELSE 0
        END,
        2  -- Round to 2 decimal places
    ) AS estimated_clv_naira

FROM
    customer_data

-- Sort by highest CLV
ORDER BY
    estimated_clv_naira DESC;
