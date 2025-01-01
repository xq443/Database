-- empno        ename       hiredate          sal       deptno
-- 7492         cathy       22/2/1981        3821       30
-- 4982         cindy       2/2/1994         3821       20
-- 2351         wang        4/2/1999         3821       20
-- 5983         qunen       12/2/2011        3821       10
-- 1328         sakar       20/2/2024        3821       30

-- employemnt amount by wach year
-- accumulated employment amount by this year

WITH EMPLOYMENT AS(
    SELECT  
        *,
        YEAR(hiredate) AS year1,
        COUNT(empno) AS cnt
    FROM 
        TABLE 
    GROUP BY 
        YEAR(hiredate)
)

SELECT  
    year1,
    cnt,
    SUM(cnt) OVER(ORDER BY year1) AS accumulated
FROM
    EMPLOYMENT


