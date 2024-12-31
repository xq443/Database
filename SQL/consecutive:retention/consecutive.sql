-- dt           name     ||    rn     indicator    cnt
--2022-08-01    cathy    ||     1    2022-07-31     
--2022-08-02    cathy    ||     2    2022-07-31
--2022-08-03    cathy    ||     3    2022-07-31     3
--2022-08-03    qin      ||     1    2022-08-02
--2022-08-05    qin      ||     2    2022-08-03



WITH DEDUPLICATED AS (
    SELECT DISTINCT
        dt,
        name
    FROM 
        TABLE
),
TEMP AS (
    SELECT 
        dt,
        name,
        ROW_NUMBER() OVER (PARTITION BY name ORDER BY dt) AS rn,
        dt - ROW_NUMBER() OVER(PARTITION BY name ORDER BY dt) AS indicator
        -- DATE_SUB(dt, INTERVAL ROW_NUMBER() OVER (PARTITION BY name ORDER BY dt) DAY) AS indicator
    FROM 
        DEDUPLICATED
)

SELECT 
    DISTINCT name
FROM (
    SELECT
        name,
        indicator,
        COUNT(*) AS cnt
    FROM 
        TEMP
    GROUP BY 
        name, indicator
) sub
WHERE 
    cnt >= 3;



-- WTIH DEDUPLICATED AS (
--     SELECT 
--         DISTINCT dt, name 
--     FROM 
--         TABLE 
-- ),

-- TEMP AS (
--     SELECT 
--         *,
--         DATE_ADD(dt, 2) AS date2, -- adding 2 units (likely days) 
--         LEAD(dt, 2) OVER(PARTITION BY name ORDER BY dt) AS date3 -- fetch the dt value two rows ahead 
--     FROM 
--         DEDUPLICATED
-- )

-- SELECT
--     DISTINCT name
-- FROM    
--     TEMP 
-- WHERE 
--     date2 = date3;