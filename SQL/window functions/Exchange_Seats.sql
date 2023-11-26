-- Write a solution to swap the seat id of every two consecutive students. If the number of students is odd, the id of the last student is not swapped.

-- Return the result table ordered by id in ascending order.
-- Input: 
-- Seat table:
-- +----+---------+
-- | id | student |
-- +----+---------+
-- | 1  | Abbot   |
-- | 2  | Doris   |
-- | 3  | Emerson |
-- | 4  | Green   |
-- | 5  | Jeames  |
-- +----+---------+
-- Output: 
-- +----+---------+
-- | id | student |
-- +----+---------+
-- | 1  | Doris   |
-- | 2  | Abbot   |
-- | 3  | Green   |
-- | 4  | Emerson |
-- | 5  | Jeames  |
-- +----+---------+
-- Explanation: 
-- Note that if the number of students is odd, there is no need to change the last one's seat


WITH CTE AS(
    SELECT 
        id,
        student,
        LAG(id, 1) OVER(ORDER BY id) AS prev,
        LEAD(id, 1) OVER(ORDER BY id) AS next
    FROM 
        Seat
)

SELECT  
    CASE 
        WHEN (id % 2 = 0) THEN prev
        WHEN (id % 2 = 1) AND next IS NOT NULL THEN next
        ELSE id
    END AS id,
    student
FROM    
    CTE
ORDER by
    id
