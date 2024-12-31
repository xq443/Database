-- cuid        os          soft_version        event_day       visit_time      duration        ext
-- 1         android           1               2020-04-01       1234567         100            【】
-- 1         android           1               2020-04-02       1234567         100            【】
-- 1         android           1               2020-04-08       1234567         100            【】
-- 2         android           1               2020-04-01       1234567         100            【】
-- 3         android           1               2020-04-02       1234567         100            【】


-- 20200401 second day, 7-day rention rate
-- 0401 uv, 0401 in 0402 uv, 0401 in 0408 uv(unique view)

-- cuid            0401        0402(second_day)    0408(7-day)
-- 1               1               1                   1
-- 2               1               0                   0

-- 0401uv        0402(second_day uv)    0408(7-dayuv)
-- 2                        1                  1

WITH TEMP AS (
    SELECT      
        cuid,
        COUNT(CASE WHEN event_day = '2020-04-01' THEN 1 ELSE null END) AS cnt_4_1,
        COUNT(CASE WHEN event_day = '2020-04-02' THEN 1 ELSE null END) AS cnt_4_2,
        COUNT(CASE WHEN event_day = '2020-04-08' THEN 1 ELSE null END) AS cnt_4_8
    FROM 
        TABLE
    WHERE 
        event_day IN ('2020-04-01', '2020-04-02', '2020-04-08')
    GROUP BY 
        cuid
    HAVING 
        COUNT(CASE WHEN event_day = '2020-04-01' THEN 1 ELSE NULL END) > 0;
)，
UV AS(
SELECT 
    '2020-04-01 RETENTION' AS type,
    COUNT(cuid) AS uv_4_1,
    COUNT(CASE WHEN cnt_4_2 > 0 THEN 1 ELSE NULL END) AS uv_4_2,
    COUNT(CASE WHEN cnt_4_8 > 0 THEN 1 ELSE NULL END) AS uv_4_8

FROM
    TEMP
)

SELECT 
    uv_4_2 * 1.0 / uv_4_1 AS two_day_rate,
    uv_4_8 * 1.0 / uv_4_1 AS seven_day_rate
FROM
    UV;



-- another way with slower effiency 

-- SELECT
--     COUNT(a.cuid) AS uv_4_1,
--     COUNT(b.cuid) AS uv_4_2,
--     COUNT(c.cuid) AS uv_4_8,
--     COUNT(b.cuid) * 1.0 / COUNT(a.cuid) AS rate_4_2,
--     COUNT(c.cuid) * 1.0 / COUNT(a.cuid) AS rate_4_8
-- FROM 
--     (SELECT DISTINCT cuid FROM TABLE WHERE event_day = '2020-04-01') a
-- LEFT JOIN 
--     (SELECT DISTINCT cuid FROM TABLE WHERE event_day = '2020-04-02') b 
--     ON a.cuid = b.cuid
-- LEFT JOIN 
--     (SELECT DISTINCT cuid FROM TABLE WHERE event_day = '2020-04-08') c 
--     ON a.cuid = c.cuid;
