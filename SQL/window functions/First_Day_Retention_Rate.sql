player_id    login_date
101           2021-12-14
101           2021-12-18
102           2021-12-31
102           2022-01-01



WITH CTE AS(
    SELECT 
        player_id,
        login_date,
        min(login_date) OVER(PARTITION BY player_id ORDER BY login_date) AS first_login
    FROM players_login
)


SELECT 
    COUNT(DISTINCT c1.player_id) / (
            SELECT
                COUNT(DISTINCT player_id)
            FROM CTE
    ) AS proportion 
FROM CTE c1
LEFT JOIN CTE c2
ON c1.player_id = c2.player_id
WHERE DATEDIFF(c2.login_date - c1.login_date) = 1
AND c1.first_login = c1.login_date  -- only consider first-ever login date as the first date