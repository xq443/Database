--- blacklist
-- id  type
-- 1   zhapian
-- 2   yuqi
-- 3   taoxian

-- users
-- id      name       sex      age
-- 1       cathy       f        23
-- 2       wang        f        33
-- 3       qd          f        53
-- 4       kf          f        13

-- 1. flag: if in blacklist, flag as yes, else no

set spark.sql.shuffle.partitions = 4;
SELECT
    a.*,
    CASE WHEN b.id IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS flag
FROM 
    users.a 
LEFT JOIN 
    blacklist b 
ON 
    a.id = b.id;


-- SELECT 
--     b.*,
--     IF(b.user IS NOT NULL, 'Yes', 'No') AS flag
-- FROM 
--     blacklist b 
-- RIGHT JOIN  
--     users a 
-- ON 
--     b.id = a.id;

