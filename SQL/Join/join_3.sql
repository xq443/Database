-- type1 table
-- time        server_id       role_id         cost        item_id     amount      p_date
-- 1234456     120             10098           2           4              4        2021-01-01
-- 1234456     120             10098           4           4              4        2021-01-01
-- 1234456     123             10098           3           3              3        2021-01-02
-- 1234456     123             10098           2           3              5        2021-01-02


-- type2 table
-- time        server_id       role_id         cost        item_id     amount      p_date
-- 1234456     123             10098           2           4              4        2021-01-01
-- 1234456     123             10098           4           4              4        2021-01-01
-- 1234456     120             10098           3           3              3        2021-01-01
-- 1234456     120             10098           2           3              5        2021-01-01
-- 1234456     123             10098           12          4              4        2021-01-02
-- 1234456     123             10098           4           4              4        2021-01-02

-- Result: 2021-01-01 - 2021-01-07 cost(type1 / type2) by each day
-- p_date          server_id       role_id     rate

-- 1. aggregate in each table (bc duplicated records)
-- 2. full outer join
-- 3. coalesce

WITH Type1Aggregated AS (
    SELECT 
        p_date,
        server_id,
        role_id,
        SUM(cost) AS sum_cost
    FROM
        type1
    WHERE 
        p_date BETWEEN '2021-01-01' AND '2021-01-07'
    GROUP BY 
        p_date,
        server_id,
        role_id
),
Type2Aggregated AS (
    SELECT 
        p_date,
        server_id,
        role_id,
        SUM(cost) AS sum_cost
    FROM
        type2
    WHERE 
        p_date BETWEEN '2021-01-01' AND '2021-01-07'
    GROUP BY 
        p_date,
        server_id,
        role_id
)
SELECT 
    COALESCE(a.p_date, b.p_date) AS p_date, 
    COALESCE(a.server_id, b.server_id) AS server_id,
    COALESCE(a.role_id, b.role_id) AS role_id,
    COALESCE(a.sum_cost, 0) AS a_cost,
    COALESCE(b.sum_cost, 0) AS b_cost,
    CASE 
        WHEN COALESCE(b.sum_cost, 0) = 0 THEN 0 
        ELSE COALESCE(a.sum_cost, 0) / COALESCE(b.sum_cost, 0) 
    END AS rate
FROM 
    Type1Aggregated a
FULL OUTER JOIN
    Type2Aggregated b 
ON 
    a.p_date = b.p_date 
    AND a.server_id = b.server_id 
    AND a.role_id = b.role_id;


-- SELECT 
--     COALESCE(a.p_date, b.p_date) AS p_date,
--     COALESCE(a.server_id, b.server_id) AS server_id,
--     COALESCE(a.role_id, b.role_id) AS role_id,
--     COALESCE(a.sum_cost, 0) AS a_cost,
--     COALESCE(b.sum_cost, 0) AS b_cost,
--     CASE 
--         WHEN COALESCE(b.sum_cost, 0) = 0 THEN 0 
--         ELSE COALESCE(a.sum_cost, 0) / COALESCE(b.sum_cost, 0) 
--     END AS rate
-- FROM 
--     (
--         SELECT 
--             p_date,
--             server_id,
--             role_id,
--             SUM(cost) AS sum_cost
--         FROM
--             type1
--         WHERE 
--             p_date BETWEEN '2021-01-01' AND '2021-01-07'
--         GROUP BY 
--             p_date,
--             server_id,
--             role_id
--     ) AS a

-- FULL OUTER JOIN

--     (
--         SELECT 
--             p_date,
--             server_id,
--             role_id,
--             SUM(cost) AS sum_cost
--         FROM
--             type2
--         WHERE 
--             p_date BETWEEN '2021-01-01' AND '2021-01-07'
--         GROUP BY 
--             p_date,
--             server_id,
--             role_id
--     ) AS b 
-- ON a.p_date = b.p_date AND a.server_id = b.server_id AND a.role_id = b.role_id;
