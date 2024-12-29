-- Mock question 1
-- if repair_status= 'repair', the date is repair start date
-- if repair_status= 'online', it means back to normal
-- calculate # repair days for each server

-- server_id   date    repair_status
-- 1          2019-08-09   repair
-- 1          2019-08-10   online 
-- 2          2019-08-10   repair

WITH TEMP1 AS (
    SELECT
        server_id AS id,
        date AS online_date,
        ROW_NUMBER() OVER(PARTITION BY server_id ORDER BY date) AS rnk
    FROM 
        table 
    WHERE 
        repair_status = 'online'
),

TEMP2 AS (
     SELECT
        server_id AS id,
        date,
        ROW_NUMBER() OVER(PARTITION BY server_id ORDER BY date) AS rnk
    FROM 
        table 
    WHERE 
        repair_status = 'repair'
)

SELECT  
    TEMP2.id,
    SUM(DATEDIFF(
        DAY,
        TEMP2.repair_date,
        -- COALESCE(TEMP1.online_date, CURRENT_DATE)
        IFNULL(TEMP1.online_date, GETDATE()) 
    )) AS total_repair_days
FROM 
    TEMP1 
RIGHT JOIN -- all records from TEMP2 (repair start dates) are included in
    TEMP2 
ON 
    TEMP1.id = TEMP2.id 
AND 
    TEMP1.rnk = TEMP2.rnk
GROUP BY 
    TEMP2.id;
