-- ROW TO COLUMN
-- qq_id       game
-- 10000        a
-- 10000        b
-- 10000        c
-- 20000        c
-- 20000        d

-- qq_id       game
-- 10000        a_b_c
-- 20000        c_d

SELECT
    qq_id,
    CONCAT_WS('_', collect_list(game)) AS arr
FROM
    TABLE 
GROUP BY 
    qq_id


-- COLUMN TO ROW(VIEW + EXPLODE)
-- SELECT
--     qq_id,
--     game2
-- FROM 
--     TABLE LATERAL VIEW EXPLODE(SPLIT(game, '_')) v1 AS game2;
