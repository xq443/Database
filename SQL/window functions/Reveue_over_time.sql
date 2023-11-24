user_id  created_at     purchase_amt
10       2020-01-01     3742
11       2020-01-04     1290
12       2020-01-07     4249


WITH CTE AS (
    SELECT 
        DATE_FORMAT(created_at, '%Y - %m') AS date, 
        SUM(purchase_amt) AS purchase_amt 
    FROM 
        amazon_purchases
    WHERE 
        purchase_amt > 0
    GROUP BY 
        DATE_FORMAT(created_at, '%Y - %m')
)
SELECT 
    date,
    AVG(purchase_amt) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_Average
FROM 
    CTE;
