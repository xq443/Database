-- LEFT SEMI JOIN: left only included
-- LEFT ANTI JOIN: right only included in left

-- FULL (OUTER) JOIN
-- deposit
-- user_id     amount  
-- 1           2900
-- 2           2400
-- 3           2500

-- debt
-- user_id      amount
-- 3            4000
-- 4            2000
-- 5            1000

-- FULL OUTER JOIN RESULT:
-- user_id     amount       user_id     amount      ||  user_id_new
-- 1           2900           NULL       NULL               1
-- 2           2400           NULL       NULL               2
-- 3           2500           3          4000               3
-- NULL        NULL           4          2000               4
-- NULL        NULL           5          1000               5
                   

SELECT 
    COALESCE(a.user_id, b.user_id) AS user_id_new,
    COALESCE(a.amount, 0) AS deposit_amount,
    COALESCE(b.amount, 0) AS debt_amount
FROM 
    deposit a 
FULL OUTER JOIN     
    debt b
ON 
    a.user_id = b.user_id


-- COALESCE(123, 456) AS X-> 123
-- COALESCE(NULL, 456) AS X-> 456
-- NVL(id, 0)
    -- If id is NULL, it will return 0.
    -- If id is not NULL, it will return the value of id.



