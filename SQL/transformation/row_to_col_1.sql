-- year        month       amount
-- 1991        1            1.1
-- 1991        2            1.3
-- 1992        1            1.4
-- 1992        2            1.3

-- year        m1       m2
-- 1991        1.1      1.3      
-- 1992        1.4      1.3


-- CASE WHEN month = 1 THEN amount ELSE 0
-- END
-- 2 BRANCH
SELECT 
    year,
    SUM(IF(month = 1, amount, 0)) AS m1,
    SUM(IF(month = 2, amount, 0)) AS m2,
    SUM(IF(month = 3, amount, 0)) AS m3,
    SUM(IF(month = 4, amount, 0)) AS m4,
FROM 
    TABLE 
GROUP BY 
    year;


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
SELECT
    qq_id,
    game2
FROM 
    TABLE LATERAL VIEW EXPLODE(SPLIT(game, '_')) v1 AS game2;



