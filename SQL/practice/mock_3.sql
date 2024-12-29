-- the highest number of kills in 3 consecutive days
-- also with the time window and the highest # of kills for those 3 days

-- row_number    player_id          time_date          num_kill        time_date_2
--     1           ginger      2022-06-03 00:00:00        3        2022-06-05 00:00:00 
--     2           ginger      2022-06-04 00:00:00        4        2022-06-06 00:00:00
--     3           ginger      2022-06-04 00:00:00        11       2022-06-06 00:00:00
--     4           ginger      2022-06-05 00:00:00        20       2022-06-07 00:00:00

-- Lag cannot build the consecutive range if the time_Date is not consecutive

WITH TWO_TIME AS (
    SELECT 
        *,
        DATEADD(DD, 2, time_date) AS time_date_2
    FROM 
        TABLE
),

TIME_STRUCTURE AS (
    SELECT 
        a.player_id,
        a.time_date,
        a.time_date_2,
        b.time_date AS b_time_date,
        b.num_kill
    FROM 
        TWO_TIME a 
    LEFT JOIN 
        TABLE b 
    ON 
        a.player_id = b.player_id 
    AND 
        a.time_date <= b.time_date
    AND 
        a.time_date_2 >= b.time_date
),

MAX_TABLE AS (
    SELECT 
        player_id,
        time_date,
        time_date_2,
        SUM(num_kill) AS kill_in_3_consecutive_days
    FROM 
        TIME_STRUCTURE 
    GROUP BY 
        player_id,
        time_date,
        time_date_2
    ORDER BY 
        SUM(num_kill) DESC
    LIMIT 
        1
)

SELECT 
    player_id,
    time_date,
    time_date_2,
    SUM(num_kill) AS kill_in_3_consecutive_days
FROM 
    TIME_STRUCTURE 
GROUP BY 
    player_id,
    time_date,
    time_date_2
HAVING SUM(num_kill)  =  (SELECT kill_in_3_consecutive_days FROM MAX_TABLE)

