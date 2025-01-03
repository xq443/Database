-- rec_no      ci_no       cust_type       cre_dt           cus_sts
-- 123          1111       08              2024-09-01          Y
-- 234          2222       02              2024-08-01          Y
-- 345          3333       02              2024-09-08          Y



-- ci_no       ac_no       bal
-- 2222        123598      1000.28
-- 2222        123599      886
-- 3333        129837      5000

-- # of ci with open account in Sept and bal > 0

WITH FILTER1 AS (
    SELECT 
        DISTINCT ci_no
    FROM 
        table1 
    WHERE 
        MONTH(cre_dt) = 9
    AND 
        cus_sts = 'Y'
), 
FILTER2 AS (
    SELECT 
        DISTINCT ci_no,
        SUM(bal) AS sum_bal
    FROM 
        table2
    GROUP BY 
        ci_no
    HAVING  
        SUM(bal) != 0
)


SELECT 
    COUNT(ci_no) AS 'num_of_ci'
FROM
    FILTER1 a
JOIN 
    FILTER2 b
ON 
    a.ci_no = b.ci_no

