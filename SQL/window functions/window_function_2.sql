-- name        month       amt
-- cathy        01         100
-- sandy        02         120
-- maria        03         120
-- novak        04         150
-- novak        05         160
-- maria        06         120
-- sandy        07         220

-- name     total_amt      rank     proportion
WITH TOTAL AS (
    SELECT 
        name,
        SUM (amt) AS total 
    FROM
        TABLE
    GROUP BY 
        name
),
RANKING AS (
    SELECT  
        *,
        ROW_NUMBER() OVER(PARTITION BY NULL ORDER BY total DESC) AS rnk,
        SUM(total) OVER(PARTITION BY NULL) AS sum_all 
    FROM 
        TOTAL 
)

SELECT 
    name,
    total AS total_amt
    rnk,

    -- || : CONCAT
    -- ROUND(total * 100 / sum_all, 2)  || % AS rate
    CONCAT(ROUND(total * 100 / sum_all, 2), '%') AS proportion
FROM 
    RANKING
ORDER BY 
    total DESC;