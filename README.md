  
# My Approach for Assessment_Q1


For this task, I started by analyzing the structure of the database, focusing specifically on three key tables:
•	users_customuser (to retrieve user details),
•	plans_plan (to identify whether a plan is a fund or savings),
•	savings_savingsaccount (to access the actual transaction data).
The goal was to group users based on their involvement in savings and investment plans. I created a Common Table Expression (CTE) to combine relevant data from these tables, associating each transaction with the user and the nature of the plan.
From there, I computed:
•	The number of distinct savings plans with deposits per user.
•	The number of distinct investment plans with deposits.
•	The total deposits made by each user.
I then filtered the results to only include users who had both at least one savings plan and at least one investment plan with actual contributions. The final output was sorted by the total deposit amount to highlight top contributors.
Summary of What the Code Does:
•	Collects all user-related savings and investment plan data via joins.
•	Aggregates counts of savings and investment plans with positive contributions.
•	Filters users who have at least one savings plan and at least one investment plan with deposits.
•	Returns total deposited amounts, sorted from highest to lowest

________________________________________
Challenges
1. Handling Missing or Zero-Value Deposits
Initially, I noticed that some users were being counted even when the amount field was zero or missing. This was giving inaccurate counts for savings or investment participation.
Solution: I used conditional logic to count only plans where amount > 0.
2. Avoiding Double Counting
Since some users had multiple transactions on the same plan, there was a risk of inflating counts.
Solution: I used COUNT(DISTINCT plan_id) instead of just COUNT(*) to ensure only unique plans were counted.
3. Ensuring Readability
The original query started getting complex, especially with multiple conditional counts and joins.
Solution: I broke the query into manageable parts using a CTE and added inline comments to keep it understandable.
________________________________________
 Final Thoughts
This exercise reinforced the importance of clear joins, data filtering, and proper aggregation in SQL—especially when working with user behavior data. I'm happy with the outcome, and the query now gives an accurate and insightful view into users' savings and investment activity.





# My Approach for Assessment_Q2


This task is a Customer Transaction Frequency Classification
This query was designed to categorize customers into different transaction frequency groups based on how often they make savings account transactions each month. The goal was to generate meaningful insights into customer activity and behavior.
Here's a breakdown of how the problem was approached:
1.	Monthly Transaction Count
First, I calculated the number of transactions each user made per month using DATE_FORMAT to group by year and month. This helped establish a time-based pattern for each user.
2.	Average Monthly Transactions
Using the results from the first step, I calculated the average number of transactions per user across all active months. This gave a per-customer monthly activity metric.
3.	User Classification
I then joined this average with the complete list of users. For those with no transactions at all, I made sure they were included via a LEFT JOIN and used COALESCE to handle NULL values. Each user was then categorized into one of the following:
o	High Frequency: 10 or more transactions/month
o	Medium Frequency: 3–9.99 transactions/month
o	Low Frequency: 0.01–2.99 transactions/month
o	No Transaction: 0 or no activity
4.	Summary Statistics
Finally, the data was grouped by frequency category to count how many users fall into each group and calculate the average transactions per category.
________________________________________
 Challenges & How They Were Resolved
1. Handling Users with No Transactions
At first, users without any transactions were being left out entirely from the final result. I fixed this by ensuring a LEFT JOIN was used between the user table and the average transaction subquery. This way, even users with zero activity were included in the classification.
2. Misleading Average Values for 'No Transaction' Users
During testing, I noticed that some users categorized as having "No Transactions" were showing an average transaction count (like 2.99). This was caused by not properly handling NULL values. To fix this, I used COALESCE to explicitly treat missing values as 0, ensuring they are categorized correctly.
3. Readability and Maintainability
As the query grew longer, it became harder to understand. So, I broke it into multiple Common Table Expressions (CTEs), each handling a specific piece of logic. This made the code modular, easier to read, and easier to debug.
________________________________________
Result
The final query now successfully classifies each customer, provides accurate group-level stats, and ensures no users are excluded even those with no transactions. It’s ready to plug into reports or dashboards for business insights.





# My Approach for Assessment_Q3


The task was to identify investment or savings plans that have been inactive for more than one year. To do this:
1.	Step 1: I used a Common Table Expression (CTE) to fetch the most recent transaction date from the entire dataset (savings_savingsaccount). This gives us a reference point for "today" in our analysis.
2.	Step 2: I queried all plans (plans_plan) that are either regular savings or investment plans and are not marked as deleted.
3.	Step 3: I joined the plans with the transaction data to find each plan's latest transaction date using MAX(transaction_date).
4.	Step 4: I calculated the number of days since the last transaction by subtracting each plan’s latest transaction date from the overall latest transaction date (from the CTE).
5.	Step 5: Finally, I filtered the results to include only plans where the inactivity period is greater than 365 days (i.e., over a year).
This approach ensured accuracy in detecting dormant or idle plans.
________________________________________
 Challenges & How I Solved Them
•	Challenge 1: Handling edge cases with NULL transactions
Some plans had no transaction history at all, which made MAX(transaction_date) return NULL. To avoid misclassification, I made sure to filter them out using HAVING last_transaction_date IS NOT NULL.
•	Challenge 2: Comparing dates dynamically
Instead of hardcoding a cutoff date, I dynamically pulled the latest transaction date using a CTE. This made the query more robust and future-proof.
•	Challenge 3: Keeping plan types readable
Plans could be either savings or investments based on flags. I used a CASE statement to make this clearer in the final output by translating binary values into meaningful labels ("Savings", "Investment").









# My Approach for Assessment_Q4


Profit Calculation:
•	First, I created a CTE (customer_transaction_profits) that combines successful savings and successful withdrawal transactions.
•	For each, I computed the profit as amount * 0.001, since profit per transaction is 0.1% of the value.
Customer-Level Aggregation:
•	I aggregated total transactions and total profit per customer.
•	Then joined this with the user table to get each customer's full name and signup date.
CLV Computation:
•	I calculated the account tenure in months using TIMESTAMPDIFF.
•	Then applied the CLV formula and converted the result from kobo to naira by dividing by 100.
Handling Edge Cases:
•	Used COALESCE to safely handle users with no transactions.
•	Guarded against division-by-zero errors using a CASE statement to skip invalid records.
•	________________________________________
Challenges Faced
1. Mixing Savings and Withdrawals Cleanly
Merging two different transaction sources (savings and withdrawals) in a way that maintains profit logic and schema consistency was a bit tricky. I handled this by unifying the structure using UNION ALL and clearly labelling the profit calculation.
2. Kobo to Naira Conversion
Since all monetary values were stored in kobo, it was easy to forget the conversion to naira. I made sure to apply the / 100 operation at the right step and rounded the final CLV to two decimal places.
3. Zero Tenure or Transaction Cases
It was important to avoid dividing by zero for customers who had just signed up or had no transactions. I used CASE WHEN logic to set the CLV to 0 in these scenarios, which also keeps the result clean and safe.

 Result
•	The final SQL output provides each customer’s:
•	Full name
•	Account tenure (in months)
•	Total number of transactions
•	Estimated CLV (in naira), sorted from highest to lowest
•	This makes it easy to identify high-value customers and understand customer engagement over time.

This approach ensured robust handling of data completeness, accuracy in financial calculations, and flexibility for future expansion.




