-- Input: 
-- Employee table:
-- +-----+-------+------------+-----------+
-- | id  | name  | department | managerId |
-- +-----+-------+------------+-----------+
-- | 101 | John  | A          | null      |
-- | 102 | Dan   | A          | 101       |
-- | 103 | James | A          | 101       |
-- | 104 | Amy   | A          | 101       |
-- | 105 | Anne  | A          | 101       |
-- | 106 | Ron   | B          | 101       |
-- +-----+-------+------------+-----------+
-- Output: 
-- +------+
-- | name |
-- +------+
-- | John |
-- +------+
-- Write a solution to find managers with at least five direct reports.
-- Return the result table in any order.



WITH CTE AS(
SELECT 
    managerId
FROM 
    Employee
GROUP BY 
    managerId
HAVING 
    COUNT(id) >= 5
)

SELECT 
    name
FROM 
    Employee
WHERE 
    id IN (SELECT
                managerId
            FROM
                CTE)

-- OR


WITH CTE AS(
SELECT 
    managerId
FROM 
    Employee
GROUP BY 
    managerId
HAVING 
    COUNT(id) >= 5
)

SELECT 
    e1.name
FROM 
    Employee e1
JOIN
    CTE e2
ON
    e1.id = e2.managerId
