-- SELECT
--     *
-- FROM
--         (
--             SELECT
--                 zzz,
--                 ROW_NUMBER() OVER(PARTITION BY XXX ORDER BY YYY) AS rnk
--             FROM 
--                 TABLE
--         ) AS T 
-- WHERE rnk <= N

-- empno        ename       hiredate          sal       deptno
-- 7492         cathy       22/2/1981        3821       30
-- 4982         cindy       2/2/1994         3821       20
-- 2351         wang        4/2/1999         3821       20
-- 5983         qunen       12/2/2011        3821       10
-- 1328         sakar       20/2/2024        3821       30

-- the highest salary ename for each deptno
-- the proportion of these ename's salary in their deptno
-- empno       sal      deptno      rank    dept_total  proportion

SELECT
    *,
    CONCAT(ROUND(sal * 100.0 / sum_all, 2), '%') AS proportion
FROM (

    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY sal DESC) AS rnk,
        SUM (sal) OVER(PARTITION BY deptno) AS dept_total
    FROM 
        TABLE
    ) AS T
WHERE rnk <= 3;
