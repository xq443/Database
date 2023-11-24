-- month-over-month percentage chaneg in revenue
-- Return the year-month date(YYYY-MM) and percentage change, rounded to 2 decima;
-- and sorted from the beginning of the year to the end of the year
id      created_at        value         purchase_id
1       2019-01-01        178374        43
2       2019-01-05         49898        36

SELECT  ym,
        CASE  
            WHEN lag_value = 0 THEN null
            ELSE ROUND((sum_value - lag_value / lag_value) * 100, 2)
        END AS percentage
FROM(
    SELECT 
        DATE_FORMAT(created_at, '%Y - %m') as ym,
        LAG(SUM(value), 1) OVER(ORDER BY DATE_FORMAT(created_at, '%Y - %m')) AS lag_value,
        SUM(value) AS sum_value
    FROM 
        sf_transactions
    GROUP BY 
        DATE_FORMAT(created_at, '%Y - %m')
    ) AS CTE
ORDER BY ym;
