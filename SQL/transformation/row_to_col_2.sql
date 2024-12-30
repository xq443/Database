-- DDate        Win
--2015-02-19    yes
--2015-02-21    no
--2015-02-19    yes
--2015-03-19    yes

-- DDate        win
--2015-02-19    2
--2015-02-21    0
--2015-03-19    1

-- SUM(CASE WHEN win = 'Yes' THEN 1 ELSE 0 END) AS win
-- COUNT(CASE WHEN win = 'Yes' THEN 1 ELSE null END) AS win
SELECT 
    DDate,
    SUM(IF(win = 'Yes', 1, 0)) AS Win,
    SUM(IF(win = 'No', 1, 0)) AS Lose
FROM 
    TABLE
GROUP BY 
    DDate
