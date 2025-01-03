-- student
-- sid     sname       sgender         class_id
-- 1       cathy       female          1
-- 2       wang        female          1
-- 3       dkj         male            2

-- course
-- cid     canme       teacher_id
-- 1       math        1
-- 2       econ        1
-- 3       physics     2

-- score
-- sid     student_id   course_id       number
-- 1        1           1               58
-- 4        1           2               50
-- 2        1           2               68
-- 3        2           2               89


-- SUBQUERY
-- student_id      math_score      econ_score
-- 1                   58              0
-- 1                   0               50
-- 1                   0               68
-- 2                   89              0

-- SUMMARY
-- student_id      math_score      econ_score
-- 1                58              68
-- 2                89              0

-- 2. all sid and sname with physics score higher than math

WITH SUBQUERY AS(
    SELECT 
        student_id,
        SUM(CASE WHEN course_id = 1 THEN number ELSE 0 END) AS 'math_score',
        SUM(CASE WHEN course_id = 2 THEN number ELSE 0 END) AS 'econ_score'
    FROM 
        score 
    GROUP BY 
        student_id
),

SUMMARY AS (
    SELECT 
        student_id,
        MAX(math_score) AS 'agg_math_score',
        MAX(econ_score) AS 'agg_econ_score'
    FROM 
        SUBQUERY
    GROUP BY 
        student_id
    WHERE 
        MAX(math_score) > MAX(econ_score)
) 

-- WTIH AGGREGATED AS (
--     SELECT 
--             student_id,
--             MAX(SUM(CASE WHEN course_id = 1 THEN number ELSE 0 END)) AS 'agg_math_score',
--             MAX(SUM(CASE WHEN course_id = 2 THEN number ELSE 0 END)) AS 'agg_econ_score'
--     FROM 
--         score
--     GROUP BY 
--         student_id
--     WHERE 
--         agg_math_score > agg_econ_score
-- )


SELECT 
    s.*
FROM 
    SUMMARY a 
JOIN 
    student s 
ON 
    a.student_id = s.sid;
