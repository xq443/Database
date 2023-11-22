-- Input: 
-- Transactions table:
-- +----------------+-------------+------------------+--------+
-- | transaction_id | customer_id | transaction_date | amount |
-- +----------------+-------------+------------------+--------+
-- | 1              | 101         | 2023-05-01       | 100    |
-- | 2              | 101         | 2023-05-02       | 150    |
-- | 3              | 101         | 2023-05-03       | 200    |
-- | 4              | 102         | 2023-05-01       | 50     |
-- | 5              | 102         | 2023-05-03       | 100    |
-- | 6              | 102         | 2023-05-04       | 200    |
-- | 7              | 105         | 2023-05-01       | 100    |
-- | 8              | 105         | 2023-05-02       | 150    |
-- | 9              | 105         | 2023-05-03       | 200    |
-- | 10             | 105         | 2023-05-04       | 300    |
-- | 11             | 105         | 2023-05-12       | 250    |
-- | 12             | 105         | 2023-05-13       | 260    |
-- | 13             | 105         | 2023-05-14       | 270    |
-- +----------------+-------------+------------------+--------+
-- Output: 
-- +-------------+-------------------+-----------------+
-- | customer_id | consecutive_start | consecutive_end | 
-- +-------------+-------------------+-----------------+
-- | 101         |  2023-05-01       | 2023-05-03      | 
-- | 105         |  2023-05-01       | 2023-05-04      |
-- | 105         |  2023-05-12       | 2023-05-14      | 
+-------------+-------------------+-----------------+
-- Write an SQL query to find the customers who have made consecutive transactions with increasing amount for at least three consecutive days. 
-- Include the customer_id, start date of the consecutive transactions period and the end date of the consecutive transactions period.
-- There can be multiple consecutive transactions by a customer.
-- Return the result table ordered by customer_id in ascending order.
WITH D1 AS(
    SELECT T1.customer_id, T1.transaction_date
    FROM Transactions T1, Transactions T2
    WHERE T2.amount > T1.amount
    AND DATEDIFF(T2.transaction_date, T1.transaction_date) = 1
    AND T1.customer_id = T2.customer_id
),

-- # +-------------+------------------+----+
-- # | customer_id | transaction_date | rn |
-- # +-------------+------------------+----+
-- # | 101	      | 2023-05-01       |  1 |
-- # | 101	      |	2023-05-02       |	2 |
-- # | 102	      |	2023-05-03       |	1 |
-- # | 105	      |	2023-05-01       |	1 |
-- # | 105	      |	2023-05-02       |	2 |
-- # | 105	      |	2023-05-03       |	3 |
-- # | 105	      |	2023-05-12       |	4 |
-- # | 105	      |	2023-05-13       |	5 |
-- # +-------------+------------------+----+

D2 AS(
    SELECT customer_id, transaction_date,
        row_number()over(partition by customer_id order by transaction_date) as rnk
    from D1
),

D3 AS(
    SELECT customer_id, transaction_date,
    DATE_SUB(transaction_date, INTERVAL rnk DAY) as date_group
    FROM D2
),
D4 AS(
    SELECT customer_id, transaction_date,
    count(date_group) as cnt,
    min(transaction_date) as consecutive_start
    from D3
    GROUP BY customer_id, date_group
)

SELECT customer_id,consecutive_start,
        DATE_ADD(consecutive_start, INTERVAL cnt DAY) as consecutive_end
FROM D4
WHERE cnt >= 2
order by customer_id

